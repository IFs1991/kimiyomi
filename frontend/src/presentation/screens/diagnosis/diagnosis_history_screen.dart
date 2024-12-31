import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/diagnosis_history_provider.dart';
import '../../../domain/entities/diagnosis_result.dart';
import 'diagnosis_result_screen.dart';

class DiagnosisHistoryScreen extends ConsumerStatefulWidget {
  const DiagnosisHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends ConsumerState<DiagnosisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(diagnosisHistoryProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('診断履歴'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(diagnosisHistoryProvider.notifier).loadHistory();
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : state.results.isEmpty
                  ? const Center(
                      child: Text('診断履歴がありません'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(diagnosisHistoryProvider.notifier).loadHistory();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final result = state.results[index];
                          return DiagnosisHistoryCard(
                            result: result,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiagnosisResultScreen(result: result),
                                ),
                              );
                            },
                            onShare: () async {
                              await ref
                                  .read(diagnosisHistoryProvider.notifier)
                                  .shareResult(result.id);
                            },
                            onDelete: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('確認'),
                                  content: const Text('この診断結果を削除してもよろしいですか？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        '削除',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                await ref
                                    .read(diagnosisHistoryProvider.notifier)
                                    .deleteResult(result.id);
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class DiagnosisHistoryCard extends StatelessWidget {
  final DiagnosisResult result;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const DiagnosisHistoryCard({
    Key? key,
    required this.result,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      result.diagnosis.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          result.isShared ? Icons.share_outlined : Icons.share,
                          color: result.isShared ? Colors.green : null,
                        ),
                        onPressed: onShare,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.result,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '総合スコア: ${result.totalScore}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '診断日: ${_formatDate(result.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}