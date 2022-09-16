import 'package:flutter/material.dart';
import 'package:timer/services/timer_service.dart';
import 'package:timer/models/timer.dart';
import 'package:timer/screens/input_timer_screen.dart';
import 'package:timer/screens/timer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  List<TimerSport> _timerList = <TimerSport>[];
  final _timerService = TimerService();

  late var _timer = TimerSport();
  var timer;

  //final _timer = Timer(id: 0, duration: 10);

  @override
  void initState() {
    super.initState();
    _timer.duration = 0;

    getAllTimers();
  }

  getAllTimers() async {
    _timerList = <TimerSport>[];
    var timers = await _timerService.readTimers();
    timers.forEach((timer) {
      setState(() {
        var timerModel = TimerSport();
        timerModel.id = timer['id'];
        timerModel.duration = timer['duration'];
        _timerList.add(timerModel);
      });
    });
  }

  editExercice(BuildContext context, timerId) async {
    timer = await _timerService.readTimerById(timerId);
    setState(() {
      _timer.id = timer[0]['id'];
      _timer.duration = timer[0]['duration'] ?? 0;
    });
  }

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 29, 29),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 7),
              itemCount: _timerList.length,
              itemBuilder: (BuildContext ctx, index) {
                return GestureDetector(
                  onLongPress: () {
                    editExercice(context, _timerList[index].id);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => InputTimerScreen(
                                creation: false, timer: _timer)))
                        .then((_) {
                      getAllTimers();
                    });
                  },
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            TimerWorkoutScreen(id: _timerList[index].id!)));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 60, 60, 60),
                          borderRadius: BorderRadius.circular(15)),
                      child: textCercle(_timerList[index].duration!)),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          foregroundColor: Theme.of(context).primaryColorDark,
          onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          InputTimerScreen(creation: true, timer: _timer)))
                  .then((_) {
                getAllTimers();
              }),
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget textCercle(duration) {
    int sec = duration % 60;
    int min = (duration / 60).floor();

    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return Text(
      minute + ":" + second,
      style: const TextStyle(
        fontSize: 25,
        fontFamily: 'BalooBhai2',
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
