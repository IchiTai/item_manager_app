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
                _itemNameController.clear();
                _quantityController.clear();
              }
            },
            child: Text('Add Item'),
          ),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                final items = provider.categories[category] ?? [];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          '${items[index].name} - ${items[index].quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (items[index].quantity > 0) {
                                context
                                    .read<CategoryProvider>()
                                    .updateItemQuantity(
                                        category,
                                        items[index].name,
                                        items[index].quantity - 1);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              context
                                  .read<CategoryProvider>()
                                  .updateItemQuantity(
                                      category,
                                      items[index].name,
                                      items[index].quantity + 1);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              context
                                  .read<CategoryProvider>()
                                  .removeItem(category, items[index].name);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
