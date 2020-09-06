import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ThreadedMessages(),
    );
  }
}

class ThreadedMessages extends StatefulWidget {
  @override
  _ThreadedMessagesState createState() => _ThreadedMessagesState();
}

class _ThreadedMessagesState extends State<ThreadedMessages> {
  var textSize = 20.0;
  String inputMessage = '';
  TextEditingController textController = TextEditingController();
  void changeFontSize() async{
    setState(() {
      textSize +=2;
    });
  }
  void setFontSize() async{
    setState(() {
      textSize =20;
    });
  }

  Future<void> _trySubmit(BuildContext context) async {

    try {
      await Firestore.instance.collection("messages").document(DateTime.now().toIso8601String()).setData({
        'message': textController.text,
        'textSize': textSize,
      });
      textController.clear();
      setFontSize();
    } catch (err) {
      print(err);
      var message = 'An error occurred';
      if (err.message != null) {
        message = err.message;
      }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(                      //Scaffold to
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:
      Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(

            children: <Widget>[

              Container(
                width: 250,
                child: TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: 'Text',
                    hintText: 'Enter your text here',

                  ),
                  style: TextStyle(
                      fontSize: textSize,
                      height: 2.0,
                      color: Colors.black,
                  ),
                  autocorrect: false,
                  onSaved: (value) {
                    inputMessage = value;
                  },
                ),
              ),

              SizedBox(
                width: 50,
              ),
              HoldDetector(

                onHold: changeFontSize,
                holdTimeout: Duration(milliseconds: 200),
                enableHapticFeedback: true,
                child:  RaisedButton(
                  child: Text(
                    'Display',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {_trySubmit(context);},
                ),
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        centerTitle: true,
        title: Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('messages').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return new ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {

                return SingleChildScrollView(

                  child: Container(
                    height: (document['textSize'] + 8.0 >50)? document['textSize'] + 25.0: 50,
                    child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(document['message']?? ' ', style: TextStyle(fontSize: document['textSize'] ??10.0),
                  ),
                ),

                ),
                  ));

            }).toList(),
          );
        },
      ),
    );
  }
}
