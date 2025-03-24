import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_grit/firebase_options.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/pages/Authentication/AuthPage.dart';
import 'package:group_grit/pages/Authentication/DisplayNamePage.dart';
import 'package:group_grit/pages/Authentication/ForgotPasswordPage.dart';
import 'package:group_grit/pages/Authentication/SignupPage.dart';
import 'package:group_grit/pages/Authentication/UsernamePage.dart';
import 'package:group_grit/pages/Chat/ChatPage.dart';
import 'package:group_grit/pages/Groups/CreateActivity.dart';
import 'package:group_grit/pages/Groups/CreateGroupPage.dart';
import 'package:group_grit/pages/Groups/EditGroupPage.dart';
import 'package:group_grit/pages/Groups/GiveExcusePage.dart';
import 'package:group_grit/pages/Groups/GroupPage.dart';
import 'package:group_grit/pages/Groups/JoinGroupPage.dart';
import 'package:group_grit/pages/Groups/MyGroupsPage.dart';
import 'package:group_grit/pages/Groups/UploadVideoPage.dart';
import 'package:group_grit/pages/HomePage.dart';
import 'package:group_grit/pages/Authentication/LoginPage.dart';
import 'package:group_grit/pages/User/LanguagePage.dart';
import 'package:group_grit/pages/User/ProfilePage.dart';
import 'package:group_grit/utils/appState.dart';
import 'package:group_grit/utils/components/VideoWidget.dart';
import 'package:group_grit/utils/components/authButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:group_grit/utils/functions/AnalyticsEngine.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// auto generated after you run `flutter pub get`

void main() async {
  String? currentScreen;

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
    name: 'App_Opened',
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      defaultColor: Color(0xFF9D50DD),
      ledColor: Colors.white,
      playSound: true,
    )
  ]);

  // Imposta il listener per il clic sulla notifica
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onNotificationClicked,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final status = await AppTrackingTransparency.requestTrackingAuthorization();
  runApp(const MyApp());
}

final currentLocale = ValueNotifier<Locale>(AppLocales.supportedLocales.first);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  Mixpanel? mixpanel;

  Future<void> initMixpanel() async {
    // initialize Mixpanel
   // mixpanel = await Mixpanel.init("587c9d6454f9336fe2cd90647429f9ad", trackAutomaticEvents: false);

    //mixpanel?.setLoggingEnabled(true);
    final packageInfo = await PackageInfo.fromPlatform();
    //mixpanel?.track("App Opened", properties: {"version": packageInfo.version});
    if (FirebaseAuth.instance.currentUser != null) {
      mixpanel?.identify('${FirebaseAuth.instance.currentUser!.uid}');
      mixpanel?.registerSuperProperties({
        "user": "${FirebaseAuth.instance.currentUser!.uid}",
        "email": "${FirebaseAuth.instance.currentUser!.email}",
        "name": "${FirebaseAuth.instance.currentUser!.displayName}"
      });
    }
  }

  void monitorInternetConnection() {
    bool? isConnected = false;

    Stream.periodic(Duration(seconds: 5))
        .asyncMap((_) => InternetAddress.lookup('google.com'))
        .listen((result) {
      bool currentlyConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (isConnected == null || isConnected != currentlyConnected) {
        isConnected = currentlyConnected;
        if (isConnected != null && isConnected!) {
          print('Connection state: ✅ Connected to the internet');
        } else {
          print('Connection state: ❌ No internet connection');
        }
      }
    }, onError: (error) {
      if (isConnected != false) {
        isConnected = false;
        print('No internet connection');
      }
    });
  }

  void checkUserAuthentication() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        //print("⚠️ Utente non autenticato, reindirizzamento alla schermata di login.");
        //navigatorKey.currentState?.pushNamedAndRemoveUntil('/LoginPage', (route) => false);
      } else {
        try {
          // Verifica se l'utente esiste ancora in FirebaseAuth
          final currentUser = FirebaseAuth.instance.currentUser;
          await currentUser?.reload();
          if (FirebaseAuth.instance.currentUser == null) {
            print("⚠️ Utente non più valido, reindirizzamento alla schermata di login.");
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/LoginPage', (route) => false);
          } else {
            print("✅ Utente autenticato: ${user.email}");
          }
        } catch (e) {
          print("❌ Errore durante la verifica dell'utente: $e");
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/LoginPage', (route) => false);
        }
      }
    });
  }

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Messaggio ricevuto in foreground: ${message.data}");
    if(Platform.isIOS){
      print("🍏 iOS gestisce la notifica tramite APNs, nessuna notifica manuale.");
      return;
    }

    // 🔴 Puliamo il payload
    Map<String, String> cleanedPayload = {};
    message.data.forEach((key, value) {
      if (value != null &&
          value != "null" &&
          value != "<null>" &&
          value != "undefined" &&
          value.toString().trim().isNotEmpty) {
        cleanedPayload[key] = value.toString();
      } else {
        cleanedPayload[key] = ""; // 🔴 Imposta stringa vuota invece di `null`
      }
    });

    // 🔥 Creiamo la notifica solo se il payload è valido
    if (cleanedPayload.isNotEmpty) {
      print("📩 Creazione notifica con payload pulito: $cleanedPayload");
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'basic_channel',
          title: cleanedPayload['title'] ?? 'Nuova notifica',
          body: cleanedPayload['body'] ?? 'Hai ricevuto un nuovo messaggio',
          payload: cleanedPayload, // Usa il payload pulito
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    }
  });
}


  void checkInitialNotification() async {
    ReceivedAction? receivedAction = await AwesomeNotifications().getInitialNotificationAction();

    if (receivedAction != null) {
      print("📩 Notifica ricevuta all'avvio: ${receivedAction.payload}");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onNotificationClicked(receivedAction); // Naviga solo quando l'app è pronta
      });
    }
  }

  @override
  void initState() {
    initMixpanel();
    setupFirebaseMessaging();
    checkInitialNotification();
    monitorInternetConnection();
    checkUserAuthentication();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
        valueListenable: currentLocale,

        /// the ValueNotifier
        builder: (_, locale, __) => MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                AppLocalizations.delegate, // Add this line
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocales.supportedLocales,
              locale: locale,
              title: 'Group Grit',
              theme: ThemeData(
                popupMenuTheme: PopupMenuThemeData(
                  color: const Color.fromRGBO(181, 213, 255, 1),
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: const Color.fromRGBO(181, 213, 255, 1),
                  todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      return null; // Use the default value.
                    },
                  ),
                  todayForegroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.black;
                      }
                      return null; // Use the default value.
                    },
                  ),
                  dayForegroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.black;
                      }
                      return null; // Use the default value.
                    },
                  ),
                  dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      return null; // Use the default value.
                    },
                  ),
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: const Color.fromRGBO(181, 213, 255, 1),
                  hourMinuteColor: Colors.white,
                  hourMinuteTextColor: Colors.black,
                  dayPeriodTextColor: Colors.black,
                  dayPeriodColor: Colors.white,
                ),
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              home: AuthPage(),
              debugShowCheckedModeBanner: false,
              routes: {
                '/LoginPage': (context) => LoginPage(),
                '/HomePage': (context) => HomePage(),
                '/SignUpPage': (context) => SignUpPage(),
                '/UsernamePage': (context) => UsernamePage(),
                '/ForgotPasswordPage': (context) => ForgotPasswordPage(),
                '/CreateGroupPage': (context) => CreateGroupPage(),
                '/JoinGroupPage': (context) => JoinGroupPage(),
                '/MyGroupsPage': (context) => MyGroupsPage(),
                '/GroupPage': (context) => GroupPage(),
                '/UploadVideoPage': (context) => UploadVideoPage(idChallenge: '', idGruppo: ''),
                '/GiveExcusePage': (context) => GiveExcusePage(),
                '/CreateActivityPage': (context) => CreateActivityPage(),
                '/LanguagePage': (context) => LanguagePage(),
                '/ChatPage': (context) => ChatPage(
                      groupId: '',
                    ),
                '/DisplayNamePage': (context) => DisplayNamePage(),
              },
            ));
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Messaggio ricevuto in background: ${message.data}");

  if (message.data.isNotEmpty) {
    if (Platform.isIOS) {
      print("🍏 iOS gestisce la notifica tramite APNs, nessuna notifica manuale.");
      return;
    }

    // 🔴 Puliamo il payload per evitare crash su Android
    Map<String, String> cleanedPayload = {};
    message.data.forEach((key, value) {
      if (value != null &&
          value != "null" &&
          value != "<null>" &&
          value != "undefined" &&
          value.toString().trim().isNotEmpty) {
        cleanedPayload[key] = value.toString();
      } else {
        cleanedPayload[key] = ""; // 🔴 Imposta stringa vuota invece di `null`
      }
    });

    if (cleanedPayload.isNotEmpty) {
      print("📩 Creazione notifica su Android con payload pulito: $cleanedPayload");
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'basic_channel',
          title: cleanedPayload['title'] ?? "New message",
          body: cleanedPayload['body'] ?? "You have a new message",
          payload: cleanedPayload,
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    }
  }
}



// Definisci il comportamento quando una notifica viene cliccata
Future<void> onNotificationClicked(ReceivedAction receivedAction) async {
  print("📩 Notifica cliccata: ${receivedAction.payload}");

  if (receivedAction.payload == null) {
    print("⚠️ Nessun payload nella notifica, ignorata.");
    return;
  }

  String? screen = receivedAction.payload!['screen'];
  String? groupId = receivedAction.payload!['groupId'];
  String? messageId = receivedAction.payload!['messageId'];
  String? groupName = receivedAction.payload!['groupName'] ?? '';
  String? groupPhoto = receivedAction.payload!['groupPhoto'] ?? '';

  print("🔗 Tentativo di navigazione verso: $screen");

  // 🔴 ATTENDE CHE IL NAVIGATOR SIA PRONTO
  int retries = 0;
  while (navigatorKey.currentState == null && retries < 5) {
    print("⌛ Il Navigator non è ancora pronto, attendo...");
    await Future.delayed(const Duration(milliseconds: 500));
    retries++;
  }

  if (navigatorKey.currentState == null) {
    print("🚨 Il Navigator non è disponibile. Navigazione annullata.");
    return;
  }

  if (screen == "ChatPage" && groupId != null && groupId.isNotEmpty) {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => ChatPage(groupId: groupId),
    ));
  } else if (screen == "GroupPage" && groupId != null && groupId.isNotEmpty) {
    navigatorKey.currentState?.pushNamed('/GroupPage', arguments: {
      'groupId': groupId,
      'name': groupName,
      'photo_url': groupPhoto,
    });
  } else {
    print("⚠️ Schermata non riconosciuta o dati mancanti, nessuna navigazione effettuata.");
  }
}
