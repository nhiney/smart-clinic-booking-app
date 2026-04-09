import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @back_button_text.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_button_text;

  /// No description provided for @welcome_to.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcome_to;

  /// No description provided for @login_account.
  ///
  /// In en, this message translates to:
  /// **'Login to Account'**
  String get login_account;

  /// No description provided for @staff_login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Are you a healthcare staff?'**
  String get staff_login_prompt;

  /// No description provided for @staff_login_link.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get staff_login_link;

  /// No description provided for @save_login.
  ///
  /// In en, this message translates to:
  /// **'Remember session'**
  String get save_login;

  /// No description provided for @staff_login_title.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get staff_login_title;

  /// No description provided for @or_label.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or_label;

  /// No description provided for @continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Fast Appointment Booking'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_desc_1.
  ///
  /// In en, this message translates to:
  /// **'Find the right doctor and book in just a few steps.'**
  String get onboarding_desc_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Flexible Consultation'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_desc_2.
  ///
  /// In en, this message translates to:
  /// **'Easily receive reminders and track your medical info.'**
  String get onboarding_desc_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Smart Medical Records'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_desc_3.
  ///
  /// In en, this message translates to:
  /// **'Securely store health history and access it quickly.'**
  String get onboarding_desc_3;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get login_welcome;

  /// No description provided for @phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_label;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number...'**
  String get phone_hint;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get password_hint;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get no_account;

  /// No description provided for @register_now.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get register_now;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @error_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get error_phone_required;

  /// No description provided for @error_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get error_password_required;

  /// No description provided for @error_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get error_login_failed;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register_title;

  /// No description provided for @register_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get register_back;

  /// No description provided for @full_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name_label;

  /// No description provided for @full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get full_name_hint;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get email_hint;

  /// No description provided for @hospital_label.
  ///
  /// In en, this message translates to:
  /// **'Target Hospital'**
  String get hospital_label;

  /// No description provided for @hospital_hint.
  ///
  /// In en, this message translates to:
  /// **'Select hospital'**
  String get hospital_hint;

  /// No description provided for @upload_id_card.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Card / Passport'**
  String get upload_id_card;

  /// No description provided for @upload_medical_cert.
  ///
  /// In en, this message translates to:
  /// **'Upload Medical Certificate'**
  String get upload_medical_cert;

  /// No description provided for @agree_terms.
  ///
  /// In en, this message translates to:
  /// **'I have read and fully agree to the Terms of Use'**
  String get agree_terms;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms_and_conditions;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @create_account_button.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_button;

  /// No description provided for @role_patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get role_patient;

  /// No description provided for @role_doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get role_doctor;

  /// No description provided for @must_accept_terms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get must_accept_terms;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalid_email;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required_field;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get home_welcome;

  /// No description provided for @map_title.
  ///
  /// In en, this message translates to:
  /// **'Clinic Map'**
  String get map_title;

  /// No description provided for @notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_title;

  /// No description provided for @chatbot_title.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get chatbot_title;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get error_network;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @language_vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get language_vietnamese;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get language_chinese;

  /// No description provided for @language_japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get language_japanese;

  /// No description provided for @language_korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get language_korean;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your account using your phone number'**
  String get register_subtitle;

  /// No description provided for @terms_agreement_text.
  ///
  /// In en, this message translates to:
  /// **'By registering, I have read and agree to the Terms of Use'**
  String get terms_agreement_text;

  /// No description provided for @otp_title.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otp_title;

  /// No description provided for @otp_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP code'**
  String get otp_hint;

  /// No description provided for @create_password_title.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get create_password_title;

  /// No description provided for @registration_success.
  ///
  /// In en, this message translates to:
  /// **'Account registered successfully!'**
  String get registration_success;

  /// No description provided for @invalid_otp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code, please try again'**
  String get invalid_otp;

  /// No description provided for @password_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, including uppercase, lowercase and numbers'**
  String get password_validation_error;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get nav_schedule;

  /// No description provided for @nav_medical_record.
  ///
  /// In en, this message translates to:
  /// **'Medical records'**
  String get nav_medical_record;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @admin_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get admin_dashboard_title;

  /// No description provided for @admin_manage_hospital.
  ///
  /// In en, this message translates to:
  /// **'Manage hospitals'**
  String get admin_manage_hospital;

  /// No description provided for @admin_manage_department.
  ///
  /// In en, this message translates to:
  /// **'Manage departments'**
  String get admin_manage_department;

  /// No description provided for @admin_manage_doctor.
  ///
  /// In en, this message translates to:
  /// **'Manage doctors'**
  String get admin_manage_doctor;

  /// No description provided for @doctor_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctor_dashboard_title;

  /// No description provided for @doctor_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello doctor'**
  String get doctor_greeting;

  /// No description provided for @doctor_today_stats.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary'**
  String get doctor_today_stats;

  /// No description provided for @doctor_patients_today.
  ///
  /// In en, this message translates to:
  /// **'Patients today'**
  String get doctor_patients_today;

  /// No description provided for @doctor_appointments_today.
  ///
  /// In en, this message translates to:
  /// **'Appointments today'**
  String get doctor_appointments_today;

  /// No description provided for @doctor_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get doctor_waiting;

  /// No description provided for @doctor_quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get doctor_quick_actions;

  /// No description provided for @doctor_today_schedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get doctor_today_schedule;

  /// No description provided for @doctor_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get doctor_view_all;

  /// No description provided for @doctor_no_appointments_today.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get doctor_no_appointments_today;

  /// No description provided for @doctor_medical_record.
  ///
  /// In en, this message translates to:
  /// **'Medical record'**
  String get doctor_medical_record;

  /// No description provided for @doctor_diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get doctor_diagnosis;

  /// No description provided for @doctor_prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get doctor_prescription;

  /// No description provided for @doctor_sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get doctor_sign;

  /// No description provided for @doctor_send_prescription.
  ///
  /// In en, this message translates to:
  /// **'Send prescription'**
  String get doctor_send_prescription;

  /// No description provided for @doctor_upload_results.
  ///
  /// In en, this message translates to:
  /// **'Upload results'**
  String get doctor_upload_results;

  /// No description provided for @doctor_advanced_features.
  ///
  /// In en, this message translates to:
  /// **'Advanced features'**
  String get doctor_advanced_features;

  /// No description provided for @doctor_ai_support.
  ///
  /// In en, this message translates to:
  /// **'AI diagnosis assistant'**
  String get doctor_ai_support;

  /// No description provided for @doctor_patient_rating.
  ///
  /// In en, this message translates to:
  /// **'Patient rating'**
  String get doctor_patient_rating;

  /// No description provided for @doctor_dashboard_analytics.
  ///
  /// In en, this message translates to:
  /// **'Dashboard analytics'**
  String get doctor_dashboard_analytics;

  /// No description provided for @doctor_time_management.
  ///
  /// In en, this message translates to:
  /// **'Time management'**
  String get doctor_time_management;

  /// No description provided for @doctor_workload_management.
  ///
  /// In en, this message translates to:
  /// **'Workload management'**
  String get doctor_workload_management;

  /// No description provided for @doctor_daily_limit.
  ///
  /// In en, this message translates to:
  /// **'Patients/day limit'**
  String get doctor_daily_limit;

  /// No description provided for @doctor_break_time.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get doctor_break_time;

  /// No description provided for @doctor_schedule_allocation.
  ///
  /// In en, this message translates to:
  /// **'Schedule allocation'**
  String get doctor_schedule_allocation;

  /// No description provided for @doctor_button_examine.
  ///
  /// In en, this message translates to:
  /// **'Examine'**
  String get doctor_button_examine;

  /// No description provided for @patient_header_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi,'**
  String get patient_header_greeting;

  /// No description provided for @patient_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search facilities/doctors/departments/services'**
  String get patient_search_hint;

  /// No description provided for @patient_section_facilities.
  ///
  /// In en, this message translates to:
  /// **'FACILITIES'**
  String get patient_section_facilities;

  /// No description provided for @patient_section_facilities_sub.
  ///
  /// In en, this message translates to:
  /// **'featured this month'**
  String get patient_section_facilities_sub;

  /// No description provided for @patient_section_doctors.
  ///
  /// In en, this message translates to:
  /// **'CONSULTING DOCTORS'**
  String get patient_section_doctors;

  /// No description provided for @patient_section_doctors_sub.
  ///
  /// In en, this message translates to:
  /// **'video consultation'**
  String get patient_section_doctors_sub;

  /// No description provided for @patient_section_care.
  ///
  /// In en, this message translates to:
  /// **'CARE'**
  String get patient_section_care;

  /// No description provided for @patient_section_care_sub.
  ///
  /// In en, this message translates to:
  /// **'wellness programs'**
  String get patient_section_care_sub;

  /// No description provided for @patient_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all  >>'**
  String get patient_view_all;

  /// No description provided for @patient_book_now.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get patient_book_now;

  /// No description provided for @patient_tab_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get patient_tab_health;

  /// No description provided for @patient_tab_test.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get patient_tab_test;

  /// No description provided for @patient_tab_vaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get patient_tab_vaccine;

  /// No description provided for @patient_banner_online_consult.
  ///
  /// In en, this message translates to:
  /// **'Online\nconsultation'**
  String get patient_banner_online_consult;

  /// No description provided for @patient_banner_personal_assistant.
  ///
  /// In en, this message translates to:
  /// **'Personal\nassistant'**
  String get patient_banner_personal_assistant;

  /// No description provided for @patient_action_book_facility.
  ///
  /// In en, this message translates to:
  /// **'Book at\nfacility'**
  String get patient_action_book_facility;

  /// No description provided for @patient_action_book_specialty.
  ///
  /// In en, this message translates to:
  /// **'Book by\nspecialty'**
  String get patient_action_book_specialty;

  /// No description provided for @patient_action_book_test.
  ///
  /// In en, this message translates to:
  /// **'Book a\ntest'**
  String get patient_action_book_test;

  /// No description provided for @patient_action_health_package.
  ///
  /// In en, this message translates to:
  /// **'Health\npackage'**
  String get patient_action_health_package;

  /// No description provided for @patient_action_personal_assistant.
  ///
  /// In en, this message translates to:
  /// **'Personal\nassistant'**
  String get patient_action_personal_assistant;

  /// No description provided for @patient_action_video_call.
  ///
  /// In en, this message translates to:
  /// **'Video call\nwith doctor'**
  String get patient_action_video_call;

  /// No description provided for @patient_action_buy_medicine.
  ///
  /// In en, this message translates to:
  /// **'Buy\nmedicine'**
  String get patient_action_buy_medicine;

  /// No description provided for @patient_action_corporate_checkup.
  ///
  /// In en, this message translates to:
  /// **'Corporate\ncheckup'**
  String get patient_action_corporate_checkup;

  /// No description provided for @doctor_morning.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get doctor_morning;

  /// No description provided for @doctor_workload_limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get doctor_workload_limit;

  /// No description provided for @doctor_workload_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doctor_workload_done;

  /// No description provided for @doctor_workload_break.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get doctor_workload_break;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
