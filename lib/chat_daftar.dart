// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unnecessary_string_interpolations, unnecessary_null_comparison, unused_element

import 'dart:convert';

import 'package:bts/chat.dart';
import 'package:bts/models/Apiconstant.dart';
import 'package:bts/models/create_consultation.dart';
import 'package:flutter/material.dart';

class ChatDaftar extends StatefulWidget {
  const ChatDaftar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatDaftar();
  }
}

class _ChatDaftar extends State<ChatDaftar> {
  TextEditingController controllerNohp =
      TextEditingController(text: "08123456789");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Daftar Konsultasi',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff4CAF50),
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Pastikan kamu melengkapi data dengan benar. Isilah informasi di bawah ini untuk memudahkan ahli gizi kami dalam berkonsultasi denganmu!',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff5C5C60),
                  fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Informasi personal',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff4CAF50),
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
                controller: controllerNohp,
                obscureText: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone_android_outlined),
                  // contentPadding: EdgeInsets.only(left: 30.0, top: 0.5, bottom: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  labelText: 'Nomor Hp',
                ),
                style: TextStyle(
                  fontSize: 14,
                  height: 0.5,
                )),
          ),
          Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: 50),
                child: ElevatedButton(
                    child: Text("MULAI CHAT".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xff99CB57)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          side: BorderSide(color: Color(0xff99CB57)),
                        ))),
                    onPressed: () {
                      setState(() {
                        _mulaiChat(controllerNohp.text, context);
                      });

                      
                    }),
              ))
        ],
      ),
    )));
  }
}

_mulaiChat(nohp, context) async {
  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Chat(ConsultationID: 0)), ModalRoute.withName("/Chat"));
  if (nohp != null || nohp != "") {
    Map<String, dynamic> datapost = {
      "action": actionCreateConsultation,
      "apikey": apikey,
      "UserId": "1",
      "PhoneNo": "$nohp"
    };

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    // print("WAAWDAW ${stringToBase64.encode(json.encode(tes))}");

    Map<String, dynamic> bodyParameters = {
      "data": "${stringToBase64.encode(json.encode(datapost))}"
    };
    
    var res = await returnCreateConsultation(bodyParameters);
    if(res?.response == "true"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Chat(ConsultationID: res!.ConsultationID)), ModalRoute.withName("/Chat"));
    } else {
          final snackBar = SnackBar(
              content: const Text("Error, Can't Start Chat !!!"),
              backgroundColor: (const Color(0xff4CAF50)),
              action: null);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

Future<ReturnCreateConsultation?> returnCreateConsultation(
    bodyParameters) async {
  ReturnCreateConsultation? result =
      await CreateConsultation().createConsultation(bodyParameters);

  return result;
}
