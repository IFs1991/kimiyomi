import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeKey = 'app_theme';
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _fontFamilyKey = 'font_family';
  static const String _themeModeKey = 'theme_mode';

  // デフォルトのテーマ設定
  static const defaultPrimaryColor = Colors.blue;
  static const defaultAccentColor = Colors.amber;
  static const defaultFontFamily = 'Noto Sans JP';
  static const defaultThemeMode = ThemeMode.system;

  // カラーパレット
  static const Map<String, Color> colorPalette = {
    'blue': Colors.blue,
    'indigo': Colors.indigo,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'red': Colors.red,
    'orange': Colors.orange,
    'amber': Colors.amber,
    'yellow': Colors.yellow,
    'lime': Colors.lime,
    'green': Colors.green,
    'teal': Colors.teal,
    'cyan': Colors.cyan,
  };

  // フォントファミリー
  static const List<String> availableFontFamilies = [
    'Noto Sans JP',
    'Roboto',
    'Montserrat',
    'Open Sans',
    'Lato',
  ];

  // テーマの取得
  static Future<ThemeData> getTheme({bool isDark = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorValue = prefs.getInt(_primaryColorKey) ?? defaultPrimaryColor.value;
    final accentColorValue = prefs.getInt(_accentColorKey) ?? defaultAccentColor.value;
    final fontFamily = prefs.getString(_fontFamilyKey) ?? defaultFontFamily;

    final primaryColor = Color(primaryColorValue);
    final accentColor = Color(accentColorValue);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      fontFamily: fontFamily,
      // テキストテーマ
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontFamily: fontFamily,
        ),
      ),
      // ボタンテーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // カードテーマ
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      // 入力フィールドテーマ
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  // テーマモードの取得
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? defaultThemeMode.index;
    return ThemeMode.values[themeModeIndex];
  }

  // プライマリカラーの設定
  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }

  // アクセントカラーの設定
  static Future<void> setAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  // フォントファミリーの設定
  static Future<void> setFontFamily(String fontFamily) async {
    if (!availableFontFamilies.contains(fontFamily)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, fontFamily);
  }

  // テーマモードの設定
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  // テーマのリセット
  static Future<void> resetTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_accentColorKey);
    await prefs.remove(_fontFamilyKey);
    await prefs.remove(_themeModeKey);
  }

  // カスタムテーマの保存
  static Future<void> saveCustomTheme(String themeName, Map<String, dynamic> themeData) async {
    final prefs = await SharedPreferences.getInstance();
    final customThemes = prefs.getStringList('custom_themes') ?? [];
    if (!customThemes.contains(themeName)) {
      customThemes.add(themeName);
      await prefs.setStringList('custom_themes', customThemes);
    }
    await prefs.setString('theme_$themeName', themeData.toString());
  }

  // カスタムテーマの読み込み
  static Future<Map<String, dynamic>?> loadCustomTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_$themeName');
    if (themeString == null) return null;

    // 文字列から Map に変換する処理を実装
    return {};
  }

  // カスタムテーマの削除
  static Future<void> deleteCustomTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    final customThemes = prefs.getStringList('custom_themes') ?? [];
    customThemes.remove(themeName);
    await prefs.setStringList('custom_themes', customThemes);
    await prefs.remove('theme_$themeName');
  }

  // カスタムテーマ一覧の取得
  static Future<List<String>> getCustomThemes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('custom_themes') ?? [];
  }
}