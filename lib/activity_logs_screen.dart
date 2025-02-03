import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  final TextEditingController _searchController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _searchController.addListener(_filterLogs);
  }

  void _fetchLogs() async {
    final logs = await DBHelper().getLogs();
    setState(() {
      _logs = logs;
      _filteredLogs = logs;
    });
  }

  void _filterLogs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLogs = _logs.where((log) {
        final action = log['action'].toLowerCase();
        final username = (log['username'] ?? 'unknown').toLowerCase();
        return action.contains(query) || username.contains(query);
      }).toList();
    });
  }

  void _filterLogsByDate() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _filteredLogs = _logs.where((log) {
          final logDate = DateTime.parse(log['timestamp']);
          return logDate.isAfter(_startDate!) && logDate.isBefore(_endDate!);
        }).toList();
      });
    }
  }

  void _deleteLog(int logId) async {
    final db = await DBHelper().database;
    await db.delete(
      'logs',
      where: 'id = ?',
      whereArgs: [logId],
    );
    _fetchLogs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log deleted successfully')),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
      _filterLogsByDate();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
      _filterLogsByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by user or action...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate == null
                          ? 'Start Date'
                          : DateFormat('yyyy-MM-dd').format(_startDate!),
                    ),
                    onPressed: () => _selectStartDate(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _endDate == null
                          ? 'End Date'
                          : DateFormat('yyyy-MM-dd').format(_endDate!),
                    ),
                    onPressed: () => _selectEndDate(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(
              child: Text(
                'No logs available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = _filteredLogs[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text(
                          log['action'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        log['action'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By: ${log['username'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd hh:mm a').format(
                              DateTime.parse(log['timestamp']),
                            ),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLog(log['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
