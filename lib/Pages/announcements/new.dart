import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/announce.dart';

class NewAnnouncePage extends StatefulWidget {
  const NewAnnouncePage({super.key});

  @override
  State<NewAnnouncePage> createState() => _NewAnnouncePageState();
}

class _NewAnnouncePageState extends State<NewAnnouncePage> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImageFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      announce.image.value = File(pickedImageFile.path);
    }
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Announce announce = Announce(
    title: '',
    description: '',
    image: null,
    createdBy: '',
  );
  late ScaffoldMessengerState scaffoldMessenger;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
        backgroundColor: const Color.fromARGB(255, 105, 104, 104),
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: size.width * 0.8,
                    child: MyFormField(
                        controller: titleController, hintText: 'Title')),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: size.width * 0.8,
                    child: MyFormField(
                      controller: descriptionController,
                      hintText: 'Description',
                      maxLines: 5,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => Column(
                    children: [
                      SizedBox(
                        height: announce.image.value != null
                            ? size.height * 0.2
                            : 20,
                        width: size.width * 0.8,
                        child: Row(
                          children: [
                            const Text('  Image : ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            SizedBox(
                                width: announce.image.value == null ? 10 : 2),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (announce.image.value == null)
                                  const Text('No Image Selected !!',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                if (announce.image.value != null)
                                  SizedBox(
                                    width: size.width * 0.5,
                                    height: size.height * 0.2,
                                    child: Image(
                                      image: FileImage(announce.image.value!),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _pickImage();
                        },
                        child: const Text('Pick Image'),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                publishButton(context, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton publishButton(BuildContext context, Size size) {
    return ElevatedButton(
        onPressed: () async {
          if (titleController.text.isEmpty ||
              descriptionController.text.isEmpty ||
              announce.image.value == null) {
            scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Please fill all the fields !!',
                    style: TextStyle(fontSize: 16))));
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
            DocumentSnapshot userData = await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get();
            announce.updateAnnouncement(
                titleController.text,
                descriptionController.text,
                announce.image.value!.path,
                userData['name']);
            String result = await announce.uploadToStorage();
            if (mounted) Navigator.pop(context);
            if (result == 'success') {
              scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Announcement Published !!',
                      style: TextStyle(fontSize: 16))));
              if (mounted) Navigator.pop(context);
            } else {
              scaffoldMessenger.showSnackBar(SnackBar(
                  content: Text(result, style: const TextStyle(fontSize: 16))));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: const Color(0xFF4E60FF),
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const SizedBox(
            width: 150,
            height: 25,
            child: Center(
                child: Text('Publish',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    )))));
  }
}

class MyFormField extends StatelessWidget {
  const MyFormField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.maxLines = 1,
      this.radius = 50});

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: hintText,
          alignLabelWithHint: true,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 150, 150, 150),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          )),
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
