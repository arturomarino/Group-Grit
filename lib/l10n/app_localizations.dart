import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @utilsComponentsVideoWidgetText2.
  ///
  /// In en, this message translates to:
  /// **'Nessun video selezionato.'**
  String get utilsComponentsVideoWidgetText2;

  /// No description provided for @utilsComponentsVideoWidgetText6.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get utilsComponentsVideoWidgetText6;

  /// No description provided for @utilsComponentsVideoWidgetText7.
  ///
  /// In en, this message translates to:
  /// **'Video on Gallery'**
  String get utilsComponentsVideoWidgetText7;

  /// No description provided for @utilsComponentsVideoWidgetText8.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get utilsComponentsVideoWidgetText8;

  /// No description provided for @utilsComponentsVideoWidgetText9.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded from gallery'**
  String get utilsComponentsVideoWidgetText9;

  /// No description provided for @utilsComponentsVideoWidgetText13.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get utilsComponentsVideoWidgetText13;

  /// No description provided for @utilsComponentsVideoWidgetText16.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully!'**
  String get utilsComponentsVideoWidgetText16;

  /// No description provided for @utilsComponentsVideoWidgetText20.
  ///
  /// In en, this message translates to:
  /// **'Upload video on api.video'**
  String get utilsComponentsVideoWidgetText20;

  /// No description provided for @utilsComponentsVideoWidgetText21.
  ///
  /// In en, this message translates to:
  /// **'No video selected'**
  String get utilsComponentsVideoWidgetText21;

  /// No description provided for @utilsComponentsVideoWidgetText22.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get utilsComponentsVideoWidgetText22;

  /// No description provided for @utilsComponentsVideoWidgetText23.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get utilsComponentsVideoWidgetText23;

  /// No description provided for @utilsComponentsVideoWidgetText24.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully!'**
  String get utilsComponentsVideoWidgetText24;

  /// No description provided for @utilsComponentsDrawerText1.
  ///
  /// In en, this message translates to:
  /// **'Group Grit'**
  String get utilsComponentsDrawerText1;

  /// No description provided for @utilsComponentsDrawerText2.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Picture'**
  String get utilsComponentsDrawerText2;

  /// No description provided for @utilsComponentsDrawerText3.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get utilsComponentsDrawerText3;

  /// No description provided for @utilsComponentsDrawerText4.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to App'**
  String get utilsComponentsDrawerText4;

  /// No description provided for @utilsComponentsDrawerText5.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get utilsComponentsDrawerText5;

  /// No description provided for @utilsFunctionsAuthServiceText1.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get utilsFunctionsAuthServiceText1;

  /// No description provided for @utilsFunctionsAuthServiceText3.
  ///
  /// In en, this message translates to:
  /// **'The password provided is too weak.'**
  String get utilsFunctionsAuthServiceText3;

  /// No description provided for @utilsFunctionsAuthServiceText5.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with that email.'**
  String get utilsFunctionsAuthServiceText5;

  /// No description provided for @utilsFunctionsAuthServiceText7.
  ///
  /// In en, this message translates to:
  /// **'Email address is invalid'**
  String get utilsFunctionsAuthServiceText7;

  /// No description provided for @utilsFunctionsAuthServiceText8.
  ///
  /// In en, this message translates to:
  /// **'User disabled, contact support.'**
  String get utilsFunctionsAuthServiceText8;

  /// No description provided for @utilsFunctionsAuthServiceText9.
  ///
  /// In en, this message translates to:
  /// **'The email address does not exist, sign up'**
  String get utilsFunctionsAuthServiceText9;

  /// No description provided for @utilsFunctionsAuthServiceText10.
  ///
  /// In en, this message translates to:
  /// **'Network error, check your internet connection'**
  String get utilsFunctionsAuthServiceText10;

  /// No description provided for @utilsFunctionsAuthServiceText14.
  ///
  /// In en, this message translates to:
  /// **'Check email or password and try again'**
  String get utilsFunctionsAuthServiceText14;

  /// No description provided for @utilsFunctionsUploadServiceText6.
  ///
  /// In en, this message translates to:
  /// **'Il tuo titolo video'**
  String get utilsFunctionsUploadServiceText6;

  /// No description provided for @utilsFunctionsUploadServiceText8.
  ///
  /// In en, this message translates to:
  /// **'Descrizione del video'**
  String get utilsFunctionsUploadServiceText8;

  /// No description provided for @utilsFunctionsUploadServiceText16.
  ///
  /// In en, this message translates to:
  /// **'Video caricato con successo!'**
  String get utilsFunctionsUploadServiceText16;

  /// No description provided for @utilsFunctionsUploadServiceText17.
  ///
  /// In en, this message translates to:
  /// **'Errore durante il caricamento del video.'**
  String get utilsFunctionsUploadServiceText17;

  /// No description provided for @mainText1.
  ///
  /// In en, this message translates to:
  /// **'Group Grit'**
  String get mainText1;

  /// No description provided for @pagesHomePageText1.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get pagesHomePageText1;

  /// No description provided for @pagesHomePageText3.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get pagesHomePageText3;

  /// No description provided for @pagesHomePageText4.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get pagesHomePageText4;

  /// No description provided for @pagesHomePageText6.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get pagesHomePageText6;

  /// No description provided for @pagesHomePageText7.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get pagesHomePageText7;

  /// No description provided for @pagesHomePageText8.
  ///
  /// In en, this message translates to:
  /// **'Update Video'**
  String get pagesHomePageText8;

  /// No description provided for @pagesGroupsCreateGroupPageText4.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get pagesGroupsCreateGroupPageText4;

  /// No description provided for @pagesGroupsCreateGroupPageText5.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get pagesGroupsCreateGroupPageText5;

  /// No description provided for @pagesGroupsCreateGroupPageText6.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pagesGroupsCreateGroupPageText6;

  /// No description provided for @pagesGroupsCreateGroupPageText7.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get pagesGroupsCreateGroupPageText7;

  /// No description provided for @pagesGroupsCreateGroupPageText8.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group description'**
  String get pagesGroupsCreateGroupPageText8;

  /// No description provided for @pagesGroupsCreateGroupPageText15.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully'**
  String get pagesGroupsCreateGroupPageText15;

  /// No description provided for @pagesGroupsCreateGroupPageText16.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get pagesGroupsCreateGroupPageText16;

  /// No description provided for @pagesGroupsJoinGroupPageText3.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get pagesGroupsJoinGroupPageText3;

  /// No description provided for @pagesGroupsJoinGroupPageText4.
  ///
  /// In en, this message translates to:
  /// **'Group Code'**
  String get pagesGroupsJoinGroupPageText4;

  /// No description provided for @pagesGroupsJoinGroupPageText6.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get pagesGroupsJoinGroupPageText6;

  /// No description provided for @pagesAuthenticationForgotPasswordPageText1.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get pagesAuthenticationForgotPasswordPageText1;

  /// No description provided for @pagesAuthenticationForgotPasswordPageText2.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password'**
  String get pagesAuthenticationForgotPasswordPageText2;

  /// No description provided for @pagesAuthenticationForgotPasswordPageText3.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get pagesAuthenticationForgotPasswordPageText3;

  /// No description provided for @pagesAuthenticationForgotPasswordPageText4.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent!'**
  String get pagesAuthenticationForgotPasswordPageText4;

  /// No description provided for @pagesAuthenticationForgotPasswordPageText5.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get pagesAuthenticationForgotPasswordPageText5;

  /// No description provided for @pagesAuthenticationUsernamePageText3.
  ///
  /// In en, this message translates to:
  /// **'SignUp Complete!'**
  String get pagesAuthenticationUsernamePageText3;

  /// No description provided for @pagesAuthenticationUsernamePageText4.
  ///
  /// In en, this message translates to:
  /// **'Before you get started, let\'s create your username'**
  String get pagesAuthenticationUsernamePageText4;

  /// No description provided for @pagesAuthenticationUsernamePageText5.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Username'**
  String get pagesAuthenticationUsernamePageText5;

  /// No description provided for @pagesAuthenticationUsernamePageText6.
  ///
  /// In en, this message translates to:
  /// **'Type your username here'**
  String get pagesAuthenticationUsernamePageText6;

  /// No description provided for @pagesAuthenticationUsernamePageText7.
  ///
  /// In en, this message translates to:
  /// **'Invalid username, at least 6 characters'**
  String get pagesAuthenticationUsernamePageText7;

  /// No description provided for @pagesAuthenticationUsernamePageText8.
  ///
  /// In en, this message translates to:
  /// **'Username is unavailable'**
  String get pagesAuthenticationUsernamePageText8;

  /// No description provided for @pagesAuthenticationUsernamePageText11.
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get pagesAuthenticationUsernamePageText11;

  /// No description provided for @pagesAuthenticationUsernamePageText12.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pagesAuthenticationUsernamePageText12;

  /// No description provided for @pagesAuthenticationSignUpPageText3.
  ///
  /// In en, this message translates to:
  /// **'SignUp to FitTrack'**
  String get pagesAuthenticationSignUpPageText3;

  /// No description provided for @pagesAuthenticationSignUpPageText4.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get pagesAuthenticationSignUpPageText4;

  /// No description provided for @pagesAuthenticationSignUpPageText5.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get pagesAuthenticationSignUpPageText5;

  /// No description provided for @pagesAuthenticationSignUpPageText6.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get pagesAuthenticationSignUpPageText6;

  /// No description provided for @pagesAuthenticationSignUpPageText7.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get pagesAuthenticationSignUpPageText7;

  /// No description provided for @pagesAuthenticationSignUpPageText8.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pagesAuthenticationSignUpPageText8;

  /// No description provided for @pagesAuthenticationSignUpPageText9.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get pagesAuthenticationSignUpPageText9;

  /// No description provided for @pagesAuthenticationSignUpPageText17.
  ///
  /// In en, this message translates to:
  /// **'SignUp'**
  String get pagesAuthenticationSignUpPageText17;

  /// No description provided for @pagesAuthenticationSignUpPageText18.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get pagesAuthenticationSignUpPageText18;

  /// No description provided for @pagesAuthenticationSignUpPageText26.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get pagesAuthenticationSignUpPageText26;

  /// No description provided for @pagesAuthenticationSignUpPageText27.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get pagesAuthenticationSignUpPageText27;

  /// No description provided for @pagesAuthenticationLoginPageText3.
  ///
  /// In en, this message translates to:
  /// **'Login to FitTrack'**
  String get pagesAuthenticationLoginPageText3;

  /// No description provided for @pagesAuthenticationLoginPageText4.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get pagesAuthenticationLoginPageText4;

  /// No description provided for @pagesAuthenticationLoginPageText5.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get pagesAuthenticationLoginPageText5;

  /// No description provided for @pagesAuthenticationLoginPageText6.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get pagesAuthenticationLoginPageText6;

  /// No description provided for @pagesAuthenticationLoginPageText7.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get pagesAuthenticationLoginPageText7;

  /// No description provided for @pagesAuthenticationLoginPageText8.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get pagesAuthenticationLoginPageText8;

  /// No description provided for @pagesAuthenticationLoginPageText16.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get pagesAuthenticationLoginPageText16;

  /// No description provided for @pagesAuthenticationLoginPageText17.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get pagesAuthenticationLoginPageText17;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
