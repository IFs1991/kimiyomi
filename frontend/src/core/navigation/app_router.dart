import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_router.g.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // 認証関連
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // プロフィール
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // 診断関連
      GoRoute(
        path: '/diagnosis',
        builder: (context, state) => const DiagnosisScreen(),
      ),
      GoRoute(
        path: '/diagnosis/result',
        builder: (context, state) => const DiagnosisResultScreen(),
      ),
      // 相性診断
      GoRoute(
        path: '/compatibility',
        builder: (context, state) => const CompatibilityScreen(),
      ),
      GoRoute(
        path: '/compatibility/result',
        builder: (context, state) => const CompatibilityResultScreen(),
      ),
      // コンテンツ
      GoRoute(
        path: '/content/:id',
        builder: (context, state) => ContentDetailScreen(
          contentId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});