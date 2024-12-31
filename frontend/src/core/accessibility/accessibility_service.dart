import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:logging/logging.dart';

class AccessibilityService {
  static final Logger _logger = Logger('AccessibilityService');
  static final FlutterTts _tts = FlutterTts();
  static final SpeechToText _stt = SpeechToText();

  // 設定キー
  static const String _fontScaleKey = 'font_scale';
  static const String _highContrastKey = 'high_contrast';
  static const String _screenReaderKey = 'screen_reader';
  static const String _reduceMotionKey = 'reduce_motion';
  static const String _keyboardNavigationKey = 'keyboard_navigation';

  // 初期化
  static Future<void> initialize() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(1.0);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    await _stt.initialize(
      onError: (error) => _logger.warning('音声認識エラー: $error'),
      onStatus: (status) => _logger.info('音声認識ステータス: $status'),
    );

    await _loadSettings();
  }

  // 設定の読み込み
  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _screenReader = prefs.getBool(_screenReaderKey) ?? false;
    _reduceMotion = prefs.getBool(_reduceMotionKey) ?? false;
    _keyboardNavigation = prefs.getBool(_keyboardNavigationKey) ?? false;
  }

  // フォントスケールの設定
  static Future<void> setFontScale(double scale) async {
    if (scale < 0.8 || scale > 2.0) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
    _fontScale = scale;
  }

  // ハイコントラストモードの設定
  static Future<void> setHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
    _highContrast = enabled;
  }

  // スクリーンリーダーの設定
  static Future<void> setScreenReader(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenReaderKey, enabled);
    _screenReader = enabled;

    if (enabled) {
      await _tts.setLanguage('ja-JP');
    } else {
      await _tts.stop();
    }
  }

  // モーション低減の設定
  static Future<void> setReduceMotion(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reduceMotionKey, enabled);
    _reduceMotion = enabled;
  }

  // キーボード操作の設定
  static Future<void> setKeyboardNavigation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyboardNavigationKey, enabled);
    _keyboardNavigation = enabled;
  }

  // テキストの読み上げ
  static Future<void> speak(String text) async {
    if (!_screenReader) return;
    await _tts.speak(text);
  }

  // 読み上げの停止
  static Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // 音声入力の開始
  static Future<void> startListening({
    required Function(String) onResult,
    required Function() onComplete,
  }) async {
    if (!await _stt.initialize()) return;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onComplete();
        }
      },
      localeId: 'ja_JP',
    );
  }

  // 音声入力の停止
  static Future<void> stopListening() async {
    await _stt.stop();
  }

  // キーボードショートカットの登録
  static void registerShortcut({
    required SingleActivator shortcut,
    required Function() onInvoke,
  }) {
    if (!_keyboardNavigation) return;

    ServicesBinding.instance.keyboard.addHandler((event) {
      if (event is KeyDownEvent) {
        if (shortcut.accepts(event, HardwareKeyboard.instance)) {
          onInvoke();
          return true;
        }
      }
      return false;
    });
  }

  // アクセシビリティツリーの構築
  static Widget buildSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  // ハイコントラストカラーの取得
  static Color getHighContrastColor(Color color) {
    if (!_highContrast) return color;

    final luminance = color.computeLuminance();
    if (luminance > 0.5) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  // アニメーション期間の取得
  static Duration getAnimationDuration(Duration normal) {
    if (_reduceMotion) {
      return Duration.zero;
    }
    return normal;
  }

  // フォントスケールの取得
  static double getFontScale() => _fontScale;

  // ハイコントラストモードの状態
  static bool isHighContrastEnabled() => _highContrast;

  // スクリーンリーダーの状態
  static bool isScreenReaderEnabled() => _screenReader;

  // モーション低減の状態
  static bool isReduceMotionEnabled() => _reduceMotion;

  // キーボード操作の状態
  static bool isKeyboardNavigationEnabled() => _keyboardNavigation;

  // 設定値の保持用の静的変数
  static double _fontScale = 1.0;
  static bool _highContrast = false;
  static bool _screenReader = false;
  static bool _reduceMotion = false;
  static bool _keyboardNavigation = false;
}