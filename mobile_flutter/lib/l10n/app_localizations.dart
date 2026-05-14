import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @residenceRules.
  ///
  /// In en, this message translates to:
  /// **'Residence Rules'**
  String get residenceRules;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsPrivacy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get unableToLoadProfile;

  /// No description provided for @tryAgainOrSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please try again or sign in again.'**
  String get tryAgainOrSignIn;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'UNIT'**
  String get unit;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get phone;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @resident.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get resident;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @logOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutQuestion;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your account.'**
  String get logOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Residence App v1.0.0'**
  String get appVersion;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @submitTrackRequests.
  ///
  /// In en, this message translates to:
  /// **'Submit & track your requests'**
  String get submitTrackRequests;

  /// No description provided for @maintenanceRequest.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Request'**
  String get maintenanceRequest;

  /// No description provided for @reportIssueRepair.
  ///
  /// In en, this message translates to:
  /// **'Report an issue or request a repair.'**
  String get reportIssueRepair;

  /// No description provided for @visitorPass.
  ///
  /// In en, this message translates to:
  /// **'Visitor Pass'**
  String get visitorPass;

  /// No description provided for @registerVisitor.
  ///
  /// In en, this message translates to:
  /// **'Register a visitor.'**
  String get registerVisitor;

  /// No description provided for @bookSharedArea.
  ///
  /// In en, this message translates to:
  /// **'Book Shared Area'**
  String get bookSharedArea;

  /// No description provided for @reserveSharedSpaces.
  ///
  /// In en, this message translates to:
  /// **'Reserve shared spaces.'**
  String get reserveSharedSpaces;

  /// No description provided for @parkingLot.
  ///
  /// In en, this message translates to:
  /// **'Parking Lot'**
  String get parkingLot;

  /// No description provided for @checkParkingSpots.
  ///
  /// In en, this message translates to:
  /// **'Check parking spots.'**
  String get checkParkingSpots;

  /// No description provided for @activityOverview.
  ///
  /// In en, this message translates to:
  /// **'Activity Overview'**
  String get activityOverview;

  /// No description provided for @visitorPasses.
  ///
  /// In en, this message translates to:
  /// **'Visitor Passes'**
  String get visitorPasses;

  /// No description provided for @noVisitorRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No visitor requests yet'**
  String get noVisitorRequestsYet;

  /// No description provided for @sharedAreaBookings.
  ///
  /// In en, this message translates to:
  /// **'Shared Area Bookings'**
  String get sharedAreaBookings;

  /// No description provided for @noSharedAreaBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No shared area bookings yet'**
  String get noSharedAreaBookingsYet;

  /// No description provided for @openRequests.
  ///
  /// In en, this message translates to:
  /// **'Open Requests'**
  String get openRequests;

  /// No description provided for @noOpenMaintenanceRequests.
  ///
  /// In en, this message translates to:
  /// **'No open maintenance requests'**
  String get noOpenMaintenanceRequests;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @addAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addAnnouncement;

  /// No description provided for @yourDayAtGlance.
  ///
  /// In en, this message translates to:
  /// **'Your Day at a Glance'**
  String get yourDayAtGlance;

  /// No description provided for @unableLoadAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Unable to load announcements.'**
  String get unableLoadAnnouncements;

  /// No description provided for @noAnnouncementsYet.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncementsYet;

  /// No description provided for @firstResidentAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Be the first resident to share an update with the community.'**
  String get firstResidentAnnouncement;

  /// No description provided for @announcementPosted.
  ///
  /// In en, this message translates to:
  /// **'Announcement posted successfully.'**
  String get announcementPosted;

  /// No description provided for @announcementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Announcement updated successfully.'**
  String get announcementUpdated;

  /// No description provided for @announcementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Announcement deleted.'**
  String get announcementDeleted;

  /// No description provided for @deleteAnnouncementQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete announcement?'**
  String get deleteAnnouncementQuestion;

  /// No description provided for @deleteAnnouncementMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this announcement.'**
  String get deleteAnnouncementMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @hexaResident.
  ///
  /// In en, this message translates to:
  /// **'HEXA RESIDENT'**
  String get hexaResident;

  /// No description provided for @secureHabitat.
  ///
  /// In en, this message translates to:
  /// **'SECURE HABITAT'**
  String get secureHabitat;

  /// No description provided for @homeSecureClimate.
  ///
  /// In en, this message translates to:
  /// **'Your home is secure\n& climate-controlled.'**
  String get homeSecureClimate;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts'**
  String get noAlerts;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'FORECAST'**
  String get forecast;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @nextBooking.
  ///
  /// In en, this message translates to:
  /// **'Next booking'**
  String get nextBooking;

  /// No description provided for @gymBookingExample.
  ///
  /// In en, this message translates to:
  /// **'Gym - 18:00'**
  String get gymBookingExample;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Pending request'**
  String get pendingRequest;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @inReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get inReview;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @noActiveRequests.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get noActiveRequests;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get allClear;

  /// No description provided for @nextVisitor.
  ///
  /// In en, this message translates to:
  /// **'Next visitor'**
  String get nextVisitor;

  /// No description provided for @visitorExample.
  ///
  /// In en, this message translates to:
  /// **'Kami benamouna. - 15:00'**
  String get visitorExample;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @editAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Edit announcement'**
  String get editAnnouncement;

  /// No description provided for @newAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New announcement'**
  String get newAnnouncement;

  /// No description provided for @updateMessageResidents.
  ///
  /// In en, this message translates to:
  /// **'Update your message for all residents'**
  String get updateMessageResidents;

  /// No description provided for @shareWithResidents.
  ///
  /// In en, this message translates to:
  /// **'Share something with all residents'**
  String get shareWithResidents;

  /// No description provided for @writeAnnouncementHint.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement here...'**
  String get writeAnnouncementHint;

  /// No description provided for @pinnedAnnouncementInfo.
  ///
  /// In en, this message translates to:
  /// **'This announcement is pinned. Its pinned status is kept here.'**
  String get pinnedAnnouncementInfo;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @postAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Post announcement'**
  String get postAnnouncement;

  /// No description provided for @incidentReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully.'**
  String get incidentReportedSuccessfully;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'connecting...'**
  String get connecting;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get startTheConversation;

  /// No description provided for @beFirstToSayHello.
  ///
  /// In en, this message translates to:
  /// **'Be the first to say hello!'**
  String get beFirstToSayHello;

  /// No description provided for @sayHi.
  ///
  /// In en, this message translates to:
  /// **'Say hi 👋'**
  String get sayHi;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @groupDirectMessages.
  ///
  /// In en, this message translates to:
  /// **'Group & direct messages'**
  String get groupDirectMessages;

  /// No description provided for @residenceChat.
  ///
  /// In en, this message translates to:
  /// **'Residence Chat'**
  String get residenceChat;

  /// No description provided for @groupChatResidents.
  ///
  /// In en, this message translates to:
  /// **'Group chat for all residents'**
  String get groupChatResidents;

  /// No description provided for @directMessages.
  ///
  /// In en, this message translates to:
  /// **'DIRECT MESSAGES'**
  String get directMessages;

  /// No description provided for @residenceChatLoading.
  ///
  /// In en, this message translates to:
  /// **'Residence chat is still loading.'**
  String get residenceChatLoading;

  /// No description provided for @noDirectMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No direct messages yet'**
  String get noDirectMessagesYet;

  /// No description provided for @tapPencilStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Tap the pencil icon to start one'**
  String get tapPencilStartConversation;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @searchByNameOrUnit.
  ///
  /// In en, this message translates to:
  /// **'Search by name or unit…'**
  String get searchByNameOrUnit;

  /// No description provided for @noResidentsFound.
  ///
  /// In en, this message translates to:
  /// **'No residents found'**
  String get noResidentsFound;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Contact Admin'**
  String get contactAdmin;

  /// No description provided for @contactAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you as soon as possible'**
  String get contactAdminSubtitle;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency level'**
  String get urgencyLevel;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Noise complaint, Maintenance issue…'**
  String get subjectHint;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue in detail…'**
  String get messageHint;

  /// No description provided for @sendToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Send to Admin'**
  String get sendToAdmin;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get messageSent;

  /// No description provided for @adminReplySoon.
  ///
  /// In en, this message translates to:
  /// **'The admin will get back to you soon.'**
  String get adminReplySoon;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @fillSubjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill in both subject and message.'**
  String get fillSubjectMessage;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @failedSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request.'**
  String get failedSendRequest;

  /// No description provided for @registerExpectedVisitor.
  ///
  /// In en, this message translates to:
  /// **'Register an expected visitor'**
  String get registerExpectedVisitor;

  /// No description provided for @visitorFullName.
  ///
  /// In en, this message translates to:
  /// **'Visitor Full Name'**
  String get visitorFullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @visitorPhone.
  ///
  /// In en, this message translates to:
  /// **'Visitor Phone'**
  String get visitorPhone;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @visitorEmail.
  ///
  /// In en, this message translates to:
  /// **'Visitor Email'**
  String get visitorEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @personalVisit.
  ///
  /// In en, this message translates to:
  /// **'Personal Visit'**
  String get personalVisit;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @contractorRepair.
  ///
  /// In en, this message translates to:
  /// **'Contractor / Repair'**
  String get contractorRepair;

  /// No description provided for @caregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiver;

  /// No description provided for @movingInOut.
  ///
  /// In en, this message translates to:
  /// **'Moving In/Out'**
  String get movingInOut;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @expectedTimeOfArrival.
  ///
  /// In en, this message translates to:
  /// **'Expected Time of Arrival'**
  String get expectedTimeOfArrival;

  /// No description provided for @selectExpectedArrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Select expected arrival time'**
  String get selectExpectedArrivalTime;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get optionalNote;

  /// No description provided for @selectVisitDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a visit date'**
  String get selectVisitDate;

  /// No description provided for @visitorRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Visitor request sent!'**
  String get visitorRequestSent;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @reserveFacilityBuilding.
  ///
  /// In en, this message translates to:
  /// **'Reserve a facility in your building'**
  String get reserveFacilityBuilding;

  /// No description provided for @yourUnitNumber.
  ///
  /// In en, this message translates to:
  /// **'Your Unit Number'**
  String get yourUnitNumber;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @selectArea.
  ///
  /// In en, this message translates to:
  /// **'Select Area'**
  String get selectArea;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get pool;

  /// No description provided for @rooftop.
  ///
  /// In en, this message translates to:
  /// **'Rooftop'**
  String get rooftop;

  /// No description provided for @bbqArea.
  ///
  /// In en, this message translates to:
  /// **'BBQ Area'**
  String get bbqArea;

  /// No description provided for @meetingRoom.
  ///
  /// In en, this message translates to:
  /// **'Meeting Room'**
  String get meetingRoom;

  /// No description provided for @kidsRoom.
  ///
  /// In en, this message translates to:
  /// **'Kids Room'**
  String get kidsRoom;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get bookingDate;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get timeSlot;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @numberOfGuests.
  ///
  /// In en, this message translates to:
  /// **'Number of Guests'**
  String get numberOfGuests;

  /// No description provided for @validNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validNumberRequired;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @specialRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Any special requirements...'**
  String get specialRequirementsHint;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @selectBookingDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a booking date'**
  String get selectBookingDate;

  /// No description provided for @sessionExpiredLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpiredLoginAgain;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @reportIssueUnit.
  ///
  /// In en, this message translates to:
  /// **'Report an issue in your unit'**
  String get reportIssueUnit;

  /// No description provided for @unitNumber.
  ///
  /// In en, this message translates to:
  /// **'Unit Number'**
  String get unitNumber;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @plumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get plumbing;

  /// No description provided for @electrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeIssueDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue in detail...'**
  String get describeIssueDetail;

  /// No description provided for @provideMoreDetail.
  ///
  /// In en, this message translates to:
  /// **'Please provide more detail'**
  String get provideMoreDetail;

  /// No description provided for @preferredDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Preferred Date (optional)'**
  String get preferredDateOptional;

  /// No description provided for @selectPreferredDate.
  ///
  /// In en, this message translates to:
  /// **'Select a preferred date'**
  String get selectPreferredDate;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @maintenanceRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Maintenance request submitted!'**
  String get maintenanceRequestSubmitted;

  /// No description provided for @failedLoadParkingData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load parking data'**
  String get failedLoadParkingData;

  /// No description provided for @residentParking.
  ///
  /// In en, this message translates to:
  /// **'Resident Parking'**
  String get residentParking;

  /// No description provided for @visitorParking.
  ///
  /// In en, this message translates to:
  /// **'Visitor Parking'**
  String get visitorParking;

  /// No description provided for @yourSpot.
  ///
  /// In en, this message translates to:
  /// **'Your Spot'**
  String get yourSpot;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
