import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../api/apis.dart';
import '../models/message.dart';
import '../helper/themes.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  //incoming message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different

    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print("=====================>Message read updated");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ////////////////////////////////////////////////////////
        Padding(
          //minimum padding required for the incoming messages

          padding: EdgeInsets.only(right: mq.width * 0.15),
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.01
                : mq.width * 0.02),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
            decoration: BoxDecoration(
                color: Colors.blue.shade300,
                border: Border.all(color: Colors.deepPurple, width: 1),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15))),

            //checking whether message is text or image
            child: widget.message.type == Type.text

                //show text
                ? Text(widget.message.msg,
                    style: Themes.myTextTheme.bodySmall!
                        .copyWith(color: Colors.white, fontSize: 16))

                //show image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(

                        //change this to adjust image such that it doesnt get cropped
                        //as well as looks proper in the UI
                        //max allowed height
                        maxHeightDiskCache: (mq.height * 0.4).toInt(),
                        // maxWidthDiskCache: 200,
                        // height: mq.height * 0.4,
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
            /* 
               ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(

                        //change this to adjust image such that it doesnt get cropped
                        //as well as looks proper in the UI
                        //max allowed height
                        maxHeightDiskCache: (mq.height * 0.4).toInt(),
                        // maxWidthDiskCache: 200,
                        // height: mq.height * 0.4,
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
              */
          ),
        ),

        //display sent/received time and read status icon
        Align(
          //to align the time/icon to the right
          alignment: Alignment.centerLeft,
          //padding the card from right so it aligns vertically with the message
          child: Padding(
            padding: EdgeInsets.only(left: mq.width * 0.033),
            child: Card(
              elevation: 1,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: EdgeInsets.all(mq.width * 0.01),
                child:
                    //timestamp of sent message
                    Text(
                        MyDateUtil.getFormattedTime(
                            context: context,
                            unformattedTime: widget.message.sent),
                        style: Themes.myTextTheme.bodySmall!.copyWith(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                //horizontal gap between time and icon
                //status of message read
                // const Icon(Icons.done_all_rounded, color: Colorss.lightBlue),
              ),
            ),
          ),
        ),
      ],
    );
  }

//outgoing message
  Widget _greenMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ////////////////////////////////////////////////////////////////
        Padding(
          //minimum padding required for the outgoing messages
          padding: EdgeInsets.only(left: mq.width * 0.15),
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.01
                : mq.width * 0.02),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
            decoration: BoxDecoration(
                color: Colors.green.shade300,
                border: Border.all(color: Colors.deepPurple, width: 1),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))),
            child: widget.message.type == Type.text

                //show text
                ? Text(widget.message.msg,
                    style: Themes.myTextTheme.bodySmall!
                        .copyWith(color: Colors.white, fontSize: 16))

                //show image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(
                        //change this to adjust image such that it doesnt get cropped
                        //as well as looks proper in the UI
                        //max allowed height
                        maxHeightDiskCache: (mq.height * 0.4).toInt(),
                        // maxWidthDiskCache: 200,
                        // height: mq.height * 0.4,
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
          ),
        ),

        //display time and read status icon
        Align(
          //to align the time/icon to the right
          alignment: Alignment.centerRight,
          //padding the card from right so it aligns vertically with the message
          child: Padding(
            padding: EdgeInsets.only(right: mq.width * 0.033),
            child: Card(
              elevation: 1,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * 0.01),
                child: Row(
                  //only take the space required by the children
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //timestamp of sent message
                    Text(
                        MyDateUtil.getFormattedTime(
                            context: context,
                            unformattedTime: widget.message.sent),
                        style: Themes.myTextTheme.bodySmall!.copyWith(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                    //horizontal gap between time and icon
                    SizedBox(width: mq.width * 0.02),
                    //double tick blue/status of message read

                    Icon(Icons.done_all_rounded,
                        color: widget.message.read.isNotEmpty
                            ? Colors.lightBlue
                            : Colors.black38,
                        size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        ////////////////////////////////////
        ////////////////////////////////////
        ////////////////////////////////////
      ],
    );
  }

//bottomsheet for modifying message/view details

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          //container won't render the borderradius as it will paint its color over it
          //hence use something else other than container
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.01, horizontal: mq.width * 0.4),
                height: mq.height * 0.007,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(mq.width * 0.01)),
              ),

              widget.message.type == Type.text
                  ? //copy message option
                  _OptionItem(
                      icon: Icon(Icons.copy_all_rounded, color: Colors.blue),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //hiding bottomsheet after text copied
                          Navigator.pop(context);
                          //custom centered snackbar for text copied
                          //show snackbar Text Copied!
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //   content: Text("Text Copied!",
                          //       textAlign: TextAlign.center,
                          //       style: TextStyle(fontWeight: FontWeight.w500)),
                          //   width: mq.width * 0.3,
                          //   duration: Duration(milliseconds: 350),
                          //   shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(15)),
                          //   backgroundColor: const Color(0xFFA841FC),
                          //   // backgroundColor: Colors.blueGrey,
                          //   behavior: SnackBarBehavior.floating,
                          // ));
                          Dialogs.showSnackBar(context, 'Text Copied!',
                              Duration(milliseconds: 500));
                        });
                      })
                  : _OptionItem(
                      icon: Icon(Icons.download_rounded, color: Colors.blue),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'AKR Chat App')
                              .then((bool? success) {
                            //for hiding bottomsheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackBar(
                                  context,
                                  'Image saved successfully!',
                                  Duration(seconds: 1));
                            }
                          });
                        } catch (e) {
                          print("Error in Saving image : $e");
                        }
                      }),
              Divider(
                  thickness: 0.5,
                  color: Colors.blueGrey,
                  endIndent: mq.width * .05,
                  indent: mq.width * .05),

              if (widget.message.type == Type.text && isMe)
                //edit message option
                _OptionItem(
                    icon: Icon(Icons.edit_note_rounded, color: Colors.blueGrey),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottomsheet
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),

              if (isMe)
                //delete message option
                _OptionItem(
                  icon: Icon(Icons.delete_forever_rounded,
                      color: Colors.redAccent),
                  name: 'Delete Message',
                  onTap: () async {
                    //for hiding bottomsheet
                    if (mounted) {
                      Navigator.pop(context);
                      await APIs.deleteMessage(widget.message).then((value) {
                        Dialogs.showSnackBar(
                            context, 'Message Deleted!', Duration(seconds: 1));
                      });
                    }
                  },
                ),

              if (isMe)
                //separator line
                Divider(
                    thickness: 0.5,
                    color: Colors.blueGrey,
                    endIndent: mq.width * .05,
                    indent: mq.width * .05),

              //sent time
              _OptionItem(
                  icon: Image.asset(
                      isMe
                          ? "assets/images/sent.png"
                          : "assets/images/received.png",
                      color: Color.fromARGB(255, 61, 182, 196),
                      height: 28,
                      width: 28),
                  //if I sent it, show sent at else received at
                  name: isMe
                      ? 'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}'
                      : 'Received At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: Image.asset("assets/images/read.png",
                      color: Colors.green, height: 28, width: 28),
                  name: widget.message.read.isEmpty
                      ? 'Read At : not seen yet'
                      : 'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating messages
  //this feature is just for understanding purpose and has NO real use case
  //as the text messages once sent should not be allowed to update

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              // actionsPadding: EdgeInsets.zero,

              contentPadding: EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: mq.height * .01),
              // elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.message_rounded, size: 27),
                  SizedBox(width: mq.width * .02),
                  Text("Update Message",
                      style: Themes.myTextTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              //tooltip for future
              // Text("Once changed, your message will be marked as updated",
              //     style: Themes.myTextTheme.bodySmall!.copyWith(
              //         fontWeight: FontWeight.w400,
              //         fontStyle: FontStyle.italic)),
              //on tapping this button send an initial message

              content: TextFormField(
                autofocus: true,
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => {updatedMsg = value},
                decoration: InputDecoration(
                    hintText: "Updated Message",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(mq.width * 0.05))),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // APIs.sendMessage(widget.user, "Hi there!", Type.text);
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      //popping the alert dialog
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg)
                          .then((value) {
                        Dialogs.showSnackBar(
                            context, 'Message updated!', Duration(seconds: 1));
                      });
                      // APIs.sendMessage(widget.user, "Hi there!", Type.text);
                    },
                    child: Text("Update")),
              ],
              // Row(
              //   children: [
              //     Icon(Icons.message_rounded),
              //     SizedBox(width: mq.width * 0.02),
              //     Text("Update Message")
              //   ],
              // ),
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Widget icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    //alternative idea
    //show a row of copy, edit, delete icons(big icons), each with their names on the bottom
    //smtg like this :
    //   ____   ____   ____
    //  |    | |    | |    |
    //  |____| |____| |____|
    //   copy   edit  delete
    //like 3 big square buttons, and jsut display sent and ready by below,
    //will look much nicer in terms of UI
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .01,
            bottom: mq.height * .016),
        child: Row(
          children: [
            icon,
            SizedBox(width: mq.width * .04),
            Flexible(
                child: Text("$name",
                    style: Themes.myTextTheme.bodySmall!
                        .copyWith(fontWeight: FontWeight.w400))),
          ],
        ),
      ),
    );
  }
}

// widget blue message
/*

 //incoming message
  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ////////////////////////////////////////////////////////////////
        //incoming message UI

        Flexible(
          child: Container(
              // alignment: Alignment.centerLeft,
              // height: mq.height * 0.05,
              padding: EdgeInsets.all(mq.width * 0.02),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.shade300,
                  border: Border.all(color: Colors.deepPurple, width: 1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              //display the message content
              child: Text(widget.message.msg,
                  style: Themes.myTextTheme.bodySmall!
                      .copyWith(color: Colors.white))),
        ),

        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            widget.message.sent,
            style:
                Themes.myTextTheme.bodySmall!.copyWith(color: Colors.black54),
          ),
        ),
      ],
    );
  }



 */

//outgoing message UI
/*
Column(
      mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.end,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ////////////////////////////////////////////////////////////////
        //outgoing message UI
        // Padding(
        //   padding: EdgeInsets.only(left: mq.width * 0.04),
        //   child: Text(
        //     widget.message.sent,
        //     style:
        //         Themes.myTextTheme.bodySmall!.copyWith(color: Colors.black54),
        //   ),
        // ),

        ////////////////////////////////////
        ////////////////////////////////////
        ////////////////////////////////////
        ///

        // Padding(
        //   padding: EdgeInsets.only(right: mq.width * 0.04),
        //   child: Text(
        //     widget.message.sent,
        //     style:
        //         Themes.myTextTheme.bodySmall!.copyWith(color: Colors.black54),
        //   ),
        // ),
        // Expanded(flex: 1, child: SizedBox()),

        Container(
          // alignment: Alignment.centerRight,
          // alignment: Alignment.centerLeft,
          // height: mq.height * 0.25,
          padding: EdgeInsets.all(mq.width * 0.02),
          margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
          decoration: BoxDecoration(
              color: Colors.blue.shade300,
              border: Border.all(color: Colors.deepPurple, width: 1),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15))),
          child: Text(widget.message.msg,
              style: Themes.myTextTheme.bodySmall!
                  .copyWith(color: Colors.white, fontSize: 16)),
        ),

        //display time and read status icon
        Align(
          //to align the time/icon to the right
          alignment: Alignment.centerRight,
          //padding the card from right so it aligns vertically with the message
          child: Padding(
            padding: EdgeInsets.only(right: mq.width * 0.033),
            child: Card(
              elevation: 3,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * 0.01),
                child: Row(
                  //only take the space required by the children
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //timestamp of sent message
                    Text(widget.message.sent,
                        style: Themes.myTextTheme.bodySmall!.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    //horizontal gap between time and icon
                    SizedBox(width: mq.width * 0.02),
                    //status of message read
                    const Icon(Icons.done_all_rounded, color: Colors.lightBlue),
                  ],
                ),
              ),
            ),
          ),
        ),

        ////////////////////////////////////
        ////////////////////////////////////
        ////////////////////////////////////
      ],
    );
  
 */

//old flexible containers
/*
        // Flexible(
        //   child: Container(
        //       // alignment: Alignment.centerLeft,
        //       // height: mq.height * 0.05,
        //       padding: EdgeInsets.all(mq.width * 0.02),
        //       margin: EdgeInsets.symmetric(
        //           horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
        //       decoration: BoxDecoration(
        //           color: Colors.deepPurple.shade900,
        //           border: Border.all(color: Colors.purple, width: 1),
        //           borderRadius: const BorderRadius.only(
        //               topLeft: Radius.circular(15),
        //               topRight: Radius.circular(15),
        //               bottomLeft: Radius.circular(15))),
        //       //display the message content
        //       child: Text(widget.message.msg,
        //           style: Themes.myTextTheme.bodySmall!
        //               .copyWith(color: Colors.white))),
        // ),

*/
/*



 Flexible(
          child: Container(
              // alignment: Alignment.centerLeft,
              // height: mq.height * 0.25,
              // padding: EdgeInsets.all(mq.width * 0.02),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.shade300,
                  border: Border.all(color: Colors.deepPurple, width: 1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(mq.width * 0.02),
                    child: Text(widget.message.msg,
                        style: Themes.myTextTheme.bodySmall!
                            .copyWith(color: Colors.white, fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: mq.height * 0.005),
                    child: Text(widget.message.sent,
                        style: Themes.myTextTheme.bodySmall!
                            .copyWith(color: Colors.white70, fontSize: 13)),
                  ),
                ],
              )),
        ),





//either do the whatsapp telegram like timestamp but figure
      // out how the container will be prevented from overflow
      //the video uses whole row with message and timestamp on either
      //sides, hence he doesn't face this issue
     

*/
// Row(
//   crossAxisAlignment: CrossAxisAlignment.end,
//   children: [
//     Padding(
//       padding: EdgeInsets.all(mq.width * 0.02),
//       child: Text(widget.message.msg,
//           style: Themes.myTextTheme.bodySmall!
//               .copyWith(color: Colors.white, fontSize: 16)),
//     ),
//     Padding(
//       padding: EdgeInsets.only(bottom: mq.height * 0.005),
//       child: Text(widget.message.sent,
//           style: Themes.myTextTheme.bodySmall!
//               .copyWith(color: Colors.white70, fontSize: 13)),
//     ),
//   ],
// ),

//download
/*


//gallery with a new album name
                                  ElevatedButton(
                                      onPressed: () async {
                                        //for video
                                        //can change the variable name later
                                        // String imageUrlDownload =
                                        //     "https://samplelib.com/lib/preview/mp4/sample-5s.mp4";
                                        //for image
                                        String imageUrlDownload = snapshot
                                            .data!.data!.memes![index].url
                                            .toString();
                                        final fileName = snapshot
                                            .data!.data!.memes![index].name
                                            .toString();
                                        final tempDirectory =
                                            await getExternalStorageDirectory();
                                        final filePath =
                                            '${tempDirectory!.path}/$fileName.jpg';
                                        debugPrint(
                                            ".......................$filePath");
                                        await Dio().download(
                                            imageUrlDownload, filePath);
                                        debugPrint(
                                            "file path : .................$filePath");
                                        //saveVideo for video
                                        //makes a directory in gallery with the following name
                                        //and stores the images/videos there
                                        await GallerySaver.saveImage(filePath,
                                            albumName: "FlutterImages");
                                      },
                                      child: Text("Download")),

                                  */
