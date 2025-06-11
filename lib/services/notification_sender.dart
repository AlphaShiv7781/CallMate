import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendCallNotification({
  required String targetUid,
  required String channelName,
}) async {
  final targetDoc = await FirebaseFirestore.instance.collection('users').doc(targetUid).get();
  final fcmToken = targetDoc['fcmToken'];

  if (fcmToken == null) return;

  const serverKey = 'YOUR_SERVER_KEY'; // Firebase project > Project Settings > Cloud Messaging > Server Key

  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode({
      'to': fcmToken,
      'data': {
        'type': 'incoming_call',
        'channelName': channelName,
      },
    }),
  );
}
