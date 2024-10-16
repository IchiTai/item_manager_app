import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_provider.dart';
import 'item_model.dart';
import 'category_items_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final categoryProvider = CategoryProvider();
  await categoryProvider.loadCategories();
  runApp(MyApp(provider: categoryProvider));
}

class MyApp extends StatelessWidget {
  final CategoryProvider provider;

  MyApp({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryProvider>.value(
      value: provider,
      child: MaterialApp(
        title: 'Item Management App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CategoryListScreen(),
      ),
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('インベントリアプリ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'カテゴリーを追加しよう！'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final category = _categoryController.text;
              if (category.isNotEmpty) {
                context.read<CategoryProvider>().addCategory(category);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('カテゴリーに「$category」が追加されました！')));
                _categoryController.clear();
              }
            },
            child: Text('カテゴリーを追加'),
          ),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                return ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    provider.reorderCategory(oldIndex, newIndex);
                  },
                  children:
                      List.generate(provider.categoryOrder.length, (index) {
                    final category = provider.categoryOrder[index];
                    return ListTile(
                      key: ValueKey(category),
                      title: Text(category),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // 削除確認ダイアログを表示
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('削除確認'),
                                content:
                                    Text('カテゴリー "$category" を削除してもよろしいですか？'),
                                actions: [
                                  TextButton(
                                    child: Text('キャンセル'),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                  ),
                                  TextButton(
                                    child: Text('削除'),
                                    onPressed: () {
                                      // カテゴリー削除を実行
                                      context
                                          .read<CategoryProvider>()
                                          .removeCategory(category);
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryItemsScreen(category: category),
                          ),
                        );
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
