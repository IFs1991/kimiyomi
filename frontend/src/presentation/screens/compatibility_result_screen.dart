import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/compatibility_provider.dart';
import '../../domain/entities/compatibility_result.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/share_dialog.dart';

class CompatibilityResultScreen extends ConsumerWidget {
  final String resultId;

  const CompatibilityResultScreen({Key? key, required this.resultId}) : super(key: key);

  void _showShareDialog(BuildContext context, CompatibilityResult result) {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(compatibilityProvider);
    final result = state.results.firstWhere((r) => r.id == resultId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果の詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareDialog(context, result),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreSection(context, result),
                  const SizedBox(height: 24.0),
                  _buildAnalysisSection(context, result),
                  const SizedBox(height: 24.0),
                  _buildTraitsSection(context, result),
                  const SizedBox(height: 24.0),
                  _buildAdviceSection(context, result),
                  const SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showShareDialog(context, result),
                      icon: const Icon(Icons.share),
                      label: const Text('結果を共有'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreSection(BuildContext context, CompatibilityResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${result.compatibilityScore}%',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              result.compatibilityLevel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, CompatibilityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分析結果',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(result.analysis),
          ),
        ),
      ],
    );
  }

  Widget _buildTraitsSection(BuildContext context, CompatibilityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '共通点と相違点',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '共通点:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                ...result.commonTraits.map((trait) => Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16.0),
                          const SizedBox(width: 8.0),
                          Expanded(child: Text(trait)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16.0),
                Text(
                  '相違点:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                ...result.differences.map((diff) => Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_circle, size: 16.0),
                          const SizedBox(width: 8.0),
                          Expanded(child: Text(diff)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceSection(BuildContext context, CompatibilityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アドバイス',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(result.advice),
          ),
        ),
      ],
    );
  }
}