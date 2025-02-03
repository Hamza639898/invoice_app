import 'package:flutter/material.dart';
import '../db_helper.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() async {
    final data = await DBHelper().getUsers();
    setState(() {
      _users = data;
    });
  }

  void _showDeleteConfirmationDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper().deleteUser(userId);
              _refreshUsers();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showForm({Map<String, dynamic>? user}) {
    final usernameController = TextEditingController(text: user?['username']);
    final passwordController = TextEditingController(text: user?['password']);
    final userTypeController = TextEditingController(text: user?['userType']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Create New User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: userTypeController,
                decoration: const InputDecoration(labelText: 'User Type (Admin/User)'),
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
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();
              final userType = userTypeController.text.trim();

              if (username.isEmpty || password.isEmpty || userType.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              if (user == null) {
                await DBHelper().insertUser(username, password, userType);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User added successfully')),
                );
              } else {
                await DBHelper().updateUser(user['id'], username, password, userType);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              }

              _refreshUsers();
              Navigator.pop(context);
            },
            child: Text(user == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterUsers() {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final username = user['username']?.toLowerCase() ?? "";
      final userType = user['userType']?.toLowerCase() ?? "";
      return username.contains(_searchQuery.toLowerCase()) || userType.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildDataTable() {
    final filteredUsers = _filterUsers();

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('S.NO.', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('User Type', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('${index + 1}')),
                      Expanded(child: Text(user['username'] ?? 'N/A')),
                      Expanded(child: Text(user['userType'] ?? 'N/A')),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showForm(user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmationDialog(user['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String?>(
                context: context,
                delegate: UserSearchDelegate(_users),
              );

              if (query != null && query.isNotEmpty) {
                setState(() {
                  _searchQuery = query;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildDataTable(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> users;

  UserSearchDelegate(this.users);

  @override
  String? get searchFieldLabel => 'Search by username or user type';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredUsers = users.where((user) {
      final username = user['username']?.toLowerCase() ?? "";
      final userType = user['userType']?.toLowerCase() ?? "";
      return username.contains(query.toLowerCase()) || userType.contains(query.toLowerCase());
    }).toList();

    return filteredUsers.isEmpty
        ? const Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          title: Text(user['username'] ?? 'N/A'),
          subtitle: Text('Type: ${user['userType'] ?? 'N/A'}'),
          onTap: () => close(context, user['username']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
