import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_hub/Pages/LoginAndSignup/login.dart';
import 'package:club_hub/Pages/home/activity.dart';
import 'package:club_hub/Pages/home/admin.dart';
import 'package:club_hub/Pages/home/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return HomePage(
                      currentIndex: 1,
                      profileType: snapshot.data!['profileType'].toString(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}

class HomePage extends StatefulWidget {
  final int currentIndex;
  final String profileType;
  const HomePage(
      {super.key, required this.currentIndex, required this.profileType});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int currentIndex;
  late String profileType;
  final List<Widget> _pages = [
    const ActivityPage(),
    const ProfilePage(),
    const AdminPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    profileType = widget.profileType;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: _pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          currentIndex: currentIndex,
          selectedIconTheme: const IconThemeData(color: Colors.blue),
          selectedFontSize: 14,
          selectedItemColor: const Color.fromARGB(255, 0, 140, 255),
          unselectedItemColor: Colors.black,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: profileType == 'Admin'
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event),
                    label: 'Activity',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings),
                    label: 'Admin',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event),
                    label: 'Activity',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
        ),
      ),
    );
  }
}
