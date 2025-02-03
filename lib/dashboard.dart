import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'db_helper.dart';
import 'inventory_screen.dart';
import 'users_screen.dart';
import 'activity_logs_screen.dart';
import 'login.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String userType;

  const DashboardScreen({Key? key, required this.username, required this.userType}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  int _userCount = 0;
  int _inventoryCount = 0;
  int _activityLogsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final userCount = (await DBHelper().getUsers()).length;
    final inventoryCount = (await DBHelper().getItems()).length;
    final activityLogsCount = (await DBHelper().getLogs()).length;

    setState(() {
      _userCount = userCount;
      _inventoryCount = inventoryCount;
      _activityLogsCount = activityLogsCount;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // تحسين قسم الصور بإضافة مسافات وحواف ناعمة وظلال
  Widget _buildCarousel() {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180, // زيادة الارتفاع لجعل الصور أوضح
            autoPlay: true,
            enlargeCenterPage: true,
          ),
          items: [
            'imges/1.jpg',
            'imges/2.jpg',
            'imges/3.jpg',
          ].map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [

        _buildCarousel(),

        // cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatsCard('Users', '$_userCount', Icons.person, Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatsCard('Inventory', '$_inventoryCount', Icons.inventory, Colors.blue),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatsCard('Activity Logs', '$_activityLogsCount', Icons.history, Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatsCard('Welcome', widget.username, Icons.waving_hand, Colors.teal),
              ),
            ],
          ),
        ),

        // devlopers part
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade200, Colors.indigo.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Our Developers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDeveloperCard('Hamza', Icons.code, Colors.blue),
                      _buildDeveloperCard('Cabdala', Icons.computer, Colors.orange),
                      _buildDeveloperCard('Yasiin', Icons.phone_android, Colors.green),
                      _buildDeveloperCard('Axmad', Icons.design_services, Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(String name, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            size: 30,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _navigateToInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryScreen()),
    );
  }

  void _navigateToUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsersScreen()),
    );
  }

  void _navigateToActivityLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivityLogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [const Color(0xFF1E1E2C), Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Row(
          children: [
            //  Admin
            CircleAvatar(
              backgroundColor: widget.userType == 'Admin' ? Colors.blueAccent : Colors.white,
              child: widget.userType == 'Admin'
                  ? const Icon(Icons.admin_panel_settings, color: Colors.white)
                  : Icon(Icons.person, color: Colors.indigo.shade700),
            ),
            const SizedBox(width: 8),
            Text(
              widget.username + (widget.userType == 'Admin' ? ' (Admin)' : ''),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: _selectedTab == 0
                ? _buildOverviewTab()
                : const Center(child: Text('Select a tab to view content.')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.dashboard, color: Colors.indigo),
                  onPressed: () => setState(() => _selectedTab = 0),
                ),
                IconButton(
                  icon: const Icon(Icons.inventory, color: Colors.blue),
                  onPressed: _navigateToInventory,
                ),
                if (widget.userType == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.orange),
                    onPressed: _navigateToUsers,
                  ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.red),
                  onPressed: _navigateToActivityLogs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
