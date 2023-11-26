import 'package:club_hub/Pages/announcements/new.dart';
import 'package:flutter/material.dart';

import '../announcements/edit_activities.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
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
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewAnnouncePage())),
            child: Card(
              elevation: 5,
              color: const Color.fromARGB(255, 159, 167, 173),
              child: SizedBox(
                height: size.height * 0.2,
                width: size.width * 0.7,
                child: const Center(
                    child: Text(
                  'New Announcement',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ]),
                )),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditAnnouncePage())),
            child: Card(
              elevation: 5,
              color: const Color.fromARGB(255, 159, 167, 173),
              child: SizedBox(
                height: size.height * 0.2,
                width: size.width * 0.7,
                child: const Center(
                    child: Text(
                  'Edit Announcement',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ]),
                )),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
