import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/compatibility_result.dart';

class ShareDialog extends StatelessWidget {
  final CompatibilityResult result;

  const ShareDialog({Key? key, required this.result}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('リンクをコピーしました')),
    );
  }

  void _shareResult(BuildContext context) {
    final text = '''
相性診断結果をシェアします！

相性スコア: ${result.compatibilityScore}%
相性レベル: ${result.compatibilityLevel}

${result.analysis}

詳細はこちら: ${result.shareUrl ?? ''}
''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('診断結果を共有'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.shareUrl != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.shareUrl!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context, result.shareUrl!),
                ),
              ],
            ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareButton(
                icon: Icons.share,
                label: '共有',
                onPressed: () => _shareResult(context),
              ),
              _ShareButton(
                icon: Icons.message,
                label: 'メッセージ',
                onPressed: () => Share.share(
                  '相性診断結果: ${result.compatibilityScore}%\n${result.shareUrl ?? ''}',
                  subject: '相性診断結果を共有します',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ShareButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }
}