import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../screens/profile_screen.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import '../api/apis.dart';
import '../helper/themes.dart';
import '../helper/dialogs.dart';
import '../main.dart';

//home screen of the app showing available contact chats
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  // ChatUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //storing users
  List<ChatUser> _list = [];

  //storing searched items
  final List<ChatUser> _searchList = [];

  //search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //setting user active status when the screen is active, running in background, or inactive.
    //updating user active status according to lifecycle events
    //resume -- active or online (screen active)
    //pause -- inactive or offline (screen in background)
    SystemChannels.lifecycle.setMessageHandler((message) {
      //message : AppLifecycleState.resumed
      //..........AppLifecycleState.paused
      //..........AppLifecycleState.inactive
      print("======> \n\nMessage in system Channels : ====> $message");

      if (APIs.auth.currentUser != null) {
        //is screen is active update active status to Online, i.e. isOnline = true
        if (message.toString().contains('resume')) {
          print("message is  =======================> $message");
          APIs.updateActiveStatus(true);
        }
        //is screen is inactive/in background update active status to offline, i.e. isOnline = false
        //in this case last seen time of the user will be shown
        if (message.toString().contains('pause')) {
          print("message is  =======================> $message");
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      //hides the keyboard whenever somewhere else is tapped
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is active and back button is pressed close the search
        //else simply pop the current screen like normal scenario
        //NOTE: WillPopScope is only applicable to the  its  child scaffold, i.e. current screen
        onWillPop: () {
          //returning false will NEVER let you pop the screen!
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: mq.width * 0.11,
            leading: Padding(
              padding: EdgeInsets.only(left: mq.height * 0.015),
              child: Image.asset(
                "assets/images/appicon.png",
                height: mq.height * 0.01,
                width: mq.height * 0.01,
              ),
            ),
            title: _isSearching
                ? TextField(
                    //autofocuse enables : display cursor and open keyboard
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Name, email..."),
                    //update search list as search text changes
                    onChanged: (val) {
                      //searching logic
                      //clear the list, ready for new search
                      _searchList.clear();
                      //matching name or email
                      for (var item in _list) {
                        if (item.name
                                .toLowerCase()
                                .contains(val.toLowerCase()) ||
                            item.email
                                .toLowerCase()
                                .contains(val.toLowerCase())) {
                          _searchList.add(item);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text("Chat App"),
            actions: [
              //search users
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              //profile screen
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: Icon(Icons.person_2_rounded)
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(APIs.me.image),
                  // ),
                  ),
              SizedBox(width: mq.width * 0.015)
            ],
          ),
          //button to add new user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
                bottom: mq.height * 0.02, right: mq.width * 0.04),
            child: FloatingActionButton(
                //sign out method on floating action button temporarily
                onPressed: () async {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.person_add_alt_1_rounded)),
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  //if some data is loaded show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    print("===================> inside 2nd streambuilder");
                    /////////////////////////////////////////////////////////////
                    //Imp. If there are no users in the my_users list,
                    //show No Connections found
                    return snapshot.data!.docs.length == 0
                        ? Center(
                            child: Text(
                                "No Connections Found\n\nAdd someone by tapping\nthe button below",
                                textAlign: TextAlign.center))
                        : StreamBuilder(
                            stream: APIs.getAllUsers(
                                snapshot.data?.docs.map((e) => e.id).toList() ??
                                    []),

                            //get only those users whose ids are provided
                            builder: (context, snapshot) {
                              //
                              print(
                                  "===================> inside 2nd streambuilder BUilder");
                              switch (snapshot.connectionState) {
                                //if data is loading
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                // return const Center(
                                //     child:
                                //         CircularProgressIndicator(strokeWidth: 2));
                                //if some data is loaded show it
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  //data from firestore database in Json format
                                  final data = snapshot.data?.docs;
                                  //mapping json data to List using fromJson method
                                  _list = data
                                          ?.map((e) =>
                                              ChatUser.fromJson(e.data()))
                                          .toList() ??
                                      [];

                                  // if (_list.isNotEmpty) {
                                  return ListView.builder(
                                      padding: EdgeInsets.only(
                                          top: mq.height * 0.01),
                                      physics: const BouncingScrollPhysics(
                                          decelerationRate:
                                              ScrollDecelerationRate.normal),
                                      //is searching is ON, fetch list from _searchList
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : _list.length,
                                      itemBuilder: (context, index) {
                                        // return Text("${list[index]}");
                                        return ChatUserCard(
                                            user: _isSearching
                                                ? _searchList[index]
                                                : _list[index]);
                                      });
                                // }
                                // else {
                                //   return Center(
                                //       child: Text(
                                //           "No Connections Found\n\nAdd someone by tapping the button below",
                                //           textAlign: TextAlign.center,
                                //           style: Themes.myTextTheme.bodySmall!
                                //               .copyWith(
                                //                   fontWeight:
                                //                       FontWeight.w500)));
                                // }
                              }
                            },
                          );
                }
              }),
        ),
      ),
    );
  }

  //for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              // actionsPadding: EdgeInsets.zero,

              contentPadding: EdgeInsets.only(
                  left: mq.width * 0.04,
                  right: mq.width * 0.04,
                  top: 20,
                  bottom: mq.height * .01),
              // elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mq.width * 0.04)),
              title: Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 27),
                  SizedBox(width: mq.width * .02),
                  Text("Add User",
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
                //the keyboard submit button action
                //look at the enter of the keyboard in your device
                // textInputAction: TextInputAction.done,
                // keyboardType: ,
                textInputAction: TextInputAction.done,
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      color: Colors.black87,
                    ),
                    hintText: "Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(mq.width * 0.05))),
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                //adding new user to chat
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      //email regex to validate email
                      //make sure to add .trim() method to
                      //remove extra leading and trailing spaces
                      if (email.isNotEmpty &&
                          RegExp(r'\S+@\S+\.\S+')
                              .hasMatch(email.toLowerCase().trim())) {
                        print(
                            "===================> Inside valid email function <================");
                        await APIs.addChatUser(email.toLowerCase().trim())
                            .then((value) {
                          if (!value) {
                            Dialogs.showErrorSnackBar(context,
                                'User does not exist', Duration(seconds: 1));
                          } else {
                            Dialogs.showSnackBar(
                                context,
                                'User added successfully!',
                                Duration(seconds: 1));
                          }
                        });
                        print(
                            "==============> User add function done <================");
                      }
                      //show error snackBar
                      else {
                        Dialogs.showErrorSnackBar(context,
                            "Enter a valid Email", Duration(seconds: 1));
                        print(
                            "================================> Invalid email <================================");
                      }

                      // APIs.sendMessage(widget.user, "Hi there!", Type.text);
                    },
                    child: Text("Add")),
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
