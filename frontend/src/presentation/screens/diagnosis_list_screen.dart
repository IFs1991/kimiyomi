import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/diagnosis_provider.dart';
import '../../domain/entities/diagnosis.dart';
import '../widgets/diagnosis_card.dart';

class DiagnosisListScreen extends ConsumerStatefulWidget {
  const DiagnosisListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiagnosisListScreen> createState() => _DiagnosisListScreenState();
}

class _DiagnosisListScreenState extends ConsumerState<DiagnosisListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(diagnosisListProvider.notifier).loadDiagnoses());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('診断一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 診断作成画面へ遷移
            },
          ),
        ],
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
                          ref.read(diagnosisListProvider.notifier).loadDiagnoses();
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : state.diagnoses.isEmpty
                  ? const Center(
                      child: Text('診断がありません'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(diagnosisListProvider.notifier).loadDiagnoses();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.diagnoses.length,
                        itemBuilder: (context, index) {
                          final diagnosis = state.diagnoses[index];
                          return DiagnosisCard(
                            diagnosis: diagnosis,
                            onTap: () {
                              // TODO: 診断詳細画面へ遷移
                            },
                            onDelete: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('確認'),
                                  content: const Text('この診断を削除してもよろしいですか？'),
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
                                    .read(diagnosisListProvider.notifier)
                                    .deleteDiagnosis(diagnosis.id);
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}