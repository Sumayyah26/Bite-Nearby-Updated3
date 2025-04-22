import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bite_nearby/Coolors.dart'; // Make sure to import your colors

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  Future<List<String>> _getPreferences() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (snapshot.exists && snapshot.data() != null) {
          List<String> preferences =
              List<String>.from(snapshot.get('preferences') ?? []);
          return preferences;
        }
      } catch (e) {
        print('Error fetching preferences: $e');
      }
    }
    return [];
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Coolors.charcoalBlack,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Center(
        child: Text(
          'Safe & Preferred',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Coolors.lightOrange,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Remove default app bar
      backgroundColor: Coolors.ivoryCream,
      body: Column(
        children: [
          _buildHeader(), // Add our custom header
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _getPreferences(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching preferences.'));
                }

                List<String> preferences = snapshot.data ?? [];
                if (preferences.isEmpty) {
                  return const Center(
                    child: Text(
                      'No preferences available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: preferences.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          preferences[index],
                          style: const TextStyle(fontSize: 16),
                        ),
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
