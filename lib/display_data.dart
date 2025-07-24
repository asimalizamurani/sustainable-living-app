import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class DisplayData extends StatefulWidget {
  const DisplayData({super.key});

  @override
  State<DisplayData> createState() => _DisplayDataState();
}

class _DisplayDataState extends State<DisplayData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Failed to load data");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final userDocs = snapshot.data?.docs ?? [];

          if (userDocs.isEmpty) {
            return Text("No users found");
          }

          return ListView(
            children: userDocs.map((val){
              final data = val.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(data['email'] ?? 'No Email'),
                trailing: Text(data['password'] ?? 'No Password'),
              );
            }).toList(),
          );
        }
      )
      
    );
  }
}