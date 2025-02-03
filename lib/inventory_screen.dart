import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> _inventoryItems = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refreshInventory();
  }

  void _refreshInventory() async {
    final data = await DBHelper().getItems();
    setState(() {
      _inventoryItems = data;
    });
  }

  void _showDeleteConfirmationDialog(int itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper().deleteItem(itemId);
              _refreshInventory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showForm({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name']);
    final quantityController = TextEditingController(text: item?['quantity']?.toString());
    final priceController = TextEditingController(text: item?['price']?.toString());
    final dateController = TextEditingController(text: item?['date']);
    final deliverToController = TextEditingController(text: item?['deliverTo']);
    final inController = TextEditingController(text: item?['in']?.toString());
    final outController = TextEditingController(text: item?['out']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Create New Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              TextField(
                controller: deliverToController,
                decoration: const InputDecoration(labelText: 'Deliver To'),
              ),
              TextField(
                controller: inController,
                decoration: const InputDecoration(labelText: 'In'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: outController,
                decoration: const InputDecoration(labelText: 'Out'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;
              final date = dateController.text;
              final deliverTo = deliverToController.text;
              final inValue = int.tryParse(inController.text) ?? 0;
              final outValue = int.tryParse(outController.text) ?? 0;

              if (name.isEmpty || date.isEmpty || deliverTo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              if (item == null) {
                await DBHelper().addItem(name, quantity, price, date, deliverTo, inValue, outValue);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added successfully')),
                );
              } else {
                await DBHelper().updateItem(item['id'], name, quantity, price, date, deliverTo, inValue, outValue);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item updated successfully')),
                );
              }

              _refreshInventory();
              Navigator.pop(context);
            },
            child: Text(item == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterItems() {
    if (_searchQuery.isEmpty) return _inventoryItems;
    return _inventoryItems.where((item) {
      final name = item['name']?.toLowerCase() ?? "";
      final id = item['id'].toString();
      return name.contains(_searchQuery.toLowerCase()) || id.contains(_searchQuery);
    }).toList();
  }

  Widget _buildDataTable() {
    final filteredItems = _filterItems();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
        columns: const [
          DataColumn(label: Text('S.NO.')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Deliver To')),
          DataColumn(label: Text('In')),
          DataColumn(label: Text('Out')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredItems.asMap().entries.map((entry) {
          int index = entry.key + 1;
          Map<String, dynamic> item = entry.value;
          return DataRow(
            cells: [
              DataCell(Text(index.toString())),
              DataCell(Text(item['name'] ?? 'N/A')),
              DataCell(Text(item['quantity'].toString())),
              DataCell(Text(item['price'].toString())),
              DataCell(Text(item['date'] ?? 'N/A')),
              DataCell(Text(item['deliverTo'] ?? 'N/A')),
              DataCell(Text(item['in'].toString())),
              DataCell(Text(item['out'].toString())),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(item['id']),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _inventoryItems.isEmpty
            ? const Center(child: Text('No items available.'))
            : _buildDataTable(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
