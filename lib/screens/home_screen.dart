import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_student_screen.dart';
import 'student_list_screen.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String connectionStatus = 'Not tested yet';
  bool isConnected = false;
  bool isLoading = false;

  Future<void> testFirebaseConnection() async {
    setState(() {
      isLoading = true;
      connectionStatus = 'Testing Firebase...';
    });

    try {
      await FirebaseFirestore.instance
          .collection('connection_test')
          .doc('test')
          .set({
        'message': 'Firebase is working!',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        connectionStatus = 'Firebase Connected!';
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Connection Failed\n$e';
        isConnected = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await userService.value.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isConnected ? Icons.cloud_done : Icons.cloud,
                size: 90,
              ),
              const SizedBox(height: 20),
              const Text(
                'Firebase Student Demo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                connectionStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isConnected ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('My Profile'),
                ),
              ),
              const SizedBox(height: 15),

              // Test Connection
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : testFirebaseConnection,
                  icon: const Icon(Icons.wifi),
                  label: Text(
                    isLoading
                        ? 'Testing...'
                        : 'Test Firebase Connection',
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Add Student
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddStudentScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Student'),
                ),
              ),
              const SizedBox(height: 15),

              // View Students
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('View Students'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}