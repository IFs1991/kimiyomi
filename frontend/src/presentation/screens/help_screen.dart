import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _helpSections = [
    {
      'title': '基本的な使い方',
      'items': [
        {
          'title': 'プロフィールの作成',
          'description': 'プロフィール写真、自己紹介、興味・関心などを設定して、あなたらしさを表現しましょう。',
          'icon': Icons.person,
        },
        {
          'title': '性格診断の受診',
          'description': 'AIを活用した性格診断で、あなたの性格を分析します。診断結果は定期的に更新することをお勧めします。',
          'icon': Icons.psychology,
        },
        {
          'title': 'マッチング',
          'description': '性格診断の結果をもとに、相性の良いユーザーが表示されます。興味のあるユーザーにいいねを送りましょう。',
          'icon': Icons.favorite,
        },
        {
          'title': 'メッセージ',
          'description': 'マッチングが成立したら、メッセージを送って交流を始めることができます。',
          'icon': Icons.chat,
        },
      ],
    },
    {
      'title': 'プライバシーとセキュリティ',
      'items': [
        {
          'title': 'プライバシー設定',
          'description': 'プロフィールの公開範囲や、通知の設定をカスタマイズできます。',
          'icon': Icons.security,
        },
        {
          'title': 'ブロックと報告',
          'description': '不適切なユーザーをブロックしたり、違反行為を報告することができます。',
          'icon': Icons.block,
        },
        {
          'title': '二段階認証',
          'description': 'アカウントのセキュリティを強化するために、二段階認証の設定をお勧めします。',
          'icon': Icons.verified_user,
        },
      ],
    },
    {
      'title': 'アカウント管理',
      'items': [
        {
          'title': 'アカウント情報の変更',
          'description': 'メールアドレスやパスワードの変更、アカウントの削除などができます。',
          'icon': Icons.manage_accounts,
        },
        {
          'title': '通知設定',
          'description': 'プッシュ通知やメール通知の設定をカスタマイズできます。',
          'icon': Icons.notifications,
        },
        {
          'title': 'データのバックアップ',
          'description': 'プロフィールデータや会話履歴をバックアップすることができます。',
          'icon': Icons.backup,
        },
      ],
    },
  ];

  Future<void> _openFAQ() async {
    const url = 'https://kimiyomi.app/faq';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openSupport() async {
    const url = 'https://kimiyomi.app/support';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://kimiyomi.app/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openTerms() async {
    const url = 'https://kimiyomi.app/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ・ガイド'),
      ),
      body: ListView(
        children: [
          // ヘルプセクション
          ..._helpSections.map((section) => _buildSection(context, section)),

          // その他のリンク
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('よくある質問'),
            onTap: _openFAQ,
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('サポート'),
            onTap: _openSupport,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('プライバシーポリシー'),
            onTap: _openPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('利用規約'),
            onTap: _openTerms,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            section['title'],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...section['items'].map<Widget>((item) => _buildHelpItem(item)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildHelpItem(Map<String, dynamic> item) {
    return ExpansionTile(
      leading: Icon(item['icon'] as IconData),
      title: Text(item['title']),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(item['description']),
        ),
      ],
    );
  }
}