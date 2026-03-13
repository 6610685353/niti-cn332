import 'package:juristic_app/features/auth/login/views/login_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';

  static final routes = {
    login: (context) => const LoginPage(),
    // home:(context) => const HomePage(),
  };
}
