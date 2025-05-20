import 'package:get/get.dart';
import 'package:senjayer/app/modules/auth/views/forgot_pass_view.dart';
import 'package:senjayer/app/modules/auth/views/login_view.dart';
import 'package:senjayer/app/modules/auth/views/pass_reset_otp_view.dart';
import 'package:senjayer/app/modules/auth/views/pass_reset_success_view.dart';
import 'package:senjayer/app/modules/auth/views/pass_reset_view.dart';
import 'package:senjayer/app/modules/auth/views/signup_view.dart';
import 'package:senjayer/app/modules/carte/views/cart_view.dart';
import 'package:senjayer/app/modules/contactInvite/views/InviterContactPage.dart';
import 'package:senjayer/app/modules/dashboard/views/dashboard_view.dart';
import 'package:senjayer/app/modules/events/views/create_event_view.dart';
import 'package:senjayer/app/modules/events/views/event_details_view.dart';
import 'package:senjayer/app/modules/events/views/events_view.dart';
import 'package:senjayer/app/modules/invitations/views/invitation_details.dart';
import 'package:senjayer/app/modules/invitations/views/invitation_view.dart';
import 'package:senjayer/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:senjayer/app/modules/onboarding/views/onboarding_view.dart';
import 'package:senjayer/app/modules/packagePurchase/views/package_selection_page.dart';
import 'package:senjayer/app/modules/search/views/searchPage.dart';
import 'package:senjayer/app/modules/splash/view/splash_view.dart';
import 'package:senjayer/app/modules/success_reg/views/success_reg_view.dart';
import 'package:senjayer/app/modules/welcome_page/views/welcome_page_view.dart';
import 'package:senjayer/app/routes/app_routes.dart';
import '../modules/packagePurchase/views/package_payment_page.dart';
import '../modules/profile/bindings/edit_profile_binding.dart';
import '../modules/profile/views/about_page.dart';
import '../modules/profile/views/delete_account_page.dart';
import '../modules/profile/views/edit_profile_page.dart';
import '../modules/profile/views/faq_page.dart';
import '../modules/profile/views/notifications_page.dart';
import '../modules/profile/views/parametres_page.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),

    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupView(),
      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.SUCCESS_REG,
      page: () => SuccessRegView(),
      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: AppRoutes.PASS_RESET,
      page: () => PassResetView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASS,
      page: () => ForgotPassView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: AppRoutes.PASS_OTP,
      page: () => PassResetOtpView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.RESET_PASS_SUCCESS,
      page: () => PassResetSuccessView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.WELCOME_PAGE,
      page: () => WelcomePageView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.INVITATIONS,
      page: () => InvitationView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.INVITATION_DETAILS,
      page: () => InvitationDetails(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.INVITATION_DETAIL_CARTE,
      page: () => CartView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.USER_EVENTS,
      page: () => EventsView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.USER_EVENTS_details,
      page: () => EventDetailsView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    
    //USER_EVENTS_INVITECONTACT
    GetPage(
      name: AppRoutes.USER_EVENTS_INVITECONTACT,
      page: () => InviterContactsPage(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.USER_CONTACT_LIST,
      page: () => InviterContactsPage(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),
    
    GetPage(
      name: AppRoutes.USER_EVENTS_CREATE,
      page: () => CreateEventView(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),


    GetPage(
      name: AppRoutes.USER_EVENTS_PACKS_PAYMENT,
      page: () => PaymentPage(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.USER_SEARCH_PAGE,
      page: () => SearchPage(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.USER_EVENTS_PACKS,
      page: () => PackageSelectionPage(),

      // binding: HomeBinding(),
      transition: Transition.cupertino, // Smooth fade-in transition
      transitionDuration: Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.PARAMETRES,
      page: () => ParametresPage(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfilePage(),
      binding: EditProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => NotificationsPage(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.FAQ,
      page: () => FAQPage(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => AboutPage(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.DELETE_ACCOUNT,
      page: () => DeleteAccountPage(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),
  ];
}
