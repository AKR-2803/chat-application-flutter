import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/text_type_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/themes.dart';
import '../models/chat_user.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/show_only_profile_picture.dart';

//show the profile info of the user
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum TextTypes { sen, boogaloo, comfortaa }

class _ProfileScreenState extends State<ProfileScreen> {
  //_formKey used to validate and store update profile information
  final _formKey = GlobalKey<FormState>();
  String? setThisTheme;

  //Image picked for profile photo
  String? _image;
  //default selected text theme

  getSelectedTextType() {}

  addStringToSF({required String setTextType}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('textType', setTextType);
  }

  @override
  Widget build(BuildContext context) {
    //provider variable to access textTypeProvider
    final textThemeProvider =
        Provider.of<TextTypeProvider>(context, listen: false);
    String selectedTypeString = sharedPrefs!.getString('textType') ?? "Sen";
    TextTypes? selectedType;
    //ensure that selected textTypes radio list is selected
    if (selectedTypeString == "Sen") {
      selectedType = TextTypes.sen;
    } else if (selectedTypeString == "Boogaloo") {
      selectedType = TextTypes.boogaloo;
    } else if (selectedTypeString == "Comfortaa") {
      selectedType = TextTypes.comfortaa;
    }
    return GestureDetector(
      //hides the keyboard whenever somewhere else is tapped
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        ///If true the [body] and the scaffold's floating widgets should size themselves to avoid the onscreen keyboard
        // For example, if there is an onscreen keyboard displayed above the scaffold, the body can be resized to avoid
        // overlapping the keyboard, which prevents widgets inside the body from being obscured by the keyboard.
        // resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        appBar: AppBar(
          title: const Text("Profile Screen"),
          centerTitle: false,
          // leadingWidth: 0,
          actions: [
            //popup menu from appBar actions
            PopupMenuButton(
              tooltip: "Edit Profile",
              elevation: 3,
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    onTap: () {
                      //as PopupMenuItem pops the screen on click we need to use
                      //addPostFrameCallback to push the alert dialog after that
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return editProfileDialog();
                            });
                      });
                      print("Clicked on edit profile");
                    },
                    height: mq.height * 0.04,
                    child: Text("Edit Profile"),
                  ),
                  PopupMenuItem<int>(
                      onTap: () {
                        //as PopupMenuItem pops the screen on click we need to use
                        //addPostFrameCallback to push the alert dialog after that
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                //Alert Dialog is StateLess Widget, so it will not update the ui...i suggest wrapping the
                                // alert dialog in a StatefulBuilder it will solve your problem.
                                return AlertDialog(
                                  // backgroundColor: Colors.transparent,
                                  // alignment: Alignment.bottomLeft,

                                  // actionsAlignment: MainAxisAlignment.start,
                                  actionsPadding: EdgeInsets.only(
                                      right: mq.width * 0.05,
                                      bottom: mq.height * 0.01),
                                  contentPadding:
                                      EdgeInsets.all(mq.height * 0.01),
                                  title: Row(
                                    children: [
                                      Icon(Icons.abc_rounded, size: 25),
                                      SizedBox(width: mq.width * 0.01),
                                      Text("Choose Text Theme"),
                                    ],
                                  ),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter customeSetState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Material(
                                            child: RadioListTile(
                                                tileColor: Colors.white,
                                                title: const Text("Sen",
                                                    style: TextStyle(
                                                        fontFamily: 'Sen')),
                                                value: TextTypes.sen,
                                                groupValue: selectedType,
                                                onChanged: (TextTypes? value) {
                                                  customeSetState(() {
                                                    selectedType = value;
                                                  });
                                                }),
                                          ),
                                          Material(
                                            child: RadioListTile(
                                                tileColor: Colors.white,
                                                title: const Text("Boogaloo",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Boogaloo')),
                                                value: TextTypes.boogaloo,
                                                groupValue: selectedType,
                                                onChanged: (TextTypes? value) {
                                                  print(
                                                      "boogaloo onChanged method<=======================");
                                                  customeSetState(() {
                                                    selectedType = value;
                                                  });
                                                }),
                                          ),
                                          Material(
                                            child: RadioListTile(
                                                tileColor: Colors.white,
                                                title: const Text("Comfortaa",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Comfortaa')),
                                                value: TextTypes.comfortaa,
                                                groupValue: selectedType,
                                                onChanged: (TextTypes? value) {
                                                  print(
                                                      "Comfortaa onChanged method<=======================");
                                                  customeSetState(() {
                                                    selectedType = value;
                                                  });
                                                }),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          //getting the fontFamily name string
                                          if (selectedType == TextTypes.sen) {
                                            setThisTheme = 'Sen';
                                            //changing UI using provider
                                            textThemeProvider.setTextType(
                                                setThisTextType: setThisTheme);
                                            //setting text type in Shared Preferences
                                            sharedPrefs!.setString(
                                                'textType', setThisTheme!);
                                          } else if (selectedType ==
                                              TextTypes.boogaloo) {
                                            setThisTheme = 'Boogaloo';
                                            textThemeProvider.setTextType(
                                                setThisTextType: setThisTheme);
                                            //setting text type
                                            sharedPrefs!.setString(
                                                'textType', setThisTheme!);
                                          } else if (selectedType ==
                                              TextTypes.comfortaa) {
                                            setThisTheme = 'Comfortaa';
                                            textThemeProvider.setTextType(
                                                setThisTextType: setThisTheme);
                                            //setting text type
                                            sharedPrefs!.setString(
                                                'textType', setThisTheme!);
                                          }
                                          // setState(() {});
                                          Navigator.pop(context);
                                          print(
                                              "seleted type was  ========> $selectedType");
                                        },
                                        child: Text("SET")),
                                  ],
                                );
                              });
                        });
                        print("Clicked on edit profile");
                      },
                      height: 50,
                      child: Text("Text Theme")),
                ];
              },
            ),
            // PopupMenuButton(
            //   tooltip: "Choose Theme",
            //   elevation: 3,
            //   itemBuilder: (context) {
            //     return [];
            //   },
            // ),
          ],
        ),
        //button to add new user
        floatingActionButton: Padding(
          padding:
              EdgeInsets.only(bottom: mq.height * 0.04, right: mq.width * 0.04),
          child: FloatingActionButton.extended(
            elevation: 3,
            backgroundColor: Colors.redAccent,
            //sign out method on floating action button temporarily
            onPressed: () async {
              print("\nEntered logout function.................");
              //showing progress dialog
              Dialogs.showProgressBar(context);

              //on pressing sign out user status changes to offline
              await APIs.updateActiveStatus(false);

              //sign out from the application
              await APIs.auth.signOut().then((value) async {
                print("\nCalled auth.SignOut function.................");
                await GoogleSignIn().signOut().then((value) {
                  print(
                      "\nCalled GoogleSignIn.SignOut function.................");
                  //hiding the progress dialog
                  Navigator.pop(context);
                  print("\nRemoving dialog................");
                  //removing home screen from stack
                  Navigator.pop(context);

                  //initializing the auth instance again after signOut
                  //so that it doesn't store old info even after sign out
                  APIs.auth = FirebaseAuth.instance;

                  print("\nRemoved Home Screen from stack................");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                  print("\nBack to Login Screen................");
                });
              });
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Logout"),
          ),
        ),
        body: SingleChildScrollView(
          //horizontal padding of the whole profile screen body
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
          child: Column(children: [
            //adding space in the beginning
            SizedBox(height: mq.height * 0.03),
            Stack(alignment: AlignmentDirectional.bottomEnd, children: [
              //profile photo
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
                        print("Clicked on the profile picture <======");
                        // Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              //display enlarged profile picture
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
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                    ),

              //edit profile picture
              MaterialButton(
                onPressed: () {
                  _showBottomSheet();
                },
                shape: const CircleBorder(),
                color: Colors.white,
                //camera icon similar to WhatsApp
                child: const Icon(Icons.camera_alt_rounded),
              ),
            ]),

            Divider(height: mq.height * 0.08, thickness: 1),
///////////////////////////////////////////////////////////////////////////////
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person),
                SizedBox(width: mq.width * 0.05),
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    readOnly: true,
                    initialValue: "${widget.user.name.trim()}",
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: " Name",
                      labelStyle: TextStyle(),
                      // filled: true,
                      // fillColor: Corlor.fromARGB(255, 232, 232, 232),
                      border: InputBorder.none,
                    ),
                    // enabled: false,
                  ),
                ),
              ],
            ),

            Divider(height: mq.height * 0.03),

            // SizedBox(height: mq.height * 0.02),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.email_rounded),
                SizedBox(width: mq.width * 0.05),
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    readOnly: true,
                    onTap: null,
                    initialValue: "${widget.user.email.trim()}",
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: " Email",
                      labelStyle: TextStyle(),
                      // filled: true,
                      // fillColor: Corlor.fromARGB(255, 232, 232, 232),
                      border: InputBorder.none,
                    ),
                    // enabled: false,
                  ),
                ),
              ],
            ),
            Divider(height: mq.height * 0.03),
            // SizedBox(height: mq.height * 0.02),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info),
                SizedBox(width: mq.width * 0.05),
                Expanded(
                  child: TextFormField(
                    maxLines: null,
                    // keyboardType: TextInputType.multiline,
                    //disable text input
                    enabled: false,
                    // readOnly: true,
                    onTap: () {},
                    initialValue: "${widget.user.about.trim()}",
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: " About",
                      // filled: true,
                      // fillColor: Corlor.fromARGB(255, 232, 232, 232),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

/////////////////////////////////////////////////////////////////////
/////////////////////////Name and About Textfields///////////////////
/////////////////////////////////////////////////////////////////////

            SizedBox(height: mq.height * 0.05),
          ]),
        ),
      ),
    );
  }

  void _showBottomSheet() {
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
            padding: EdgeInsets.only(
                top: mq.height * 0.008, bottom: mq.height * 0.03),
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.005, horizontal: mq.width * 0.4),
                height: mq.height * 0.007,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(mq.width * 0.01)),
              ),
              SizedBox(height: mq.height * 0.01),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              Text("Pick Profile Photo",
                  textAlign: TextAlign.center,
                  style: Themes.myTextTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.w500)),
              // SizedBox(width: mq.width * 0.02),
              //tooltip suggesting maximum file size 100KB
              // const Tooltip(
              //     message: "Maximum File Size is 100KB",
              //     child: Icon(Icons.info_rounded))
              // ],
              // ),
              SizedBox(height: mq.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick photo from gallery
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            //reducing image quality to 70, ranges from 0-100
                            imageQuality: 70);

                        //size in KB
                        // final fileBytes =
                        //     File(_image!).readAsBytesSync().lengthInBytes /
                        //         1024;

                        // int size in KB
                        // final int intFileBytes = fileBytes.toInt();
                        // print(
                        //     "===> File Size in kB : $intFileBytes KB, in MB :${(intFileBytes / 1048576)} MB");
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          print(
                              "\n\n\nImage path =====>${image.path} ---- Mimetype ====> ${image.mimeType}");

                          if (!mounted) return;
                          //hiding bottomsheet
                          Navigator.pop(context);
                          Dialogs.showSnackBar(
                              context,
                              "Profile Picture updated successfully!",
                              const Duration(milliseconds: 800));
                        }
                        // else {
                        //   Dialogs.showSnackBar(context,
                        //       "Image file exceeds maximum limit of 100KB");
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * 0.25, mq.height * 0.15)),
                      child: Image.asset("assets/images/gallery.png")),

                  //pick photo from camera
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          print("\n\n\n");
                          print("Image path =====>${image.path}");
                          //hiding bottomsheet
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * 0.25, mq.height * 0.15)),
                      child: Image.asset("assets/images/camera.png")),
                ],
              ),
            ],
          );
        });
  }

  Widget editProfileDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mq.height * 0.01)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
          // style: ElevatedButton.styleFrom(
          //     shape: const StadiumBorder(),
          //     minimumSize: Size(mq.width * 0.4, mq.height * 0.06)),
        ),
        TextButton(
          onPressed: () {
            //if form is validated
            if (_formKey.currentState!.validate()) {
              print("\n\n=========> Inside validator <=========");
              _formKey.currentState!.save();
              print(
                  "\n\nForm current state =========> ${_formKey.currentState}");
              //close the dialog profile is updated
              APIs.updateUserInfo().then((value) => Navigator.pop(context));
              print("\n\n=========> Data updated <=========");
              setState(() {});
              Dialogs.showSnackBar(context, "Profile Updated Successfully!",
                  const Duration(milliseconds: 800));
            }
            // setState(() {});
          },
          child: Text("Update"),
          // style: ElevatedButton.styleFrom(
          //     shape: const StadiumBorder(),
          //     minimumSize: Size(mq.width * 0.4, mq.height * 0.06)),
        ),
      ],
      title: Row(
        children: [
          Icon(Icons.edit_note_sharp, size: 25),
          SizedBox(width: mq.width * 0.01),
          Text("Edit Profile"),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: mq.height * 0.01),
            TextFormField(
              textInputAction: TextInputAction.done,
              //maximum characters allowed
              maxLength: 30,
              maxLines: null,
              initialValue: widget.user.name,
              //silly mistake done by me => APIs.me.name == val (double equal to)
              onSaved: (val) => APIs.me.name = val ?? '',
              validator: (val) => val != null && val.isNotEmpty
                  ? null
                  : "Username can't be empty",
              decoration: InputDecoration(
                errorStyle: TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.person, color: Colors.black),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Eg. Aaryaveer Rajput",
                label: const Text("Username"),
              ),
            ),
            SizedBox(height: mq.height * 0.03),
            //about textfield
            TextFormField(
              textInputAction: TextInputAction.done,
              //maximum characters allowed
              maxLength: 100,
              minLines: 1,
              maxLines: 3,
              // expands: true,
              //silly mistake done by me => APIs.me.name == val (double equal to)
              initialValue: widget.user.about,
              onSaved: (val) => APIs.me.about = val ?? '',
              validator: (val) =>
                  val != null && val.isNotEmpty ? null : "About can't be empty",
              decoration: InputDecoration(
                errorStyle: TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.info, color: Colors.black),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Eg. Feeling Happy",
                label: const Text("About"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appTextStyle() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mq.height * 0.02)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20),
      actions: [],
      title: Row(
        children: [
          Icon(Icons.abc_rounded, size: 25),
          SizedBox(width: mq.width * 0.01),
          Text("Choose Text Theme"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }

// gOGrSwljvvW6dFFAY2SIIAROxUH2_6BySu3e1IoYdb0KxB7JBpgQcIM22/
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


  TextFormField(
                initialValue: widget.user.name,
                //silly mistake done by me => APIs.me.name == val (double equal to)
                onSaved: (val) => APIs.me.name = val ?? '',
                validator: (val) =>
                    val != null && val.isNotEmpty ? null : "Required Field",
                decoration: InputDecoration(
                  // errorStyle: Themes.myTextTheme.titleSmall,
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: "Eg. Aaryaveer Rajput",
                  label: const Text("Name"),
                ),
              ),
              SizedBox(height: mq.height * 0.02),
              //about textfield
              TextFormField(
                initialValue: widget.user.about,
                onSaved: (val) => APIs.me.about = val ?? '',
                validator: (val) =>
                    val != null && val.isNotEmpty ? null : "Required Field",
                decoration: InputDecoration(
                  // errorStyle: Themes.myTextTheme.titleSmall,
                  prefixIcon: const Icon(Icons.info, color: Colors.black),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: "Eg. Feeling Happy",
                  label: const Text("About"),
                ),
              ),

*/
