import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../main.dart';
import '../api/apis.dart';
import '../helper/themes.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import '../widgets/message_card.dart';
import '../screens/chat_media_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //handle the send message textfield!
  final _textController = TextEditingController();

  //_showEmoji => show/hide emojis
  //_isUploading => check if images are uploading or not
  bool _showEmoji = false, _isUploading = false;

  ScrollController _scrollController = ScrollController();

//list storing all the messages
  List<Message> _list = [];
  List<String> _imagesList = [];

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;
    //as status bar turns black after wrapping the Scaffold with SafeArea
    //use SystemChrome.setSystemUIOverlayStyle to set the statusBarColor to white
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(statusBarColor: Colors.grey.shade50));
    return GestureDetector(
      //to pop keyboard whenever clicked anywhere else
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //when emojis keyboard is active and back button is pressed, close the keyboard
          //else simply pop the current screen like normal scenario
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.blueGrey.shade50,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              titleSpacing: 0,
              // title: const Text("Hello App"),
            ),
            // appBar: AppBar(
            //   // automaticallyImplyLeading: false,
            //   flexibleSpace: _appBar(),
            //   titleSpacing: 0,
            //   // title: const Text("Hello App"),
            // ),
            body: Stack(
              children: [
                // backgorund image for chat screen
                Positioned(
                    height: mq.height,
                    width: mq.width,
                    child: Image.asset('assets/images/chatbackground.png',
                        fit: BoxFit.fill)),

                // Container(
                //   constraints: BoxConstraints.expand(),
                //   child: Image.asset(
                //     'assets/images/chatbackground.jpg',
                //     fit: BoxFit.fill,
                //   ),
                // ),
                // SizedBox.expand(
                //     child: Image.asset('assets/images/chatbackground2.jpg',
                //         fit: BoxFit.fill)),

                Column(children: [
                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////

                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(child: SizedBox());
                          //if some data is loaded show it
                          //if some data is loaded show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            //data from firestore database in Json format
                            final data = snapshot.data?.docs;
                            //mapping json data to List using fromJson method
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * 0.01),
                                  physics: const BouncingScrollPhysics(
                                      decelerationRate:
                                          ScrollDecelerationRate.normal),
                                  itemBuilder: (context, index) {
                                    //adding images for chat media screen
                                    if (_list[index].type == Type.image &&
                                        !_imagesList
                                            .contains(_list[index].msg)) {
                                      _imagesList.add(_list[index].msg);
                                    }
                                    /////////////////////////////////////////////////
                                    //showing messages
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              //showing Card when no message is present
                              return Center(
                                  child: SizedBox(
                                height: mq.height * 0.35,
                                width: mq.width * 0.6,
                                child: Card(
                                  elevation: 1.5,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.all(mq.height * 0.01),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("No messages here yet...",
                                            style: Themes.myTextTheme.bodySmall!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        SizedBox(height: mq.height * 0.03),
                                        Text(
                                            "Send a message or tap the greeting below",
                                            style: Themes.myTextTheme.bodySmall!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w400),
                                            textAlign: TextAlign.center),
                                        SizedBox(height: mq.height * 0.02),
                                        //on tapping this button send an initial message
                                        MaterialButton(
                                            onPressed: () {
                                              APIs.sendMessage(
                                                  widget.user,
                                                  "Namaste ${widget.user.name}!",
                                                  Type.text);
                                            },
                                            child: Image.asset(
                                                "assets/images/greetings.png",
                                                height: mq.height * 0.15)),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                            }
                          // return Center();
                        }
                      },
                    ),
                  ),

                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////
                  //////////////////////////////////////////////////////////////

                  //show progress indicator while images are uploading
                  if (_isUploading)
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: mq.width * 0.055,
                              vertical: mq.height * 0.01),
                          child: const CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2),
                        )),

                  //message input field, emoji picker, gallery, camera, send button
                  _chatInput(),

                  //showing emojis keyboard
                  if (_showEmoji)
                    SizedBox(
                      height: mq.height * 0.35,
                      child: EmojiPicker(
                        /// pass here the same [ TextEditingController ]  that is connected to your input field
                        textEditingController: _textController,
                        config: Config(
                          // iconColor: Colors.black,
                          iconColorSelected: Colors.black,
                          indicatorColor: Colors.deepPurple,
                          skinToneIndicatorColor: Colors.black54,
                          //default category to show
                          // initCategory: Category.ANIMALS,
                          buttonMode: ButtonMode.CUPERTINO,
                          // bgColor: Colors.black,
                          columns: 8,
                          //setting maximum emoji size
                          emojiSizeMax: 28 *
                              (Platform.isIOS
                                  ? 1.30
                                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                        ),
                      ),
                    ),
                  /////////////////////////////////////////////////////////////
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      //view user profile from chat screen
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatMediaScreen(
                    user: widget.user, mediaList: _imagesList)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            //mapping json data to List using fromJson method
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                //back button
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back)),
                //display profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.1),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: mq.height * 0.050,
                    height: mq.height * 0.050,
                    //updating the profile picture in chat screen if user changes it
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                SizedBox(width: mq.width * 0.025),
                //onTapping the username column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //display user name
                    Text(list.isNotEmpty ? list[0].name : widget.user.name,
                        style: Themes.myTextTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 17)),

                    SizedBox(height: mq.height * 0.002),

                    //display last seen
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? '🟢 Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12))
                  ],
                )
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(
          left: mq.width * 0.02,
          right: mq.width * 0.01,
          bottom: mq.height * 0.002),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              // color: Colors.redAccent,
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined)),

                  //message textfield
                  Expanded(
                      child: Scrollbar(
                    trackVisibility: true,
                    controller: _scrollController,
                    child: TextField(
                      scrollController: _scrollController,
                      //cursor
                      // autofocus: true,
                      // readOnly: true,
                      // textAlign: TextAlign.justify,
                      // maxLength: 100,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      // textInputAction: TextInputAction.newline,
                      showCursor: true,
                      controller: _textController,
                      decoration: const InputDecoration(
                          hintText: "Message", border: InputBorder.none),
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                    ),
                  )),

                  //gallery button
                  IconButton(
                      constraints:
                          BoxConstraints.tightForFinite(width: mq.width * 0.09),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        //uploading images one by one
                        for (var i in images) {
                          print("\nimage path : =====> ${i.path}");
                          //while image is uploading from camera
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          //after image is uploaded from camera
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(Icons.image)),

                  //camera button
                  IconButton(
                      // iconSize: 10,
                      // constraints: BoxConstraints.tightForFinite(
                      //     height: mq.height * 0.05),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);

                        if (image != null) {
                          print("\n");
                          print("Image path =====>${image.path}");
                          //while image is uploading from camera
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(

                              //after image is uploaded from camera
                              widget.user,
                              File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(Icons.camera_alt)),
                  // SizedBox(width: mq.width * 0.01)
                ],
              ),
            ),
          ),

          //send message button
          ElevatedButton(
            onPressed: () {
              //sending the message if not empty
              if (_textController.text.trim().isNotEmpty) {
                if (_list.isEmpty) {
                  //on first message send user to my_users collection of chat user
                  //suppose Tom added Jerry, and texts him, hence Jerry is added to my_users list of Tom
                  //so as soon as Jerry receives the first message from Tom, we need to add Tom to Jerry's my_users list also!
                  APIs.sendFirstMessage(
                      widget.user, _textController.text.trim(), Type.text);
                } else {
                  //simply send message
                  APIs.sendMessage(
                      widget.user, _textController.text.trim(), Type.text);
                }
              }

              _textController.clear();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.deepPurple,
              minimumSize: Size(mq.width * 0.115, mq.width * 0.115),
            ),
            child: Icon(Icons.send_rounded,
                size: mq.width * 0.065, color: Colors.white),
          )

          // MaterialButton(
          //   // height: 80,
          //   onPressed: () {},
          //   materialTapTargetSize: MaterialTapTargetSize.padded,
          //   // minWidth: 20,
          //   minWidth: 10,
          //   shape: const CircleBorder(),
          //   color: Colors.purple,
          //   child:
          //       const Icon(Icons.send_rounded, size: 28, color: Colors.white),
          // )
        ],
      ),
    );
  }
}

//Container when no message is shown
/*
 //   Container(
                          //     alignment: Alignment.center,
                          //     height: mq.height * 0.3,
                          //     width: mq.width * 0.6,
                          //     decoration: BoxDecoration(
                          //         color: Colors.green,
                          //         borderRadius: BorderRadius.circular(20)),
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Text("No messages here yet...",
                          //             style: Themes.myTextTheme.bodySmall!
                          //                 .copyWith(fontWeight: FontWeight.w500)),
                          //         SizedBox(height: mq.height * 0.03),
                          //         Text("Send a message or tap the greeting below",
                          //             style: Themes.myTextTheme.bodySmall!
                          //                 .copyWith(fontWeight: FontWeight.w400),
                          //             textAlign: TextAlign.center),
                          //         SizedBox(height: mq.height * 0.02),
                          //         Image.asset("assets/images/greetings.png",
                          //             height: mq.height * 0.15),
                          //       ],
                          //     ),
                          //   ),\
*/
