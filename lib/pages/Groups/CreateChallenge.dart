import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class CreateChallengePage extends StatefulWidget {
  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Photo';

  final TextEditingController _challengeNameController = TextEditingController();

  final TextEditingController _challengeDescriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = TimeOfDay.now();
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime = TimeOfDay.now();

  // Function to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectTime(context); // Call _selectTime after selecting the date
      });
    }
  }

  // Function to select the time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(bottom: 30),
          height: GGSize.screenHeight(context) * 0.3,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Flexible(
                child: Container(
                  height: 200,
                  child: CupertinoDatePicker(
                    minimumDate: DateTime.now().day == _selectedDate?.day ? DateTime.now() : null,
                    use24hFormat: true,
                    mode: CupertinoDatePickerMode.time,
                    //initialDateTime: DateTime.now().add(Duration(minutes: 1)),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _selectedTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                      });
                    },
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop(_selectedTime);
                  FocusScope.of(context).unfocus();
                },
              )
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _selectedDate!,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
        _selectEndTime(context); // Call _selectTime after selecting the date
      });
    }
  }

  // Function to select the time
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(bottom: 30),
          height: GGSize.screenHeight(context) * 0.3,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Flexible(
                child: CupertinoDatePicker(
                  use24hFormat: true,
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedEndTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                    });
                  },
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop(_selectedEndTime);
                  FocusScope.of(context).unfocus();
                },
              )
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  bool _showCircle = false;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: GGColors.backgroundColor,
          title: Text(
            'Create Challenge',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),

                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text("Require Fields", style: TextStyle(color: GGColors.primarytextColor, fontSize: 23, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text("Challenge Name", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    //() => _selectTime(context),

                    TextFormField(
                      controller: _challengeNameController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: GGColors.primarytextColor),
                      decoration: InputDecoration(
                        hintText: "50 pushups a day",
                        hintStyle: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: GGColors.buttonColor,
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.TextFieldColor, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a challenge name';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 7),
                      child: Row(
                        children: [
                          Text("Challenge Must be done between:",
                              style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Future.delayed(Duration(milliseconds: 500), () {
                          _selectDate(context);
                        });
                      },
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: GGSize.screenHeight(context) * 0.058,
                        decoration: BoxDecoration(
                          color: GGColors.buttonColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  _selectedDate != null && _selectedTime != null
                                      ? "${_selectedDate!.toLocal()}".split(' ')[0] + " " + _selectedTime!.format(context)
                                      : "Enter Time from",
                                  style: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    CupertinoButton(
                      onPressed: () => _selectEndDate(context),
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: GGSize.screenHeight(context) * 0.058,
                        decoration: BoxDecoration(
                          color: GGColors.buttonColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  _selectedEndDate != null && _selectedEndTime != null
                                      ? "${_selectedEndDate!.toLocal()}".split(' ')[0] + " " + _selectedEndTime!.format(context)
                                      : "Enter Time to",
                                  style: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 7),
                      child: Row(
                        children: [
                          Text("Video Proof Needed", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: GGSize.screenHeight(context) * 0.058,
                        width: GGSize.screenWidth(context),
                        decoration: BoxDecoration(
                          color: GGColors.buttonColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Center(
                            child: Row(
                              children: [
                                Container(
                                  width: GGSize.screenWidth(context) * 0.8,
                                  child: DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(19),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    value: dropdownValue,
                                    elevation: 16,
                                    iconEnabledColor: Colors.transparent,
                                    style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.w700),
                                    underline: Container(
                                      height: 0,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    onChanged: (String? newValue) {
                                      if (newValue == 'Apple Health') {
                                        // Show a message or perform an action for Apple Health
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Apple Health option is coming soon!'),
                                            backgroundColor: Colors.deepOrange,
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          dropdownValue = newValue!;
                                        });
                                      }
                                    },
                                    items: <String>['Photo', 'Video', 'Confirmation', 'Apple Health'].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          children: [
                                            Text(
                                              value,
                                              style: TextStyle(color: GGColors.primaryColor),
                                            ),
                                            Spacer(),
                                            Visibility(
                                              visible: value == 'Apple Health',
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: GGSize.screenWidth(context) * 0.3,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          // azzurro
                                                          Color.fromARGB(255, 188, 54, 255), // viola
                                                          Color.fromARGB(255, 255, 8, 234),
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(9),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Coming Soon'.toUpperCase(),
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text("Optional Field", style: TextStyle(color: GGColors.primarytextColor, fontSize: 23, fontWeight: FontWeight.bold)),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text("Challenge Description",
                              style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: _challengeDescriptionController,
                      keyboardType: TextInputType.text,
                      minLines: 5,
                      maxLines: 7,
                      style: TextStyle(color: GGColors.primarytextColor),
                      decoration: InputDecoration(
                        hintText: "If needed, give more details/instructions for the challenge, or upload video demo below",
                        hintStyle: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: GGColors.buttonColor,
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.TextFieldColor, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    /*
                    DottedBorder(
                      padding: EdgeInsets.zero,
                      dashPattern: [5, 5],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(19),
                      color: GGColors.primaryColor,
                      strokeWidth: 1,
                      child: Container(
                          width: GGSize.screenWidth(context),
                          height: GGSize.screenHeight(context) * 0.1,
                          decoration: BoxDecoration(color: const Color.fromARGB(54, 0, 103, 238), borderRadius: BorderRadius.circular(19)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.share, color: GGColors.primaryColor),
                              SizedBox(width: 5),
                              Text("Tap to Upload Video", style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          )),
                    ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedDate != null &&
                              _selectedTime != null &&
                              _selectedEndDate != null &&
                              _selectedEndTime != null) {
                            DateTime startDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );
                            DateTime endDateTime = DateTime(
                              _selectedEndDate!.year,
                              _selectedEndDate!.month,
                              _selectedEndDate!.day,
                              _selectedEndTime!.hour,
                              _selectedEndTime!.minute,
                            );

                            if (startDateTime.isAfter(endDateTime) || startDateTime.isAtSameMomentAs(endDateTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Start date must be before end date'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            var challengeDoc =
                                FirebaseFirestore.instance.collection('groups').doc(arguments['groupId']).collection('challenges').doc();
                            await challengeDoc.set({
                              'activityName': _challengeNameController.text.trim(),
                              'activityDescription': _challengeDescriptionController.text.trim(),
                              'startDateTime': startDateTime,
                              'endDateTime': endDateTime,
                              'videoProofMode': dropdownValue,
                              'challengeId': challengeDoc.id,
                              'creatorId': FirebaseAuth.instance.currentUser!.uid,
                            });
                            setState(() {
                              _showCircle = true;
                            });

                            await Future.delayed(Duration(seconds: 2));
                            setState(() {
                              _showCircle = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                            width: GGSize.screenWidth(context),
                            height: GGSize.screenHeight(context) * 0.065,
                            decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Create Challenge", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(width: 10),
                                Visibility(
                                    visible: _showCircle,
                                    child: SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ))),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
