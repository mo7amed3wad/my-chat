import 'package:flutter/material.dart';
import 'package:mychat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedinUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final sms = TextEditingController();
  String messageTtext;

  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    final User = await _auth.currentUser();
    if (User != null) {
      loggedinUser = User;
      print(loggedinUser.email);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

// void getData()async{
// var messages = await _firestore.collection("messages").getDocuments();
//  for(var message in messages.documents){
//  print(message.data);
//  }
//}
  void messageStreaming() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //messageStreaming();
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: sms,
                      onChanged: (value) {
                        messageTtext = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      sms.clear();
                      var _firestore =
                          Firestore.instance.collection("messages").add({
                        "sender": loggedinUser.email,
                        "text": messageTtext,
                        "time":DateTime.now()
                        //"sender" : loggedinUser.email
                      });

                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("messages").orderBy("time").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ));
          }
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messagesbubble = [];
          for (var message in messages) {
            final messageText = message.data["text"];
            final messageSender = message.data["sender"];
            final messagetime =message.data["time"];
            final currentuser = loggedinUser.email;
            final messageWidget = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentuser == messageSender,
              //time: messagetime,
            );
            messagesbubble.add(messageWidget);
          }

          return Expanded(
            child: ListView
            
            (reverse: true,
              children: messagesbubble),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
//  DateTime time;
  MessageBubble({this.sender, this.text, this.isMe , });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            elevation: 5,
            borderRadius:isMe? BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30)):BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30)),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 16, color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
