import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../helper/my_date_util.dart';
import '../helper/themes.dart';
import '../models/chat_user.dart';
import '../main.dart';
import '../widgets/show_only_profile_picture.dart';

//view-profile of user from the chat screen
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  //Image picked for profile photo
  String? _image;

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        // leadingWidth: 0,
        centerTitle: false,
      ),

      body: Center(
        child: Column(children: [
          //adding space in the beginning
          SizedBox(height: mq.height * 0.03),
          _image != null
              ?
              //local image
              ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.1),
                  //display profile picture
                  child: Image.file(
                    File(_image!),
                    width: mq.height * 0.2,
                    height: mq.height * 0.2,
                    fit: BoxFit.cover,
                  ),
                )
              :
              //image from server
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          //onTap, display enlarged profile picture
                          //only profile picture displayed
                          builder: (_) =>
                              ShowOnlyProfilePicture(user: widget.user)),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    //display profile picture
                    child: CachedNetworkImage(
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

          SizedBox(height: mq.height * 0.03),
          Text(widget.user.email,
              style: Themes.myTextTheme.bodyMedium!.copyWith(fontSize: 18)),
          SizedBox(height: mq.height * 0.02),

          Card(
            // clipBehavior: Clip.hardEdge,
            // borderOnForeground: true,

            margin: EdgeInsets.all(20),
            // shadowColor: Colors.deepPurple,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(mq.height * 0.015),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("About",
                      style: Themes.myTextTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: mq.height * 0.01),
                  Text(widget.user.about,
                      textAlign: TextAlign.justify,
                      style: Themes.myTextTheme.bodySmall),
                ],
              ),
            ),
          ),
        ]),
      ),

      //position of the floatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //showing joined date of the user
      floatingActionButton: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: "Joined On: ",
              style: Themes.myTextTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
          TextSpan(
              text: MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: Themes.myTextTheme.bodyMedium),
        ]),
      ),
    );
  }
}

//Add User class
/*

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   final String fullName;
//   final String company;
//   final int age;

//   HomeScreen(
//       {required this.fullName, required this.company, required this.age});

//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = FirebaseFirestore.instance.collection('users');

//     Future<void> addUser() {
//       return users
//           .add({"full_name": fullName, "company": company, "age": age})
//           .then((value) => print("\n\n==>User added"))
//           .catchError((error) => print("\n\n==>Falied to add user : $error"));
//     }

//     return TextButton(onPressed: addUser, child: Text("Add user"));
//   }
// }



*/
