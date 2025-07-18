import 'dart:io';
import 'package:bharat_worker/constants/firestore_constants.dart';
import 'package:bharat_worker/main.dart';
import 'package:bharat_worker/models/chat_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<ChatMessages> list = [];
class ChatServices {
 // final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatServices(
      {
        //required this.prefs,
        required this.firebaseStorage,
        required this.firebaseFirestore});


  ///------------------ Upload Image ----------------
  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }


  ///-------------- Update FireStore --------------
  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }


  /// --------------- Get Message -----------------------
  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(FirestoreConstants.message)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }


  /// ---------------- Send Message -----------------------
  void sendChatMessage(
      String content,
      String type,
      String groupChatId,
      String currentUserId,
      String peerId,
      String fileMainName,
      String seen,
      Timestamp timeStamp,
      String lastSeen,
      String lastMessage,
      String isDelete,
      String status, // <-- Add status param
      [String? replyTo] // <-- Add replyTo param (optional)
      ) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(FirestoreConstants.message)
        .doc();

    ChatMessages chatMessages = ChatMessages(
      senderId: currentUserId,
      receiverId: peerId,
      timestamp: timeStamp,
      content: content,
      type: type,
      seen: seen,
      filename: fileMainName, lastSeen: lastSeen, lastMessage:lastMessage, isDelete: isDelete, status: status, replyTo: replyTo, ); // <-- Set status and replyTo

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }

  /// Update message status to delivered
  Future<void> markMessageDelivered(String groupChatId, String messageId) async {
    await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(FirestoreConstants.message)
        .doc(messageId)
        .update({'status': '1'}); // 1 = delivered
  }


   Future<void> getSelfInfo(String userId,
       String isOnline,
       String lastActive,
       int count) async {
    await firebaseFirestore
        .collection('users')
        .doc(userId.toString())
        .get()
        .then((user) async {
      if (user.id == userId && user.exists) {
        updateChatCount(userId,isOnline,lastActive,count);
      } else {
        await createChatCount(userId).then((value) => getSelfInfo(userId,isOnline,lastActive,count));
      }
    });
  }

   Future<void> updateChatCount(
       String currentUserId,
       String isOnline,
       String lastActive,
       int count,) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    DocumentReference documentReference =  firebaseFirestore
        .collection('users')
        .doc(
      sharedPreferences.getInt("userId").toString(),
    );

    ChatCount chatMessages = ChatCount(
        userId: currentUserId,
        isOnline: isOnline,lastActive:lastActive,count:count, pushToken: '');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }


   Future<void> createChatCount(String userId) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatCount(
      userId: userId.toString(),
      isOnline: false.toString(),
      lastActive: time,
      pushToken: '',
      count:0,
    );
    if (chatUser.userId != "null" || userId != "null") {
      await firebaseFirestore
          .collection('users')
          .doc(chatUser.userId)
          .set(chatUser.toJson());
    }
  }

  Future<void> decrementCount(String userID) async {
    final userDocRef = firebaseFirestore
        .collection('users').doc(userID);

    try {
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final int count = data?['count'] ?? 0;

        debugPrint("count....$count");
        if (count != 0) {
          await userDocRef.update({'count': count-1});
          //debugPrint('Count decremented by 1.');
        } else {
         // debugPrint('Count is already zero.');
        }
      } else {
       // debugPrint('No such document!');
      }
    } catch (e) {
    //  debugPrint('Error getting document: $e');
    }
  }

  Future<void> incrementCount(String userID,int totalCount) async {
    final userDocRef = firebaseFirestore
        .collection('users').doc(userID);

    try {
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final int count = data?['count'] ?? 0;

        debugPrint("count....$count");
          await userDocRef.update({'count':totalCount});
          debugPrint('Count decremented by 1.');

      } else {
        debugPrint('No such document!');
      }
    } catch (e) {
      debugPrint('Error getting document: $e');
    }
  }



  Future<void> seeMsg(String groupId,String senderId,String seen) async{
    final query = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupId.toString())
        .collection(FirestoreConstants.message)
        .where('sender_id', isEqualTo: senderId)
        .where('seen', isEqualTo: "0")
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'seen': seen, 'status': '2'}); // <-- Set status to '2' (seen)
    }
  }

  Future<void> lastUpdateMsg(String groupId,String senderId) async{
    final query = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupId.toString())
        .collection(FirestoreConstants.message)
        .where('sender_id', isEqualTo: senderId)
        .where('lastMessage', isEqualTo: "0")
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'lastMessage': "1"});
    }
  }

  // Method to count the messages with lastMessage equal to "0"
  int countLastMessagesEqualZero(var list,var peerID,var userId) {
    int count = 0;

    // setState(() {
    for (var message in list) {
      debugPrint("message.receiverId...${message.receiverId}");
      debugPrint("message.receiverId...${message.content}");
      debugPrint("message.seen...${message.seen}");
      debugPrint("peerID...$peerID");
      if (message.seen.toString() == "0" && message.senderId == peerID) {
        count++;
      }
    }
    // });

    return count;
  }

  // Delete mea
  Future<void> deleteMsg(String groupId,String senderId) async{
    final query = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupId.toString())
        .collection(FirestoreConstants.message)
        .where('sender_id', isEqualTo: senderId)
        .where('isDelete', isEqualTo: "0")
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'isDelete': "1"});
    }
  }



  String getChatRoomIdByUserId1(String userID, String bookingId,String peerID) {
    int userId = int.parse(userID);
    int peerId = int.parse(peerID);
  var  groupChatId = "";
    if (userId <= peerId) {
      groupChatId = '$userId-$bookingId-$peerId';
    } else {
      groupChatId = '$peerId-$bookingId-$userId';
    }
    return groupChatId;
  }

  String getChatRoomIdByUserId(String userID, String peerID) {
    int userId = userID == "null" || userID == "" ?0: int.parse(userID);
    int peerId = peerID == "null" || peerID == "" ?0:int.parse(peerID);
    var  groupChatId = "";
    if (userId <= peerId) {
      groupChatId = '$userId-$peerId';
    } else {
      groupChatId = '$peerId-$userId';
    }
    return groupChatId;
  /* return userID.hashCode <= peerID.hashCode
       ? '$userID-$peerID'
       : '$peerID-$userID';*/
 }

  // Stream to get unread message count for a user in real time
  Stream<int> getUnreadCountStream(String userId) {
    return firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['count'] ?? 0) as int);
  }

  /// Set typing status for a user in a chat room
  Future<void> setTypingStatus(String groupChatId, String userId, bool isTyping) async {
    await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .set({'typing_user_$userId': isTyping}, SetOptions(merge: true));
  }

  /// Listen to typing status of a user in a chat room
  Stream<bool> typingStatusStream(String groupChatId, String userId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .snapshots()
        .map((doc) => (doc.data()?['typing_user_$userId'] ?? false) as bool);
  }
}

/// ----------- Message Type --------------
class MessageType {
  static const text = "text";
  static const image = "image";
  static const sticker = "sticker";
  static const doc = "doc";
  static const location = "location";
}
