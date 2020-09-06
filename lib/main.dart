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
  var textSize = 15.0;
  String inputMessage = '';
  TextEditingController textController = TextEditingController();
  void changeFontSize() async{ // function to increase textsize on holding the display button
    setState(() {
      textSize +=2;
    });
  }
  void setFontSize() async{  // function to set the default textsize value on releasing the display button
    setState(() {
      textSize =15;
    });
  }

  Future<void> _trySubmit(BuildContext context) async {  // function to store the value of the message and its size to firebase

    try { // exception handling
      await Firestore.instance.collection("messages").document(DateTime.now().toIso8601String()).setData({ // sets data in firebase under the collection name = "messages" and generates a document id based on time
        'message': textController.text,  //retrieving the value of the user input
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
  Widget build(BuildContext context) {     // Build method describes the part of the user interface represented by this widget.
    final deviceSize = MediaQuery.of(context).size; //Getting device size
    final deviceWidth = deviceSize.width;  // Getting device width for reponsive width
    final deviceHeight = deviceSize.height; // Getting device height for responsive height
    print(deviceSize);
    print(deviceWidth);
    print(deviceHeight);
    return Scaffold(                      // Scaffold provides a framework to implement the basic material design layout of the application
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:               // To fix the user input and button bar at bottom of screen
      Container(
        color: Color(0xFF1E4B7E),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(                  // To add the input input textfield and display button in a row

            children: <Widget>[

              Container(
                width: deviceWidth*.5, // dynamic width
                child: TextFormField(
                  controller: textController, // to retrieve value of a text field
                  decoration: InputDecoration(
                    labelText: 'Text',
                    hintText: 'Enter your text here',

                  ),

                  style: TextStyle(                //styling of the text widget and size
                      fontSize: textSize,
                      height: 2.0,
                    color: Colors.white,
                  ),
                  autocorrect: false,
                  onSaved: (value) {
                    inputMessage = value;
                  },
                ),
              ),

              SizedBox(// to add distance between the textfield and display button
                height: MediaQuery.of(context).viewInsets.bottom,

                width: deviceWidth*0.125,
              ),
              Container(
                width:deviceWidth*0.30 ,
                child: HoldDetector(                  // to add animation for adding press and hold text size animation
                  onHold: changeFontSize,           //to activate the hold functionality
                  holdTimeout: Duration(milliseconds: 200),
                  enableHapticFeedback: true,
                  child:  RaisedButton(
                    child: Text(
                      'Display',
                      style: TextStyle(
                        fontSize: 20.0,

                      ),
                    ),
                    onPressed: () {_trySubmit(context);}, //to activate the on press functionality
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(// Main appbar of the application
        backgroundColor: Color(0xFF1E4B7E),
        centerTitle: true,
        title: Text('Messages'), //title of the application
      ),
      backgroundColor: Colors.white70,
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('messages').snapshots(), //getting data from cloud firestore
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return new ListView(//ListView - scrollable column
            children: snapshot.data.documents.map((DocumentSnapshot document) {  //retrieving document

                return SingleChildScrollView(

                  child: Container(
                    height: (document['textSize'] + 8.0 > 40)? document['textSize'] + 25.0: 50, //adjusting the size of the display tile of the message
                    child: Card(
                      color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(document['message']?? ' ', style: TextStyle(fontSize: document['textSize'] ??10.0), //Display the message
                  ),
                ),

                ),
                  ));

            }).toList(), //Display the list of all messages entered by user
          );
        },
      ),
    );
  }
}
