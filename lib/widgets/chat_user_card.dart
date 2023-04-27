import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../api/apis.dart';
import '../screens/chat_screen.dart';
import '../helper/themes.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import '../widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message (if null, show about)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      //uncomment to remove margin, similar to whatsapp UI
      // margin: EdgeInsets.zero,
      // margin: EdgeInsets.symmetric(
      //     horizontal: mq.width * .025, vertical: mq.height * .002),
      // color: Color.fromARGB(255, 239, 236, 240),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          //Naigating to chat screen
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              //mapping json data to List using fromJson method
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              //mapping json data to List using fromJson method
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                //Image.network("APIs.auth.currentUser.photoURL")
                //user profile picture
                // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
                leading: InkWell(
                  onTap: () {
                    //showing enlarged profile picture dialog
                    //using animated dialog
                    showGeneralDialog(
                        context: context,
                        transitionBuilder: (ctx, a1, a2, myWidget) {
                          // return ProfileDialog(user: widget.user);
                          return Transform.scale(
                            scale: Curves.fastLinearToSlowEaseIn
                                .transform(a1.value),
                            child: Opacity(
                              opacity: a1.value,
                              child: ProfileDialog(user: widget.user),
                            ),
                          );
                        },
                        //pop when clicked anywhere else
                        barrierDismissible: true,
                        barrierLabel: '',
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (ctx, a1, a2) {
                          return const SizedBox();
                        });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * 0.06,
                      height: mq.height * 0.06,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                //user name
                title: Text(widget.user.name,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: mq.width * 0.03),

                //last message
                subtitle: Padding(
                  padding: EdgeInsets.only(top: mq.height * 0.007),
                  child: Text(
                      // implement this WhatsApp feature:
                      //if last message is from you, in chat user card, YOU: "msg" should be shown
                      //else just the message should be shown
                      // "message toId: ${_message!.toId} user id : ${widget.user.id}",
                      _message != null
                          ? _message!.type == Type.image
                              ? '🏝 Photo'
                              : _message!.msg.length > 30
                                  ? "${_message!.msg.substring(0, 30)}..."
                                  : _message!.msg
                          //limiting the length of about content shown in chat user card
                          : widget.user.about.length > 30
                              ? "${widget.user.about.substring(0, 30)}..."
                              : widget.user.about,
                      style: Themes.myTextTheme.bodySmall!
                          .copyWith(fontSize: 15, color: Colors.grey.shade700)),
                ),

                //last message time
                trailing: _message == null
                    //show nothing when no message is sent
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ?
                        //add some logic to display no. of unread messages rather than a dot
                        //fetch the conversations allmessages using APIs.getAllMessages()
                        //and check how many messages have read == '', display that number.
                        //show dot for unread messages
                        Container(
                            width: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple.shade300),
                          )

                        //timestamp of last message
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: Themes.myTextTheme.bodySmall!
                                .copyWith(fontSize: 15, color: Colors.black54)),
              );
            }),
      ),
    );
  }

  //animation in profile pitcure dialog
  // void _scaleDialog() {
  //   showGeneralDialog(
  //     context: context,
  //     pageBuilder: (ctx, a1, a2) {
  //       return Container();
  //     },
  //     transitionBuilder: (ctx, a1, a2, child) {
  //       var curve = Curves.easeOutCirc.transform(a1.value);
  //       return Transform.scale(
  //         // origin: Offset(-200, -200),
  //         // alignment: Alignment.centerLeft,
  //         // filterQuality: FilterQuality.low,
  //         scale: curve,
  //         child: ProfileDialog(user: widget.user),
  //       );
  //     },
  //     transitionDuration: const Duration(milliseconds: 400),
  //   );
  // }
}
