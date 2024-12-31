import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  static const _tutorialPages = [
    {
      'title': 'キミヨミへようこそ',
      'description': 'AIを活用した性格診断・マッチングアプリで、あなたにぴったりの出会いを見つけましょう。',
      'image': 'assets/images/tutorial/welcome.png',
    },
    {
      'title': '性格診断',
      'description': '最新のAI技術を使用して、あなたの性格を詳しく分析します。',
      'image': 'assets/images/tutorial/diagnosis.png',
    },
    {
      'title': 'マッチング',
      'description': '性格診断の結果をもとに、相性の良いユーザーを見つけることができます。',
      'image': 'assets/images/tutorial/matching.png',
    },
    {
      'title': 'コミュニケーション',
      'description': 'マッチングしたユーザーとメッセージを交換して、お互いのことをより深く知ることができます。',
      'image': 'assets/images/tutorial/chat.png',
    },
    {
      'title': 'さあ、始めましょう',
      'description': 'プロフィールを作成して、新しい出会いを見つけましょう。',
      'image': 'assets/images/tutorial/start.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      setState(() {
        _currentPage = page;
        _isLastPage = page == _tutorialPages.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeTutorial();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.2),
                ],
              ),
            ),
          ),
          // チュートリアルコンテンツ
          SafeArea(
            child: Column(
              children: [
                // スキップボタン
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _skipTutorial,
                      child: const Text('スキップ'),
                    ),
                  ),
                ),
                // ページビュー
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _tutorialPages.length,
                    itemBuilder: (context, index) {
                      final page = _tutorialPages[index];
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // イラスト
                            Expanded(
                              child: Image.asset(
                                page['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // タイトル
                            Text(
                              page['title']!,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // 説明文
                            Text(
                              page['description']!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // インジケーターとボタン
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ページインジケーター
                      Row(
                        children: List.generate(
                          _tutorialPages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // 次へボタン
                      ElevatedButton(
                        onPressed: _nextPage,
                        child: Text(_isLastPage ? '始める' : '次へ'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}