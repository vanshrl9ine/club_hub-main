import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_hub/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit.dart';

class EditAnnouncePage extends StatefulWidget {
  const EditAnnouncePage({super.key});

  @override
  State<EditAnnouncePage> createState() => _EditAnnouncePageState();
}

class _EditAnnouncePageState extends State<EditAnnouncePage> {
  _fetchAnnouncements() async {
    QuerySnapshot<Map<String, dynamic>> docs = await FirebaseFirestore.instance
        .collection('announcements')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      _activities = docs.docs
          .map((doc) => {
                'id': doc.id, // Add the document ID
                ...doc.data(),
              })
          .toList();
      //order activities by date
      _activities.sort((a, b) => a['date'].compareTo(b['date']));
    });
  }

  late List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePage(
                      currentIndex: 2,
                      profileType: 'Admin',
                    )));
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Announcements'),
          backgroundColor: const Color.fromARGB(255, 105, 104, 104),
          elevation: 0,
        ),
        body: Center(
          child: Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 105, 104, 104),
                  Color.fromARGB(255, 62, 62, 62),
                  Colors.black
                ],
              ),
            ),
            child: ListView.builder(
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: activityItem(index),
                  );
                }),
          ),
        ),
      ),
    );
  }

  InkWell activityItem(int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => EditAnnouncement(
                    title: _activities[index]['title'],
                    description: _activities[index]['description'],
                    docId: _activities[index]['id'],
                    imageUrl: _activities[index]['image']))));
      },
      child: Card(
        elevation: 5,
        color: const Color.fromARGB(255, 159, 167, 173),
        child: SizedBox(
          height: 75,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activities[index]['title'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _activities[index]['description'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        //convert timestamp to date
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 53, 53, 53),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
                const SizedBox(
                  width: 8,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
