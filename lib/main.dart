import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  // 注意: firebase_options.dartが必要です
  // `flutterfire configure`コマンドで生成してください
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase設定が見つからない場合、デモモードで起動
    print('Firebase設定が見つかりません: $e');
    print('`flutterfire configure`コマンドでFirebaseを設定してください');
  }

  runApp(
    const ProviderScope(
      child: PlayPlanApp(),
    ),
  );
}
