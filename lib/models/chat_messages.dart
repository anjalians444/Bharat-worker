

import 'package:bharat_worker/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  String senderId;
  String receiverId;
  Timestamp timestamp;
  String content;
  String filename;
  String seen;
  String type;
  String lastSeen;
  String lastMessage;
  String isDelete;
  String status; // 0=sent, 1=delivered, 2=seen
  String? replyTo; // id of the message being replied to
  // String bookingId;
 // Timestamp separateDate;

  ChatMessages(
      {required this.senderId,
      required this.receiverId,
      required this.timestamp,
      required this.content,
      required this.type,
      required this.seen,
      required this.filename,
      required this.lastSeen,
      required this.lastMessage,
      required this.isDelete,
      required this.status,
      this.replyTo,
      // required this.bookingId,
    //  required this.separateDate,
      });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.senderId: senderId,
      FirestoreConstants.receiverId: receiverId,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.filename: filename,
      FirestoreConstants.seen: seen,
      FirestoreConstants.lastSeen: lastSeen,
      FirestoreConstants.lastMessage: lastMessage,
      FirestoreConstants.isDelete: isDelete,
      'status': status,
      if (replyTo != null) 'replyTo': replyTo,
      // FirestoreConstants.bookingId: bookingId,
      //FirestoreConstants.separateDate: separateDate,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String receiverId = documentSnapshot.get(FirestoreConstants.receiverId);
    String senderId = documentSnapshot.get(FirestoreConstants.senderId);
    Timestamp timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String content = documentSnapshot.get(FirestoreConstants.content);
    String type = documentSnapshot.get(FirestoreConstants.type);
    String filename = documentSnapshot.get(FirestoreConstants.filename);
    String seen = documentSnapshot.get(FirestoreConstants.seen);
    String lastSeen = documentSnapshot.get(FirestoreConstants.lastSeen);
    String lastMessage = documentSnapshot.get(FirestoreConstants.lastMessage);
    String isDelete = documentSnapshot.get(FirestoreConstants.isDelete);
    String status = documentSnapshot.data().toString().contains('status') ? documentSnapshot.get('status') : '0';
    String? replyTo = documentSnapshot.data().toString().contains('replyTo') ? documentSnapshot.get('replyTo') : null;
    // String bookingId = documentSnapshot.get(FirestoreConstants.bookingId);
  //  Timestamp separateDate = documentSnapshot.get(FirestoreConstants.separateDate);

    return ChatMessages(
        senderId: senderId,
        receiverId: receiverId,
        timestamp: timestamp,
        content: content,
        type: type,
        seen: seen,
        filename: filename,
      lastSeen: lastSeen,
      lastMessage: lastMessage,
      isDelete: isDelete,
      status: status,
      replyTo: replyTo,
      // bookingId: bookingId,
    );
  }
}





class ChatCount {
  String userId;
  String isOnline;
  String lastActive;
  String pushToken;
  int count;

  ChatCount(
      {required this.userId,
        required this.isOnline,
        required this.lastActive,
        required this.pushToken,
        required this.count,
      });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.senderId: userId,
      FirestoreConstants.content: isOnline,
      FirestoreConstants.lastActive: lastActive,
      FirestoreConstants.pushToken: pushToken,
      FirestoreConstants.count: count,
    };
  }
  factory ChatCount.fromDocument(DocumentSnapshot documentSnapshot) {
    String userId = documentSnapshot.get(FirestoreConstants.senderId);
    String isOnline = documentSnapshot.get(FirestoreConstants.isOnline);
    String lastActive = documentSnapshot.get(FirestoreConstants.lastActive);
    String pushToken = documentSnapshot.get(FirestoreConstants.pushToken);
    int count = documentSnapshot.get(FirestoreConstants.count);

    return ChatCount(
      userId: userId,
      isOnline: isOnline,
      lastActive: lastActive,
      pushToken: pushToken,
      count: count,
    );
  }
}

class ChatCount1 {
  String userId;
  String isOnline;
  String lastActive;
  String pushToken;
  String count;

  ChatCount1({
    required this.userId,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': userId,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'pushToken': pushToken,
      'count': count,
    };
  }

  factory ChatCount1.fromJson(Map<String, dynamic> json) {
    return ChatCount1(
      userId: json['sender_id'].toString(),
      isOnline: json['isOnline'].toString(),
      lastActive: json['lastActive'],
      pushToken: json['pushToken'],
      count: json['count'].toString(),
    );
  }
}
