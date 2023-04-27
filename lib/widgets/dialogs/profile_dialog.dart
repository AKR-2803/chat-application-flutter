import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../helper/themes.dart';
import '../../screens/chat_screen.dart';
import '../../widgets/show_only_profile_picture.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mq.height * 0.02)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * 0.35,
        child: Stack(children: [
          //display user name
          Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(user.name,
                  style: Themes.myTextTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold))),
          //display profile picture
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      //display enlarged profile picture
                      //only profile picture displayed
                      builder: (_) => ShowOnlyProfilePicture(user: user)),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.02),
                //display profile picture
                child: CachedNetworkImage(
                  width: mq.height * 0.3,
                  height: mq.height * 0.3,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
          ),
          //display info icon
          Align(
              alignment: AlignmentDirectional.topEnd,
              child: Tooltip(
                message: "User Info",
                child: InkWell(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    onTap: () {
                      //pop the dialog
                      Navigator.pop(context);
                      //push the chat screen page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              //
                              builder: (_) => ChatScreen(user: user)));
                    },
                    child: const Icon(CupertinoIcons.text_bubble_fill)),
              ))
        ]),
      ),
    );
  }
}
