const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Funzione schedulata per controllare ogni 2 minuti
exports.scheduledAutoKick = functions.region("europe-west1").pubsub
    .schedule("every 2 minutes").onRun(async (context) => {
        console.log("🔄 Starting expired challenges check and auto-kick rules...");

        const now = new Date();
        try {
            // Recupera tutti i gruppi
            const groupsSnapshot = await db.collection("groups").get();
            for (const groupDoc of groupsSnapshot.docs) {
                const groupId = groupDoc.id;
                const groupData = groupDoc.data();

                if (groupData.auto_kick_rules !== "Missing 2 Challenges in a row") {
                    console.log(`🚫 No auto-kick rules for group ${groupId}, skipping.`);
                    continue;
                }

                // Recupera tutte le challenge concluse del gruppo non ancora verificate
                const challengesSnapshot = await db.collection("groups").doc(groupId).collection("challenges")
                    .where("endDateTime", "<=", now)
                    .get();

                if (challengesSnapshot.empty) {
                    console.log(`⚠️ No expired challenges for group ${groupId}, skipping check.`);
                    continue;
                }

                // Recupera tutti gli utenti del gruppo
                const membershipsSnapshot = await db.collection("memberships")
                    .where("groupId", "==", groupId)
                    .get();

                for (const membershipDoc of membershipsSnapshot.docs) {
                    const userId = membershipDoc.data().userId;
                    const userRole = membershipDoc.data().role;
                    
                    // Se l'utente è un admin, non fare nulla
                    if (userRole === 'admin') {
                        console.log(`👮 User ${userId} is an admin, skipping.`);
                        continue;
                    }

                    console.log(`🔍 Checking challenges for user: ${userId}`);

                    // Recupera o crea il ranking dell'utente
                    const userRankingRef = db.collection("users_rankings").doc(`${userId}_${groupId}`);
                    const userRankingSnapshot = await userRankingRef.get();
                    let missedChallenges = userRankingSnapshot.exists ? (userRankingSnapshot.data().missedChallenges || 0) : 0;

                    // Verifica se l'utente ha saltato challenge e aggiorna il conteggio
                    for (const challenge of challengesSnapshot.docs) {
                        if (challenge.data().verified_auto_kick) {
                            console.log(`✔️ Challenge ${challenge.id} has already been verified for auto-kick, skipping.`);
                            continue;
                        }

                        const userChallengeSnapshot = await db.collection("users_challenges")
                            .where("userId", "==", userId)
                            .where("challengeId", "==", challenge.id)
                            .get();

                        if (userChallengeSnapshot.empty) {
                            missedChallenges++;
                        }
                    }

                    // Se l'utente ha saltato 2 challenge, rimuovilo dal gruppo e resetta il conteggio
                    if (missedChallenges >= 2) {
                        console.log(`⛔ User ${userId} has missed 2 challenges in total, removing from group and leaderboard.`);
                        await membershipDoc.ref.delete();
                        await userRankingRef.delete();
                    } else {
                        // Aggiorna il conteggio delle challenge saltate nel ranking
                        await userRankingRef.set({
                            userId: userId,
                            groupId: groupId,
                            missedChallenges: missedChallenges
                        }, { merge: true });
                    }
                }

                // Segna tutte le challenge verificate per l'auto-kick
                for (const challengeDoc of challengesSnapshot.docs) {
                    await challengeDoc.ref.update({ verified_auto_kick: true });
                    console.log(`✔️ Challenge ${challengeDoc.id} marked as verified.`);
                }
            }
            console.log("🎉 Auto-kick process completed.");
        } catch (error) {
            console.error("❌ Error during auto-kick:", error);
        }
    });






exports.scheduledResetStreaks = functions.region("europe-west1").pubsub
    .schedule("every 2 minutes").onRun(async (context) => {
        console.log("🔄 Avvio controllo delle challenge scadute...");

        const now = new Date();
        try {
            // Recupera tutti i gruppi
            const groupsSnapshot = await db.collection("groups").get();
            for (const groupDoc of groupsSnapshot.docs) {
                const groupId = groupDoc.id;

                // Recupera tutte le challenge del gruppo
                const challengesSnapshot = await db.collection("groups").doc(groupId).collection("challenges").get();

                for (const challengeDoc of challengesSnapshot.docs) {
                    const challengeData = challengeDoc.data();
                    const challengeId = challengeDoc.id;
                    const endDateTime = challengeData.endDateTime;

                    // Se la challenge è già verificata, la saltiamo
                    if (challengeData.verified_streak) {
                        console.log(`✔️ Challenge ${challengeId} è già verificata, salto.`);
                        continue;
                    }

                    // Converte il timestamp Firestore
                    const challengeEndTime = endDateTime instanceof admin.firestore.Timestamp
                        ? endDateTime.toDate()
                        : new Date(endDateTime);

                    if (!challengeEndTime || challengeEndTime > now) {
                        console.log(`⏳ Challenge ${challengeId} non ancora scaduta.`);
                        continue; // Challenge non ancora scaduta
                    }

                    console.log(`⏳ Challenge ${challengeId} scaduta. Controllo utenti...`);

                    // Recupera tutti gli utenti della classifica del gruppo
                    const rankingsSnapshot = await db.collection("users_rankings")
                        .where("groupId", "==", groupId)
                        .get();

                    for (const rankingDoc of rankingsSnapshot.docs) {
                        const userId = rankingDoc.data().userId;
                        console.log(`🔍 Controllo challenge per utente: ${userId}`);

                        // Controlla se l'utente è ancora membro del gruppo
                        const membershipSnapshot = await db.collection("memberships")
                            .where("userId", "==", userId)
                            .where("groupId", "==", groupId)
                            .get();

                        if (membershipSnapshot.empty) {
                            console.log(`⚠️ Utente ${userId} non è più membro del gruppo ${groupId}, salto.`);
                            continue;
                        }

                        // Controlla se l'utente ha completato la challenge
                        const userChallengeSnapshot = await db.collection("users_challenges")
                            .where("userId", "==", userId)
                            .where("challengeId", "==", challengeId)
                            .get();

                        if (userChallengeSnapshot.empty) {
                            console.log(`⚠️ Utente ${userId} non ha completato la challenge ${challengeId}, resetto streak.`);
                            await rankingDoc.ref.update({ streak: 0 });
                        } else {
                            console.log(`✅ Utente ${userId} ha completato la challenge.`);
                        }
                    }

                    // Segna la challenge come verificata dopo aver controllato tutti gli utenti
                    await challengeDoc.ref.update({ verified_streak: true });
                    console.log(`✔️ Challenge ${challengeId} segnata come verificata.`);
                }
            }
            console.log("🎉 Processo di reset completato.");
        } catch (error) {
            console.error("❌ Errore durante il reset degli streak:", error);
        }
    });


exports.newGroupMessageNotification = functions
    .region('europe-west1')
    .firestore.document('groups/{groupId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();
        const groupId = context.params.groupId;
        const senderId = messageData.senderId;
        const messageContent = messageData.text;

        try {
            // Ottieni il nome del mittente
            const senderDoc = await db.collection('users').doc(senderId).get();
            const senderName = senderDoc.exists ? senderDoc.data().display_name || 'Utente' : 'Utente';

            // Ottieni il nome del gruppo
            const groupDoc = await db.collection('groups').doc(groupId).get();
            const groupName = groupDoc.exists ? groupDoc.data().name || 'Gruppo' : 'Gruppo';

            // Ottieni gli ID degli utenti membri del gruppo, escludendo il mittente
            const membershipsSnapshot = await db
                .collection('memberships')
                .where('groupId', '==', groupId)
                .get();

            if (membershipsSnapshot.empty) {
                console.log('Nessun membro trovato per questo gruppo.');
                return null;
            }

            // Ottieni i token dei dispositivi degli utenti destinatari
            const tokens = [];
            for (const membershipDoc of membershipsSnapshot.docs) {
                const userId = membershipDoc.data().userId;

                // Escludi il mittente dalla notifica
                if (userId === senderId) continue;

                const tokensSnapshot = await db
                    .collection('users')
                    .doc(userId)
                    .collection('tokens')
                    .get();

                tokensSnapshot.forEach(tokenDoc => {
                    const token = tokenDoc.data().token;
                    if (token) tokens.push(token);
                });
            }

            if (tokens.length === 0) {
                console.log('Nessun token di dispositivo trovato per i membri del gruppo.');
                return null;
            }

            // Formattazione della notifica con nome mittente, nome gruppo e testo messaggio
            for (const token of tokens) {
                const message = {
                    token: token,
                    data: {
                        screen: "ChatPage",
                        groupId: groupId,
                        messageId: context.params.messageId,
                        title: `${senderName} [${groupName}]`,
                        body: messageContent
                    },
                    android: {
                        priority: "high"
                    },
                    apns: {
                        payload: {
                            aps: {
                                alert: {
                                    title: `${senderName} [${groupName}]`,
                                    body: messageContent
                                },
                                sound: "default",
                                contentAvailable: true,
                                mutableContent: true
                            }
                        }
                    }
                };

                try {
                    const response = await admin.messaging().send(message);
                    console.log(`Notifica inviata con successo a ${token}:`, response);
                } catch (error) {
                    console.error(`Errore nell'invio della notifica a ${token}:`, error);
                }
            }

            return null;
        } catch (error) {
            console.error("Errore durante l'invio delle notifiche:", error);
            return null;
        }
    });

exports.newChallengeNotification = functions
    .region('europe-west1')
    .firestore.document('groups/{groupId}/challenges/{challengeId}')
    .onCreate(async (snapshot, context) => {
        const challengeData = snapshot.data();
        const groupId = context.params.groupId;
        const groupName = challengeData.name;
        const groupPhoto = challengeData.photo_url;
        const creatorId = challengeData.creatorId;
        const challengeTitle = challengeData.activityName;

        try {
            // Ottieni il nome del creatore
            const creatorDoc = await db.collection('users').doc(creatorId).get();
            const creatorName = creatorDoc.exists ? creatorDoc.data().display_name || 'User' : 'User';

            // Ottieni il nome del gruppo
            const groupDoc = await db.collection('groups').doc(groupId).get();
            const groupName = groupDoc.exists ? groupDoc.data().name || 'Group' : 'Group';

            // Ottieni gli ID degli utenti membri del gruppo, escludendo il creatore
            const membershipsSnapshot = await db
                .collection('memberships')
                .where('groupId', '==', groupId)
                .get();

            if (membershipsSnapshot.empty) {
                console.log('No members found for this group.');
                return null;
            }

            // Ottieni i token dei dispositivi degli utenti destinatari
            const tokens = [];
            for (const membershipDoc of membershipsSnapshot.docs) {
                const userId = membershipDoc.data().userId;

                // Escludi il creatore dalla notifica
                if (userId === creatorId) continue;

                const tokensSnapshot = await db
                    .collection('users')
                    .doc(userId)
                    .collection('tokens')
                    .get();

                tokensSnapshot.forEach(tokenDoc => {
                    const token = tokenDoc.data().token;
                    if (token) tokens.push(token);
                });
            }

            if (tokens.length === 0) {
                console.log('No device tokens found for group members.');
                return null;
            }

            // Formattazione della notifica con nome creatore, nome gruppo e titolo della challenge
            for (const token of tokens) {
                const message = {
                    token: token,
                    data: {
                        screen: "GroupPage",
                        groupId: `${groupId}`,
                        groupName: `${groupName}`,
                        groupPhoto: `${groupPhoto}`,
                        title: `${creatorName} created a challenge in ${groupName}`,
                        body: challengeTitle
                    },
                    android: {
                        priority: "high"
                    },
                    apns: {
                        payload: {
                            aps: {
                                alert: {
                                    title: `${creatorName} created a challenge in ${groupName}`,
                                    body: challengeTitle
                                },
                                sound: "default",
                                contentAvailable: true,
                                mutableContent: true
                            }
                        }
                    }
                };
                
                try {
                    const response = await admin.messaging().send(message);
                    console.log(`Notifica inviata con successo a ${token}:`, response);
                } catch (error) {
                    console.error(`Errore nell'invio della notifica a ${token}:`, error);
                }
            }

            return null;
        } catch (error) {
            console.error("Errore durante l'invio delle notifiche:", error);
            return null;
        }
    });

    