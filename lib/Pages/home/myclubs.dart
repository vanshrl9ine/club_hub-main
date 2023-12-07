import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyClubsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Clubs'),
        ),
        body: FutureBuilder(
            future: getCurrentUser(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No Data'));
              }

              User user = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.displayName ?? "Guest",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      user.email ?? "",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    // Fetch and display the "Clubs" array
                    FutureBuilder(
                      future: _firestore.collection('users').doc(user.uid).get(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return Text('No additional data found');
                        }

                        // Extract the "Clubs" array
                        List<dynamic>? clubs = snapshot.data!.get('Clubs');

                        if (clubs == null || clubs.isEmpty) {
                          return Text('No Clubs found');
                        }

                        // Display the "Clubs" array in a table
                        return DataTable(
                          columns: [DataColumn(label: Text('Clubs'))],
                          rows: clubs
                              .map(
                                (club) => DataRow(cells: [
                              DataCell(Text(club.toString())),
                            ]),
                          )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            ),
        );
    }
}