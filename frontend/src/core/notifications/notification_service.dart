import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // 通知設定の保存用キー
  static const String _soundSettingKey = 'notification_sound';
  static const String _vibrationSettingKey = 'vibration_pattern';
  static const String _groupSettingKey = 'notification_group';
  static const String _prioritySettingKey = 'notification_priority';
  static const String _retentionDaysKey = 'notification_retention_days';

  // 通知音のプリセット
  static const Map<String, String> notificationSounds = {
    'default': 'notification_default.mp3',
    'chime': 'notification_chime.mp3',
    'bell': 'notification_bell.mp3',
    'melody': 'notification_melody.mp3',
  };

  // バイブレーションパターンのプリセット
  static const Map<String, List<int>> vibrationPatterns = {
    'default': [0, 100, 100, 100],
    'double': [0, 100, 100, 100, 100, 100],
    'long': [0, 500],
    'gentle': [0, 50, 50, 50],
  };

  // 初期化
  static Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(initializationSettings);
    await _loadSettings();
  }

  // 設定の読み込み
  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSound = prefs.getString(_soundSettingKey) ?? 'default';
    _currentVibration = prefs.getString(_vibrationSettingKey) ?? 'default';
    _groupEnabled = prefs.getBool(_groupSettingKey) ?? true;
    _priority = prefs.getInt(_prioritySettingKey) ?? 0;
    _retentionDays = prefs.getInt(_retentionDaysKey) ?? 30;
  }

  // 通知音の設定
  static Future<void> setNotificationSound(String soundName) async {
    if (!notificationSounds.containsKey(soundName)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundSettingKey, soundName);
    _currentSound = soundName;
  }

  // バイブレーションパターンの設定
  static Future<void> setVibrationPattern(String patternName) async {
    if (!vibrationPatterns.containsKey(patternName)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vibrationSettingKey, patternName);
    _currentVibration = patternName;
  }

  // 通知のグループ化設定
  static Future<void> setGrouping(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_groupSettingKey, enabled);
    _groupEnabled = enabled;
  }

  // 通知の優先度設定
  static Future<void> setPriority(int priority) async {
    if (priority < 0 || priority > 5) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prioritySettingKey, priority);
    _priority = priority;
  }

  // 通知の保存期間設定
  static Future<void> setRetentionDays(int days) async {
    if (days < 1 || days > 365) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_retentionDaysKey, days);
    _retentionDays = days;
  }

  // 通知の送信
  static Future<void> showNotification({
    required String title,
    required String body,
    String? groupKey,
    Map<String, dynamic>? payload,
  }) async {
    // 通知音の再生
    if (_currentSound != 'none') {
      await _audioPlayer.play(AssetSource(notificationSounds[_currentSound]!));
    }

    // バイブレーション
    if (_currentVibration != 'none') {
      final pattern = vibrationPatterns[_currentVibration]!;
      await Vibration.vibrate(pattern: pattern);
    }

    // 通知の構築
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Default notification channel',
        importance: Importance.values[_priority],
        priority: Priority.values[_priority],
        groupKey: _groupEnabled ? (groupKey ?? 'default_group') : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // 通知の送信
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload != null ? Uri.encodeFull(payload.toString()) : null,
    );

    // 古い通知の削除
    await _cleanOldNotifications();
  }

  // 古い通知の削除
  static Future<void> _cleanOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: _retentionDays));
    // ここで古い通知を削除する処理を実装
  }

  // 通知履歴の取得
  static Future<List<NotificationEvent>> getNotificationHistory() async {
    // 通知履歴を取得する処理を実装
    return [];
  }

  // 通知のグループ化
  static Future<void> groupNotifications(List<NotificationEvent> notifications) async {
    if (!_groupEnabled) return;

    // 通知のグループ化処理を実装
  }

  // 設定値の保持用の静的変数
  static String _currentSound = 'default';
  static String _currentVibration = 'default';
  static bool _groupEnabled = true;
  static int _priority = 0;
  static int _retentionDays = 30;
}

// 通知イベントのモデルクラス
class NotificationEvent {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;
  final String? groupKey;

  NotificationEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.payload,
    this.groupKey,
  });
}