import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/course/course_list_screen.dart';
import '../screens/course/course_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/courses',
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (u) => u != null,
        loading: () => false,
        error: (_, __) => false,
      );
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/courses';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/courses',
            name: 'courses',
            builder: (context, state) => const CourseListScreen(),
          ),
          GoRoute(
            path: '/courses/:courseId',
            name: 'courseDetail',
            builder: (context, state) => CourseDetailScreen(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
          GoRoute(
            path: '/mypage',
            name: 'mypage',
            builder: (context, state) => const MypageScreen(),
          ),
        ],
      ),
    ],
  );
});

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('マイページ',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('ブックマークや学習履歴がここに表示されます'),
          ],
        ),
      ),
    );
  }
}