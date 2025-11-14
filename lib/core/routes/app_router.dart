import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/groups/create_group_screen.dart';
import '../../screens/groups/group_detail_screen.dart';
import '../../screens/plans/create_plan_screen.dart';
import '../../screens/plans/plan_detail_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case '/create-group':
        return MaterialPageRoute(builder: (_) => const CreateGroupScreen());

      case '/group-detail':
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => GroupDetailScreen(groupId: groupId),
        );

      case '/create-plan':
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CreatePlanScreen(groupId: groupId),
        );

      case '/plan-detail':
        final planId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PlanDetailScreen(planId: planId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('ページが見つかりません: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
