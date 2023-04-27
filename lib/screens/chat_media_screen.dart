import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../helper/themes.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/show_only_profile_picture.dart';

//screen showing media of a specific chat
// ignore: must_be_immutable
class ChatMediaScreen extends StatefulWidget {
  ChatMediaScreen({super.key, required this.user, required this.mediaList});
  ChatUser user;
  List<String> mediaList;
  @override
  State<ChatMediaScreen> createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // widget.mediaList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Media"),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: mq.height * 0.02, horizontal: mq.width * 0.035),
        child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //
              //profile picture
              //
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
                    width: mq.height * 0.18,
                    height: mq.height * 0.18,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),
              SizedBox(height: mq.height * 0.01),
              //
              //username
              //
              Text(widget.user.name,
                  style: Themes.myTextTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.w500)),
              SizedBox(height: mq.height * 0.01),
              //
              //email
              //
              Text(widget.user.email,
                  style: Themes.myTextTheme.bodySmall!.copyWith(
                      color: Color.fromRGBO(0, 0, 0, 0.541), fontSize: 14)),

              Divider(height: mq.height * 0.04, thickness: 1),
              //
              //about
              //

              Scrollbar(
                controller: _scrollController,
                child: TextFormField(
                  scrollController: _scrollController,
                  maxLines: 2,
                  // keyboardType: TextInputType.multiline,
                  enabled: false,
                  // readOnly: true,
                  onTap: () {},
                  initialValue: "${widget.user.about}",
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    labelText: " About",
                    labelStyle: TextStyle(fontSize: 20),
                    // filled: true,
                    // fillColor: Corlor.fromARGB(255, 232, 232, 232),
                    border: InputBorder.none,
                  ),
                ),
              ),

              Divider(height: mq.height * 0.03),

              // TextFormField(
              //   maxLines: 2,
              //   readOnly: true,
              //   onTap: null,
              //   initialValue: "${widget.user.about}",
              //   decoration: InputDecoration(
              //       contentPadding: EdgeInsets.zero,
              //       labelText: " About",
              //       labelStyle: TextStyle(),
              //       // filled: true,
              //       // fillColor: Corlor.fromARGB(255, 232, 232, 232),
              //       border: OutlineInputBorder(
              //           borderSide: BorderSide.none,
              //           borderRadius: BorderRadius.circular(20))),
              //   // enabled: false,
              // ),
              // SizedBox(height: mq.height * 0.02),

              //|||||||||||||||||||||||||||
              //|||Media, links, docs||||||
              //|||||||||||||||||||||||||||
              SizedBox(
                height: mq.width * 0.25,
                width: double.infinity,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: null,
                  title: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Media, links, and docs",
                        style: TextStyle(color: Colors.black45),
                      )),
                  subtitle: widget.mediaList.length != 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          // reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.mediaList.length,
                          itemBuilder: (context, index) {
                            print(
                                "inside itembuilder of media <=================");
                            if (widget.mediaList.isNotEmpty) {
                              print(
                                  "length  ===> ====>[${widget.mediaList.length}]");
                              print(
                                  "list of images ===> ====>[${widget.mediaList[index]}]");
                              return ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.02),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(mq.height * 0.01),
                                    //display profile picture
                                    child: CachedNetworkImage(
                                      height: mq.width * 0.25,
                                      width: mq.width * 0.25,
                                      fit: BoxFit.cover,
                                      //url to the images
                                      imageUrl: widget.mediaList[index],
                                      // placeholder: (context, url) => CircularProgressIndicator(),
                                      progressIndicatorBuilder:
                                          (context, url, donloadProgress) {
                                        return Container(
                                          color: Colors.blueGrey,
                                        );
                                      },
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                              child:
                                                  Icon(CupertinoIcons.person)),
                                    ),
                                  ),
                                ),
                              );
                            }
                            print(
                                "No media found..................<===================");
                            //showing Card when no message is present
                            return Center(child: Text("No media to show"));
                          },
                        )
                      :
                      //if no media is found
                      Center(
                          child: Text("No media",
                              style: Themes.myTextTheme.bodySmall!
                                  .copyWith(color: Colors.black54))),
                ),
              ),
              //space between block report buttons and above
              SizedBox(height: mq.height * 0.18),
              //block and report button
              Divider(height: mq.height * 0.03),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    TextButton.icon(
                        style: TextButton.styleFrom(
                            iconColor: Colors.red, foregroundColor: Colors.red),
                        onPressed: () {
                          Dialogs.showErrorSnackBar(
                              context,
                              "This feature is yet to be implemented",
                              Duration(seconds: 1));
                        },
                        icon: Icon(Icons.block_rounded),
                        label: Text("Block ${widget.user.name}")),
                    TextButton.icon(
                        style: TextButton.styleFrom(
                            iconColor: Colors.red, foregroundColor: Colors.red),
                        onPressed: () {
                          Dialogs.showErrorSnackBar(
                              context,
                              "This feature is yet to be implemented",
                              Duration(seconds: 1));
                        },
                        icon: Icon(Icons.thumb_down_alt_rounded),
                        label: Text("Report ${widget.user.name}")),
                  ],
                ),
              )

              ////////////////////////////////////////////////////////////////////////////////////
              ////////////////////////////////////////////////////////////////////////////////////
            ]),
      ),
    );
  }
}
