// calendar_utils.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarUtils {
  static Future<List<Event>> loadEvents() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('events').get();

    return querySnapshot.docs
        .map((doc) => Event(
      doc['title'],
      DateTime.fromMillisecondsSinceEpoch(
        doc['date'].millisecondsSinceEpoch,
        isUtc: true,
      ),
      id: doc.id,
    ))
        .toList();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserSnapshot() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userUid).get();
  }

  static Future<void> addEvent(String title, DateTime selectedDay) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    String profileType = userSnapshot.data()?['profileType'];

    if (profileType == 'Admin') {
      final newEvent = Event(title, selectedDay);

      // Add the new event to Firestore
      await FirebaseFirestore.instance.collection('events').add({
        'title': newEvent.title,
        'date': newEvent.date.toUtc(),
        'addedBy': userUid,
      });
    }
  }

  static Future<void> deleteEvent(Event event, BuildContext context) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    String profileType = userSnapshot.data()?['profileType'];

    if (profileType == 'Admin') {
      // Remove the event from Firestore
      await FirebaseFirestore.instance.collection('events').doc(event.id).delete();

      // Notify the user that the event has been deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event deleted successfully.'),
        ),
      );
    } else {
      // Non-admin users are not allowed to delete events
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only users with admin profile can delete events.'),
        ),
      );
    }
  }
}
class Event {
  final String? id; // Make id nullable
  final String title;
  final DateTime date;

  Event(this.title, this.date, {this.id}); // Make id an optional named parameter

  // Add a factory constructor to create an event from a DocumentSnapshot
  factory Event.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Event(
      snapshot['title'],
      DateTime.fromMillisecondsSinceEpoch(
        snapshot['date'].millisecondsSinceEpoch,
        isUtc: true,
      ),
      id: snapshot.id, // Assign the document id as the event id
    );
  }
}
