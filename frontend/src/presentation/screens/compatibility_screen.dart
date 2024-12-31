import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/compatibility_provider.dart';
import '../../domain/entities/compatibility_result.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_indicator.dart';

class CompatibilityScreen extends ConsumerStatefulWidget {
  const CompatibilityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends ConsumerState<CompatibilityScreen> {
  final _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(compatibilityProvider.notifier).loadCompatibilityHistory());
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  }

  Future<void> _checkCompatibility() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      _showErrorDialog('ユーザーIDを入力してください');
      return;
    }

    await ref.read(compatibilityProvider.notifier).checkCompatibility(userId);
  }

  Widget _buildResultCard(CompatibilityResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '相性スコア: ${result.compatibilityScore}%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text('相性レベル: ${result.compatibilityLevel}'),
            const SizedBox(height: 8.0),
            Text('分析: ${result.analysis}'),
            const SizedBox(height: 16.0),
            Text(
              '共通点:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...result.commonTraits.map((trait) => Text('• $trait')),
            const SizedBox(height: 8.0),
            Text(
              '相違点:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...result.differences.map((diff) => Text('• $diff')),
            const SizedBox(height: 16.0),
            Text(
              'アドバイス:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(result.advice),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ref.read(compatibilityProvider.notifier).shareResult(result.id),
                  child: const Text('共有'),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () => ref.read(compatibilityProvider.notifier).deleteResult(result.id),
                  child: const Text('削除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compatibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('相性診断'),
      ),
      body: state.isLoading
          ? const LoadingIndicator()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: '相手のユーザーID',
                            hintText: 'ユーザーIDを入力',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: _checkCompatibility,
                        child: const Text('診断する'),
                      ),
                    ],
                  ),
                ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) => _buildResultCard(state.results[index]),
                  ),
                ),
              ],
            ),
    );
  }
}