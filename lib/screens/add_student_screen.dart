import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() =>
      _AddStudentScreenState();
}

class _AddStudentScreenState
    extends State<AddStudentScreen> {

  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final courseController = TextEditingController();

  bool isSaving = false;

  Future<void> saveStudent() async {
    if (nameController.text.isEmpty ||
        studentIdController.text.isEmpty ||
        courseController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields.',
          ), // Text
        ), // SnackBar
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .add({
        'name': nameController.text,
        'studentId': studentIdController.text,
        'course': courseController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      nameController.clear();
      studentIdController.clear();
      courseController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student saved to Firebase!',
          ), // Text
        ), // SnackBar
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ), // Text
        ), // SnackBar
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    courseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ), // AppBar

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ), // InputDecoration
            ), // TextField
            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ), // InputDecoration
            ), // TextField
            const SizedBox(height: 15),

            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ), // InputDecoration
            ), // TextField
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isSaving ? null : saveStudent,
                icon: const Icon(Icons.cloud_upload),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save to Firebase',
                ), // Text
              ), // ElevatedButton.icon
            ), // SizedBox

          ], // Column
        ), // Padding
      ), // Scaffold
    );
  }
}