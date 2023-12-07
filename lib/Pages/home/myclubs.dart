import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_hub/Pages/LoginAndSignup/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import 'package:flutter/material.dart';

class MyClubsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Clubs'),
      ),
      body: Center(
        child: Text('This is the My Clubs Page'),
      ),
    );
  }
}
