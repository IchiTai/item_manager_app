import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_provider.dart';
import 'item_model.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String category;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  CategoryItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryのアイテム'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _itemNameController,
              decoration: InputDecoration(labelText: 'アイテムの名前'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'アイテムの数'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final itemName = _itemNameController.text;
              final quantity = int.tryParse(_quantityController.text) ?? 0;
              if (itemName.isNotEmpty) {
                context
                    .read<CategoryProvider>()
                    .addItem(category, itemName, quantity);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アイテムに「$itemName」が追加されました！')));
                _itemNameController.clear();
                _quantityController.clear();
              }
            },
            child: Text('アイテムを追加'),
          ),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                final items = provider.categories[category] ?? [];
                return ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    provider.reorderItem(category, oldIndex, newIndex);
                  },
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    return ListTile(
                      key: ValueKey(item),
                      title: Text('${item.name} - ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (item.quantity > 0) {
                                provider.updateItemQuantity(
                                    category, item.name, item.quantity - 1);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              provider.updateItemQuantity(
                                  category, item.name, item.quantity + 1);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              provider.removeItem(category, item.name);
                            },
                          ),
                        ],
                      ),
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
