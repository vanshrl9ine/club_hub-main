import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_hub/services/announce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_activities.dart';

class EditAnnouncement extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String docId;
  const EditAnnouncement(
      {super.key,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.docId});

  @override
  State<EditAnnouncement> createState() => _EditAnnouncementState();
}

class _EditAnnouncementState extends State<EditAnnouncement> {
  Future<String> saveToStorage() async {
    try {
      Reference ref1 = FirebaseStorage.instance
          .ref()
          .child('Announcements')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(widget.title);
      //delete previous image
      await ref1.delete();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Announcements')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(announce.title.value);
      UploadTask uploadTask = ref.putFile(
          announce.image.value!,
          SettableMetadata(
            contentType: "image/jpeg",
          ));
      TaskSnapshot snap = await uploadTask;
      String url = await snap.ref.getDownloadURL();
      return url;
    } catch (e) {
      return 'error: ${e.toString()}';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImageFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      announce.image.value = File(pickedImageFile.path);
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    announce.title.value = widget.title;
    announce.description.value = widget.description;
  }

  late ScaffoldMessengerState scaffoldMessenger;
  Announce announce = Announce(
    title: '',
    description: '',
    image: null,
    createdBy: FirebaseAuth.instance.currentUser!.uid,
  );
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Announcement'),
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
                        controller: titleController, labelText: 'Title')),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: size.width * 0.8,
                    child: MyFormField(
                      controller: descriptionController,
                      labelText: 'Description',
                      maxLines: 5,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.2,
                      width: size.width * 0.8,
                      child: Row(
                        children: [
                          const Text('  Image : ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(width: 2),
                          Obx(
                            () => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (announce.image.value == null)
                                  SizedBox(
                                    width: size.width * 0.5,
                                    height: size.height * 0.2,
                                    child: Image(
                                      image: NetworkImage(widget.imageUrl),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
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
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    saveButton(context, size),
                    deleteButton(context, size)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton deleteButton(BuildContext context, Size size) {
    return ElevatedButton(
        onPressed: () async {
          try {
            //show loading
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
            Reference ref1 = FirebaseStorage.instance
                .ref()
                .child('Announcements')
                .child(FirebaseAuth.instance.currentUser!.uid)
                .child(widget.title);
            await ref1.delete();
            await FirebaseFirestore.instance
                .collection('announcements')
                .doc(widget.docId)
                .delete();

            if (mounted) Navigator.pop(context);
            if (mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditAnnouncePage()));
              scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Deletion Successful !!',
                      style: TextStyle(fontSize: 16))));
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
            scaffoldMessenger
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: const Color.fromARGB(255, 248, 68, 55),
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const SizedBox(
            width: 120,
            height: 25,
            child: Center(
                child: Text('Delete',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    )))));
  }

  ElevatedButton saveButton(BuildContext context, Size size) {
    return ElevatedButton(
        onPressed: () async {
          String url = '';

          try {
            //show loading
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
            if (widget.title == titleController.text &&
                widget.description == descriptionController.text &&
                announce.image.value == null) {
              throw 'No changes made !!';
            }
            if (widget.title != titleController.text) {
              announce.title.value = titleController.text;
            }
            if (widget.description != descriptionController.text) {
              announce.description.value = descriptionController.text;
            }
            if (announce.image.value != null) {
              url = await saveToStorage();
              if (url.startsWith('error')) {
                throw url;
              }
            }
            if (url == '') {
              url = widget.imageUrl;
            }
            await FirebaseFirestore.instance
                .collection('announcements')
                .doc(widget.docId)
                .update({
              'title': announce.title.value,
              'description': announce.description.value,
              'image': url,
            });
            if (mounted) Navigator.pop(context);
            if (mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditAnnouncePage()));
              scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Updated Successfully !!',
                      style: TextStyle(fontSize: 16))));
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
            scaffoldMessenger
                .showSnackBar(SnackBar(content: Text(e.toString())));
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
            width: 120,
            height: 25,
            child: Center(
                child: Text('Save',
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
      required this.labelText,
      this.maxLines = 1,
      this.radius = 50});

  final TextEditingController controller;
  final String labelText;
  final int maxLines;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: labelText,
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
