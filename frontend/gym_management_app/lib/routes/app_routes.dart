import 'package:get/get.dart';
import '../views/auth/login_screen.dart';
import '../views/home/home_screen.dart';
import '../views/members/member_list_screen.dart';
import '../views/members/member_form_screen.dart';
import '../views/membership/subscription_screen.dart';
import '../views/attendance/attendance_screen.dart';
import '../views/pos/pos_screen.dart';
import '../views/reports/report_screen.dart';
import '../views/settings/settings_screen.dart';
import '../controllers/auth_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String memberList = '/members';
  static const String memberForm = '/members/form';
  static const String subscription = '/subscription';
  static const String attendance = '/attendance';
  static const String pos = '/pos';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberList,
      page: () => const MemberListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberForm,
      page: () => const MemberFormScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: subscription,
      page: () => const SubscriptionScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: attendance,
      page: () => const AttendanceScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: pos,
      page: () => const PosScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: reports,
      page: () => const ReportScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
