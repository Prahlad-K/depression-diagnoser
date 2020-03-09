import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: FirstRoute(),
));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Depression Detection',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.grey[600],
              ),
            ),
            FlatButton(
              child: Icon(IconData(58849, fontFamily: 'MaterialIcons', matchTextDirection: true),size:50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              padding: new EdgeInsets.all(20)
            ),
          ],
        )
      )
    );
  }
}

class _HomePageState extends State<HomePage> {
  final List<GlobalKey<FormState>> _formKey = new List(10);
  List<String> answers = new List(10);
  _HomePageState(){
    for (int i=0;i<10;i++){
      _formKey[i] = new GlobalKey<FormState>();
      answers[i] = '';
    }
  }
  int _index = 0;
  var question =['q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'];
  var type = [1,0,1,1,1,1,1,1,1];
  void submit(int i) {
    // First validate form.
      _formKey[i].currentState.save(); // Save our form now.

      print('Printing the answer for q ${i}');
      print('Email: ${answers[i]}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questionnaire"),
        backgroundColor: Colors.grey[600],
      ),
      body: Center(
        child: SizedBox(
          height: 300, // card height
          child: PageView.builder(
            itemCount: 10,
            controller: PageController(viewportFraction: 0.7),
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (_, i) {
              return Transform.scale(
                scale: i == _index ? 1 : 0.9,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(10,10,10,0),
                      child: new Form(
                          key: this._formKey[i],
                          child: new ListView(
                              children: <Widget>[
                                type[i]==1?new TextFormField(
                                  //keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                                    decoration: new InputDecoration(
                                        hintText: 'answer',
                                        labelText: question[i]
                                    ),
                                    onSaved: (String value) {
                                      this.answers[i] = value;
                                    }
                                ):new RadioButtonGroup(
                                    labels: <String>[
                                    "Option 1",
                                        "Option 2",
                                        ],
                                        onSelected: (String selected) => print(selected)
                                  ),
                                FlatButton(
                                    child: Icon(IconData(59511, fontFamily: 'MaterialIcons', matchTextDirection: true),size:50,color: answers[i].length==0? Colors.black : Colors.green),
                                    onPressed: () {
                                      onPressed: this.submit(i);
                                    },
                                    padding: new EdgeInsets.all(20)
                                ),
                              ]
                          )
                      )
                  ),
                  /*
                  child: Column(
                    children: <Widget>[
                      Text(
                        question[i],
                        style: TextStyle(fontSize: 32),
                      ),
                      TextFormField(
                          decoration: new InputDecoration(
                              hintText: 'your experiences...',
                              labelText: 'Answer'
                          ),
                      ),
                    ]
                  ),
                  */
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExitPage()),
          );
        },
        child: Icon(IconData(57679, fontFamily: 'MaterialIcons', matchTextDirection: true),size:50), // This trailing comma makes auto-formatting nicer for build methods.
      )
    );
  }
}
class ExitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Center(
          child:Text(
            'We will respond soon. Thank you!'
          )
        )
    );
  }
}

/*
class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questionnaire"),
        backgroundColor: Colors.grey[600],
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(10,10,10,0),
          height: 220,
          width: double.maxFinite,
          child: Card(
            elevation: 5,
          ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
          (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
          () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
          (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
          () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.cancel),
                  mini: true,
                  backgroundColor: Colors.deepOrange,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.cancel().then(
                            (result) => setState(() {
                          _isListening = result;
                          resultText = "";
                        }),
                      );
                  },
                ),
                FloatingActionButton(
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "en_US")
                          .then((result) => print('$result'));
                  },
                  backgroundColor: Colors.pink,
                ),
                FloatingActionButton(
                  child: Icon(Icons.stop),
                  mini: true,
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.stop().then(
                            (result) => setState(() => _isListening = result),
                      );
                  },
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.cyanAccent[100],
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 24.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/
/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/