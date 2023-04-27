import 'package:chatapplication/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ShowOnlyProfilePicture extends StatelessWidget {
  ShowOnlyProfilePicture({required this.user, super.key});
  ChatUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(user.name),
            elevation: 0,
            leadingWidth: mq.width * 0.1,
            centerTitle: false),
        body: GestureDetector(
            //detects finger gestures accordingly
            // onVerticalDragDown: (details) => Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (_) => HomeScreen())),
            onVerticalDragDown: (details) => Navigator.pop(context),
            // onTap: () => Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (_) => HomeScreen())),
            // onTap: () {
            // },
            child: Center(
              //enlarged profile picture
              child: CachedNetworkImage(
                width: double.maxFinite,
                height: mq.height * 0.5,
                fit: BoxFit.cover,
                imageUrl: user.image,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            )),
      ),
    );
  }
}
