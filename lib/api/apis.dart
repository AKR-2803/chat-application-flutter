import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/message.dart';
import '../models/chat_user.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firestore storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self info
  static late ChatUser me;

  //returns current user
  static User get user => auth.currentUser!;

  //for accessing firebase messaging
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    //t is the token (String? t)
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print("===========> Push Token ==========> $t");
      }
    });

    //handling foreground messages
    // (foreground is when the application is open, in-view and in-use)
    /* 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("========> Got a message whilst in the foreground!");
      print("========> Message data: ${message.data}");

      if (message.notification != null) {
        print("Message also contained a notification: ${message.notification}");
      }
    }); 
    */
  }

  //for sending notifications
  static Future<void> sendPushNotifications(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var res =
          await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader:
                    "key=AAAATcwlWPg:APA91bG-77yIGggaF7039JAoTe8YFdsXiBwEOQSqteNK_ArCiTQK2u8TE33neorTsA8td75oQ24f4ge3akkgXG34hG1VUoQ71zvFGB2QHEo7yjnSfYKom8nAF84dOz6IhFe6Btk6qXsJ"
              },
              body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print("\n======> send push notifications error : $e");
    }
  }

  //checking if user exists already or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //adding a chat user fot chatting
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    print("Data of the email ============> :  ${data.docs}");

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists
      print(
          "inside the firestore collection add function <===========================");

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      print("Done ! added user to firebase <===========================");
      return true;
    } else {
      //user does not exist
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      //if user exists get self info
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //setting user status to active
        updateActiveStatus(true);

        print("\n\nMy Data ========> ${user.data()}");
      } else {
        //if user does not exist already
        //create a user first
        //then get self information
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //create a new user
  static Future<void> createUser() async {
    //This value is independent of the time zone.
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: auth.currentUser!.displayName.toString(),
      email: user.email.toString(),
      about: "Hey there! I am using AKRChat app",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    //adding the user data to firsestore
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //getting IDs of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        //not showing ones own ID (we dont chat with ourselves)
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //get all users from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    print("User ids (getAllUsers function) =======> $userIds");
    return firestore
        .collection('users')
        //not showing ones own ID (we dont chat with ourselves)
        .where('id', whereIn: userIds)
        .snapshots();
  }

  //adding a user to my_users when first time mssage is sent
  //scanario: you added a user and texted him, but he might not have you in his "my_users" list
  //hence when texted first time, we need to add this(sender) user into other(receiver) user's "my_user" list
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection("my_users")
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //updating user info
  static Future<void> updateUserInfo() async {
    print("\n\n\nInside the update info method...............");
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
    print("\n\n\n Update info method finished...............");
  }

  //updating profile picture
  static Future<void> updateProfilePicture(File file) async {
    //getting the file extension
    final ext = file.path.split('.').last;
    print("=========> Extension of the file : $ext <=========");
    //ref is storageRef, i.e reference to storage files with path
    final storageRef = storage.ref().child('profile_pictures/${user.uid}.$ext');
    //uploading the image
    await storageRef
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((TaskSnapshot p0) {
      print(
          "=========> Data transferred : ${p0.bytesTransferred / 1000} KB <=========");
    });

    //updating the image in firestore database
    me.image = await storageRef.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //for getting speccific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        //not showing ones own ID (we dont chat with ourselves)
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online or last seen time of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************************** Chat Screen Related APIs **************************

  //chats (collection)  ==>  conversation_id (docs)  ==>  messages (collection)  ==>  message (doc)

  //getting unique conversation ID
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //get all messages of a particular conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        //not showing ones own ID (we dont chat with ourselves)
        .snapshots();
  }

  //for sending messages
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as ID)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to be sent
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotifications(chatUser, type == Type.text ? msg : 'image'));
  }

  //update message read status
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message to show in the chat list
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //sending images in chat
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    /////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////

    //getting the file extension
    final ext = file.path.split('.').last;
    //ref is storageRef, i.e reference to storage files with path
    //name image with the timestamp using millisecondsSinceEpoch
    //so that the image names are unique
    final storageRef = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading the image
    await storageRef
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((TaskSnapshot p0) {
      print(
          "=========> Data transferred : ${p0.bytesTransferred / 1000} KB <=========");
    });

    //updating the image in firestore database
    final imageUrl = await storageRef.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
    /////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////
  }

  //deleting messages
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    //if message type is image
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //updating messages
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});

    //if message type is image
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
}
