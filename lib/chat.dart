// ignore_for_file: deprecated_member_use, unnecessary_const, sized_box_for_whitespace, unnecessary_new, sort_child_properties_last, non_constant_identifier_names, use_key_in_widget_constructors, no_logic_in_create_state, unnecessary_string_interpolations, unused_field, use_build_context_synchronously, unused_local_variable, prefer_final_fields, list_remove_unrelated_type, prefer_is_empty, prefer_const_constructors, unnecessary_null_comparison, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bts/chat_daftar.dart';
import 'package:bts/custombubbleshape.dart';
import 'package:bts/models/Apiconstant.dart';
import 'package:bts/models/list_chat.dart';
import 'package:bts/models/rating.dart';
import 'package:bts/models/save_chat.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.ConsultationID});

  // Declare a field that holds the Todo.
  final int ConsultationID;

  @override
  State<StatefulWidget> createState() {
    return _Chat();
  }
}

class _Chat extends State<Chat> {
  late StreamController _postsController = new StreamController();
  final TextEditingController _controllerMessage = TextEditingController();
  final TextEditingController _controllerKomentarRting =
      TextEditingController();
  bool emojiShowing = false;
  FocusNode focusNode = FocusNode();
  int? ConsultationID;
  late String baseimage = "";
  late Uint8List bytes;
  final double _currentRating = 0;
  IconData? _selectedIcon;
  late double _rating = 0.0;
  bool isloading = false;

  late List<File> _file = <File>[];
  List<Widget> list = <Widget>[];
  List<String> _baseimage = <String>[];
  final bool _running = true;
  List getImg = [];
  List imgDecode = [];

  // This funcion will helps you to pick and Image from Gallery
  _pickfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4'],
    );

    if (result != null) {
      setState(() {
        // PlatformFile file = result.files.first;

  // print(file.name);
  // print(file.bytes);
  // print(file.size);
  // print(file.extension);
  
// File filess = File(file.path.toString());

        List<File> files = result.paths.map((path) => File(path!)).toList();
        // var filess = file.path;
  //       final File fileForFirebase = File(file.path);

        // List<File> files = [filess];

        // print("HAHAHA  $result $filesss");
        
        _file = files;
      });
    } else {
      // User canceled the picker
    }
  }

  _rowImage(int lengthData) {
    list = [];
    _baseimage = [];
    for (var i = 0; i < lengthData; i++) {
      List<int> imageBytes = _file[i].readAsBytesSync();
      baseimage = base64Encode(imageBytes);

      _baseimage.add(baseimage);

      bytes = const Base64Codec().decode(base64.normalize(baseimage));
      list.add(Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(5.0),
            width: MediaQuery.of(context).size.width * 0.21,
            height: MediaQuery.of(context).size.width * 0.21,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff99CB57))),
            child: Image.memory(bytes,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.21,
                height: MediaQuery.of(context).size.width * 0.21),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _file.removeAt(i);
                  _baseimage.removeAt(i);
                  list.removeAt(i);
                });
              },
              icon: const Icon(
                Icons.highlight_off_outlined,
                size: 20.0,
                color: const Color(0xff99CB57),
              ),
            ),
          )
        ],
      ));
    }

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Align(alignment: Alignment.center, child: Wrap(children: list)));
  }

  _onEmojiSelected(Emoji emoji) {
    _controllerMessage
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerMessage.text.length));
  }

  _onBackspacePressed() {
    _controllerMessage
      ..text = _controllerMessage.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerMessage.text.length));
  }

  @override
  void initState() {
    super.initState();
    getListChatmanual(widget.ConsultationID);
    print("CONS_ID ${widget.ConsultationID}");
    // focusNode.requestFocus();
  }

  Stream getChatStream(consultationID) async* {
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (consultationID != null || consultationID != "") {
        Map<String, dynamic> datapost = {
          "action": actionListChat,
          "apikey": apikey,
          "ConsultationID": "$consultationID",
          "UserId": "1"
        };

        Codec<String, String> stringToBase64 = utf8.fuse(base64);

        Map<String, dynamic> bodyParameters = {
          "data": "${stringToBase64.encode(json.encode(datapost))}"
        };

        var result = await ListChat().listChat(bodyParameters);
        // if (result != null) {
        //   setState(() {
        //     print("MASUKKKKKKKKKK");
        //     isLoading(false);
        //   });
        // }

        yield result;
      }
    }
  }

  getListChatmanual(consultationID) async {
    getImg = [];
    imgDecode = [];
    if (consultationID != null || consultationID != "") {
      Map<String, dynamic> datapost = {
        "action": actionListChat,
        "apikey": apikey,
        "ConsultationID": "$consultationID",
        "UserId": "1"
      };

      Codec<String, String> stringToBase64 = utf8.fuse(base64);

      Map<String, dynamic> bodyParameters = {
        "data": "${stringToBase64.encode(json.encode(datapost))}"
      };

      var result = await ListChat().listChat(bodyParameters);
      getImg = result!;
      if (getImg.isNotEmpty) {
        isLoading(false);
      }
      for (var i = 0; i < result.length; i++) {
        late Uint8List byteImg;
        if (getImg[i]['image'] != "") {
          byteImg = const Base64Codec().decode(getImg[i]['image']);
          imgDecode.add(byteImg);
        } else {
          imgDecode.add("");
        }
      }

      // print("KALAOAA ${imgDecode}");
      // return result;
    }
  }

  Future<ReturnSave?> retrunSaveChat(bodyParameters) async {
    ReturnSave? result = await SaveChat().saveChat(bodyParameters);

    return result;
  }

  _sendChat(consultationID, message, List<File> img) async {
    if ((consultationID != null || consultationID != "") &&
            (message != null || message != "") ||
        (img.isNotEmpty)) {
      if (img.length > 0) {
        for (var i = 0; i < img.length; i++) {
          List<int> imageBytes = img[i].readAsBytesSync();
          baseimage = base64Encode(imageBytes);

          Map<String, dynamic> datapost = {
            "action": actionAddChat,
            "apikey": apikey,
            "ConsultationID": "$consultationID",
            "UserId": "1",
            "TextDetail": "${(i == 0) ? message : ""}",
            "image": "$baseimage"
          };

          Codec<String, String> stringToBase64 = utf8.fuse(base64);

          Map<String, dynamic> bodyParameters = {
            "data": "${stringToBase64.encode(json.encode(datapost))}"
          };

          var res = await retrunSaveChat(
            bodyParameters,
          );
          if (res!.response == "true") {
            setState(() {
              getListChatmanual(widget.ConsultationID);
            });
          } else {
            setState(() {
              isLoading(false);
              // ignore: prefer_const_constructors
              final snackBar = SnackBar(
                  content: const Text("Error, Can't Send Chat !!!"),
                  backgroundColor: (const Color(0xff4CAF50)),
                  action: null);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }
        }
      } else {
        if ((consultationID != null || consultationID != "") &&
            (message != null || message != "")) {
          Map<String, dynamic> datapost = {
            "action": actionAddChat,
            "apikey": apikey,
            "ConsultationID": "$consultationID",
            "UserId": "1",
            "TextDetail": "$message",
            "image": ""
          };

          Codec<String, String> stringToBase64 = utf8.fuse(base64);

          Map<String, dynamic> bodyParameters = {
            "data": "${stringToBase64.encode(json.encode(datapost))}"
          };
          var res = await retrunSaveChat(bodyParameters);
          if (res!.response == "true") {
            setState(() {
              getListChatmanual(widget.ConsultationID);
            });
          } else {
            setState(() {
              isLoading(false);
              // ignore: prefer_const_constructors
              final snackBar = SnackBar(
                  content: const Text("Error, Can't Send Chat !!!"),
                  backgroundColor: (const Color(0xff4CAF50)),
                  action: null);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }
        }
      }
    }
  }

  Future<ReturnSaveRating?> retrunAddRating(bodyParameters) async {
    ReturnSaveRating? result = await RatingChat().ratingChat(bodyParameters);

    return result;
  }

  _sendRating(consultationID, coment, rate) async {
    if (rate == 0.0) {
      // ignore: prefer_const_constructors
      final snackBar = SnackBar(
          content: const Text("Please Insert Rating First !!!"),
          backgroundColor: (const Color(0xff4CAF50)),
          action: null);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      if ((consultationID != null || consultationID != "") &&
              (coment != null || coment != "") ||
          (rate != 0.0)) {
        Map<String, dynamic> datapost = {
          "action": actionAddRate,
          "apikey": apikey,
          "ConsultationID": "$consultationID",
          "Rate": "$rate",
          "Comment": "$coment"
        };

        Codec<String, String> stringToBase64 = utf8.fuse(base64);

        Map<String, dynamic> bodyParameters = {
          "data": "${stringToBase64.encode(json.encode(datapost))}"
        };
        var res = await retrunAddRating(bodyParameters);
        if (res!.response == "true") {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ChatDaftar()),
              ModalRoute.withName("/Chat_Daftar"));
        } else {
          // ignore: prefer_const_constructors
          final snackBar = SnackBar(
              content: const Text("Error, Can't Add Rating !!!"),
              backgroundColor: (const Color(0xff4CAF50)),
              action: null);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        return res;
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    _postsController.close();
    super.dispose();
  }

  isLoading(bool isloading) async {
    if (isloading) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: SizedBox(height: 50, width: 50,child: CircularProgressIndicator(),),);
        },
      );
    } else {
      await Future<void>.delayed(const Duration(seconds: 5));
      Navigator.pop(context);
    }
  }

  Widget iconCreation(
      IconData icons, Color color, String text, dynamic fungsi) {
    return InkWell(
      onTap: () {
        setState(() {
          fungsi();
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: _currentRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      unratedColor: const Color(0xff4CAF50).withAlpha(50),
      itemCount: 5,
      itemSize: 23.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: const Color(0xff4CAF50),
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(36.0))),
                  content: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.73,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.highlight_off_outlined),
                                color: const Color(0xff99CB57),
                                iconSize: 22.0,
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Text(
                                  "Selesai berkonsultasi dengan Dr. Lindsey?",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff4CAF50)),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Beri rating konsultasi anda",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff818181)),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0,
                                    right: 30.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _ratingBar(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30.0),
                                child: TextFormField(
                                    controller: _controllerKomentarRting,
                                    textAlignVertical: TextAlignVertical.top,
                                    maxLines: 10,
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      border: OutlineInputBorder(),
                                      hintText: 'Komentar anda ...',
                                    ),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        // color: Color(0xffC4C4C4),
                                        fontWeight: FontWeight.w400)),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30.0,
                                      right: 30.0,
                                      bottom: 10.0,
                                      top: 10.0),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints.tightFor(
                                        height: 50),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      child: ElevatedButton(
                                          child: Text("SELESAI".toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color(0xff99CB57)),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                side: const BorderSide(
                                                    color: Color(0xff99CB57)),
                                              ))),
                                          onPressed: () {
                                            setState(() {
                                              _sendRating(
                                                  widget.ConsultationID,
                                                  _controllerKomentarRting.text,
                                                  _rating);
                                            });
                                          }),
                                    ),
                                  ))
                              // Stack(
                              //   clipBehavior: Clip.none, children: <Widget>[

                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })) ??
        false;
  }

  Widget listviewchat(data) {
    // print("KASLALDKA ${getImg[0]}");
    // late Uint8List bytes;
    // for (var i = 0; i < getImg.length; i++) {
    //   if (getImg[i]['image'] != "") {
    //     bytes = const Base64Codec().decode(getImg[i]['image']);
    //     getImg
    //   }
    // }
    // late Uint8List bytes;
    // if (getImg[0] != "") {
    //       bytes = const Base64Codec().decode(getImg[0]);
    //     }
    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var expT = data[index]['CreatedAt'].split(" ");
        var expH = expT[1].split(":");
        List T = [expH[0], expH[1]];
        String time = T.join(".");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // if (messages[index]['important'] == "1")
            //   Container(
            //     padding: const EdgeInsets.only(
            //         left: 14,
            //         right: 14,
            //         top: 10,
            //         bottom: 0),
            //     child: Align(
            //       alignment: (messages[index]
            //                   ['messageType'] ==
            //               "receiver"
            //           ? Alignment.topLeft
            //           : Alignment.topRight),
            //       child: Container(
            //         width:
            //             MediaQuery.of(context).size.width *
            //                 0.8,
            //         decoration: BoxDecoration(
            //           borderRadius: const BorderRadius.only(
            //               topLeft: const Radius.circular(5),
            //               topRight:
            //                   const Radius.circular(5)),
            //           color: (messages[index]
            //                       ['messageType'] ==
            //                   "receiver"
            //               ? const Color(0xffFFFFFF)
            //               : const Color(0xff99CB57)),
            //         ),
            //         padding: const EdgeInsets.all(16),
            //         child: Text(
            //           messages[index]['messageContent'],
            //           style: TextStyle(
            //               fontSize: 13,
            //               color: messages[index]
            //                           ['messageType'] ==
            //                       "receiver"
            //                   ? const Color(0xff000000)
            //                   : const Color(0xffFFFFFF)),
            //         ),
            //       ),
            //     ),
            //   ),
            Container(
              // messages[index]['important'] == "1"
              //     ? const EdgeInsets.only(
              //         left: 14,
              //         right: 14,
              //         top: 0,
              //         bottom: 0)
              //     :
              padding: const EdgeInsets.only(
                  left: 14, right: 14, top: 10, bottom: 0),
              child: Align(
                alignment: (data[index]['flag'] == "2"
                    ? Alignment.topLeft
                    : Alignment.topRight),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    // messages[index]
                    //             ['important'] ==
                    //         "1"
                    //     ? const BorderRadius.only(
                    //         bottomLeft:
                    //             const Radius.circular(5),
                    //         bottomRight: Radius.circular(5))
                    //     :
                    borderRadius: BorderRadius.circular(5),
                    color: (data[index]['flag'] == "2"
                        ? const Color(0xffFFFFFF)
                        : const Color(0xff4CAF50)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: (data[index]['image'] == "")
                      ? Text(
                          data[index]['Text'],
                          style: TextStyle(
                              fontSize: 13,
                              color: data[index]['flag'] == "2"
                                  ? const Color(0xff000000)
                                  : const Color(0xffFFFFFF)),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 2.0,
                                    top: 0.0,
                                    left: 0.0,
                                    right: 0.0),
                                child: (imgDecode.isEmpty)
                                    ? Center(
                                        child: SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator()))
                                    : Image.memory(imgDecode[index]),
                              ),
                            ),
                            Text(
                              data[index]['Text'],
                              style: TextStyle(
                                  fontSize: 13,
                                  color: data[index]['flag'] == "2"
                                      ? const Color(0xff000000)
                                      : const Color(0xffFFFFFF)),
                            )
                          ],
                        ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  left: 50, right: 30, top: 0, bottom: 10),
              child: Align(
                alignment: (data[index]['flag'] == "2"
                    ? Alignment.topLeft
                    : Alignment.topRight),
                child: Container(
                  width: (data[index]['flag'] == "2"
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width * 0.65),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (data[index]['flag'] != "2")
                        Container(
                            width: MediaQuery.of(context).size.width * 0.06,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "$time",
                                style: const TextStyle(
                                    fontSize: 8, color: Color(0xffF6F6F6)),
                              ),
                            )),
                      if (data[index]['flag'] != "2")
                        Container(
                            width: 50,
                            child: const Icon(
                              Icons.done_all,
                              size: 15,
                              color: Color(0xff4CAF50),
                            )),
                      Expanded(
                          child: Container(
                              alignment: (data[index]['flag'] == "2"
                                  ? Alignment.topLeft
                                  : Alignment.topRight),
                              child: CustomPaint(
                                  painter: CustomBubbleShape(
                                      (data[index]['flag'] == "2"
                                          ? const Color(0xffFFFFFF)
                                          : const Color(0xff4CAF50)))))),
                      if (data[index]['flag'] == "2")
                        Container(
                            width: MediaQuery.of(context).size.width * 0.06,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                "$time",
                                style: TextStyle(
                                    fontSize: 8,
                                    color: const Color(0xffF6F6F6)),
                              ),
                            )),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  ScrollController _scrollController = new ScrollController();

  final _formKey = GlobalKey<FormState>();
  List messages = [];
  int nb = 6;
  @override
  Widget build(BuildContext context) {  
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          color: const Color(0xff5C5C60),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: ListView(
                        reverse: true,
                        controller: _scrollController,
                        children: <Widget>[
                      StreamBuilder(
                        stream: getChatStream(widget.ConsultationID),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return listviewchat(snapshot.data);
                          }
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width * 1,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ])),
                if (_file.isNotEmpty)
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.1,
                      maxHeight: MediaQuery.of(context).size.height * 0.25,
                    ),
                    child: Container(
                        padding: const EdgeInsets.all(5.0),
                        // height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 1,
                        color: const Color(0xffF6F6F6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _rowImage(_file.length)),
                            // Container(
                            //   width: 50,
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(right: 20.0),
                            //     child: IconButton(
                            //       onPressed: () {
                            //         setState(() {
                            //           baseimage = "";
                            //         });
                            //       },
                            //       icon: const Icon(Icons.close, size: 20.0),
                            //     ),
                            //   ),
                            // )
                          ],
                        )),
                  ),
                if (baseimage != "")
                  const Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                Container(
                  // height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.height * 1,
                  color: const Color(0xffF6F6F6),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, top: 10.0, bottom: 10.0),
                            child: new ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 300.0,
                              ),
                              child: Stack(
                                children: [
                                  TextFormField(
                                    focusNode: focusNode,
                                    // autofocus: true,
                                    onTap: () {
                                      setState(() {
                                        emojiShowing = false;
                                      });
                                    },
                                    controller: _controllerMessage,
                                    maxLines: 7,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: 'Ketik pesan anda',
                                      hintStyle: TextStyle(
                                          color: Color(0xff606060),
                                          fontSize: 13),
                                      contentPadding:
                                          EdgeInsets.only(right: 40, left: 40),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: (!emojiShowing)
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                emojiShowing = !emojiShowing;
                                                focusNode.unfocus();
                                              });
                                            },
                                            icon: const Icon(
                                                Icons
                                                    .sentiment_satisfied_alt_outlined,
                                                size: 20.0),
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                focusNode.requestFocus();
                                                emojiShowing = false;
                                              });
                                            },
                                            icon: const Icon(Icons.keyboard,
                                                size: 20.0),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _pickfile();
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 20.0),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading(true);
                                _sendChat(widget.ConsultationID,
                                    _controllerMessage.text, _file);
                                _controllerMessage.text = "";
                                _baseimage = [];
                                _file = [];
                                list = [];
                                focusNode.unfocus();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(50, 50),
                                shape: const CircleBorder(),
                                primary: const Color(0xff4CAF50)),
                            child: const Icon(
                              Icons.send_outlined,
                              color: Colors.white,
                              size: 20.0,
                            )),
                      )
                      // ElevatedButton(
                      //     style: ButtonStyle(
                      //       foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      //       backgroundColor: MaterialStateProperty.all<Color>(Color(0xff4CAF50)),
                      //       shape: MaterialStateProperty.all<CircleBorder>(
                      //         CircleBorder()
                      //       )
                      //     ),
                      //     onPressed: () => null,
                      //     child: const Icon(
                      //           Icons.send_outlined,
                      //           color: Colors.white,
                      //           size: 20.0,)
                      //   )
                      // child: new RawMaterialButton(
                      //       onPressed: () {},
                      //       child:Icon(
                      //         Icons.send_outlined,
                      //         color: Colors.white,
                      //         size: 20.0,),
                      //       shape: new CircleBorder(),
                      //       fillColor: Color(0xff4CAF50),
                      //     )
                    ],
                  ),
                ),
                Offstage(
                  offstage: !emojiShowing,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: EmojiPicker(
                        onEmojiSelected: (Category category, Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: Config(
                            columns: 7,
                            // Issue: https://github.com/flutter/flutter/issues/28894
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            gridPadding: EdgeInsets.zero,
                            initCategory: Category.RECENT,
                            bgColor: const Color(0xFFF2F2F2),
                            indicatorColor: Colors.blue,
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                            progressIndicatorColor: Colors.blue,
                            backspaceColor: Colors.blue,
                            skinToneDialogBgColor: Colors.white,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            replaceEmojiOnLimitExceed: false,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              textAlign: TextAlign.center,
                            ),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL)),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: FloatingActionButton(
            onPressed: (() {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(36.0))),
                        content: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.73,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.highlight_off_outlined),
                                      color: const Color(0xff99CB57),
                                      iconSize: 22.0,
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0, right: 30.0),
                                      child: Text(
                                        "Selesai berkonsultasi dengan Dr. Lindsey?",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff4CAF50)),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Beri rating konsultasi anda",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff818181)),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0,
                                          right: 30.0,
                                          top: 10.0,
                                          bottom: 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          _ratingBar(),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, right: 30.0),
                                      child: TextFormField(
                                          controller: _controllerKomentarRting,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          maxLines: 10,
                                          obscureText: false,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(10.0),
                                            border: OutlineInputBorder(),
                                            hintText: 'Komentar anda ...',
                                          ),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xffC4C4C4),
                                              fontWeight: FontWeight.w400)),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30.0,
                                            right: 30.0,
                                            bottom: 10.0,
                                            top: 10.0),
                                        child: ConstrainedBox(
                                          constraints:
                                              const BoxConstraints.tightFor(
                                                  height: 50),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1,
                                            child: ElevatedButton(
                                                child: Text(
                                                    "SELESAI".toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                                style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty.all<Color>(
                                                            const Color(
                                                                0xff99CB57)),
                                                    shape: MaterialStateProperty
                                                        .all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      side: const BorderSide(
                                                          color: Color(
                                                              0xff99CB57)),
                                                    ))),
                                                onPressed: () {
                                                  setState(() {
                                                    _sendRating(
                                                        widget.ConsultationID,
                                                        _controllerKomentarRting
                                                            .text,
                                                        _rating);
                                                  });
                                                }),
                                          ),
                                        ))
                                    // Stack(
                                    //   clipBehavior: Clip.none, children: <Widget>[

                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }),
            child: Icon(
              Icons.highlight_off_outlined,
              color: const Color(0xffF6F6F6),
              size: MediaQuery.of(context).size.width * 0.1,
            ),
            backgroundColor: const Color(0xff5C5C60).withOpacity(0.5),
            splashColor: Colors.amber,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
