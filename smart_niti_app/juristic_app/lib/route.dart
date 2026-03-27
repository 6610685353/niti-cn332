import 'package:flutter/material.dart';
import 'package:juristic_app/features/auth/login/views/login_page.dart';
import 'package:juristic_app/features/dashboard/views/dashboard_page.dart';
import 'package:juristic_app/features/home/view/home_page.dart';
import 'package:juristic_app/features/task_dispatch/view/task_dispatch_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String task_dispatch = '/task-dispatch';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    task_dispatch: (context) => const TaskDispatchPage(),
  };
}
