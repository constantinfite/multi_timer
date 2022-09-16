import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timer/models/timer.dart';
import 'package:timer/services/timer_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InputTimerScreen extends StatefulWidget {
  const InputTimerScreen(
      {Key? key, required this.creation, required this.timer})
      : super(key: key);

  final bool creation;
  final TimerSport timer;

  @override
  State<InputTimerScreen> createState() => _InputTimerScreenState();
}

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final secondsString = '$seconds'.padLeft(2, '0');

  if (minutes == 0) {
    return '$secondsString s';
  } else {
    final minutesString = '$minutes'.padLeft(1, '0');
    return '$minutesString m $secondsString s';
  }
}

class _InputTimerScreenState extends State<InputTimerScreen> {
  int id = 0;

  Duration durationTimer = Duration(minutes: 0, seconds: 0);

  final exercice = TimerSport();
  final _timerService = TimerService();
  int _totalSecond = 0;
  final _formKey = GlobalKey<FormState>();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

    if (!widget.creation) {
      editValue();
    }
  }

  convertDurationToTime(
    Duration duration,
  ) {
    var minute = duration.inMinutes.remainder(60);
    var second = duration.inSeconds.remainder(60);

    _totalSecond = minute * 60 + second;
  }

  editValue() async {
    setState(() {
      id = widget.timer.id!;
      durationTimer = Duration(
          minutes: widget.timer.duration! ~/ 60,
          seconds: widget.timer.duration! % 60);
    });
  }

  choiceAction(String choice) async {
    if (choice == "delete") {
      await _timerService.deleteTimer(id);
      Navigator.pop(context);
    }
  }

  _showToast(_text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 60, 60, 60),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'BalooBhai2',
            ),
          ),
        ],
      ),
    );
    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Stack(alignment: Alignment.centerRight, children: <Widget>[
            Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.75, child: child)
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 29, 29),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
            ),
            color: Color.fromARGB(255, 255, 255, 255),
            iconSize: 40,
            onPressed: () => Navigator.pop(context)
            // 2
            ),
        backgroundColor: Colors.transparent,
        title: Text(
          !widget.creation ? 'Edit Timer ' : 'Add Timer',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 30,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: const Color.fromARGB(255, 55, 226, 175),
              iconSize: 50,
              onPressed: () async {
                convertDurationToTime(durationTimer);

                if (widget.creation) {
                  if (_totalSecond != 0) {
                    final _timer = TimerSport();
                    _timer.duration = _totalSecond;
                    await _timerService.saveTimer(_timer);
                    Navigator.pop(context);
                  } else {
                    fToast.removeQueuedCustomToasts();
                    _showToast("Choice a value");
                  }
                } else {
                  if (_totalSecond != 0) {
                    final _timer = TimerSport();
                    _timer.id = id;
                    _timer.duration = _totalSecond;
                    await _timerService.updateTimer(_timer);
                    Navigator.pop(context);
                  } else {
                    fToast.removeQueuedCustomToasts();
                    _showToast("Choice a value");
                  }
                }
              }
              // 2
              ),
          Visibility(
            visible: !widget.creation,
            child: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 40,
                  color: const Color.fromARGB(255, 60, 60, 60),
                ),
                itemBuilder: (_) => const <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                          child: Text('Delete'), value: 'delete'),
                    ],
                onSelected: choiceAction),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              //key: _formKey,
              child: Column(children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Card(
                  color: Colors.white,
                  child: Column(children: [buildTimePicker()]),
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.transparent)),
                  elevation: 2,
                ),
                SizedBox(
                  height: 20,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimePicker() => SizedBox(
        height: 300,
        child: CupertinoTimerPicker(
          initialTimerDuration: durationTimer,
          mode: CupertinoTimerPickerMode.ms,
          minuteInterval: 1,
          secondInterval: 1,
          onTimerDurationChanged: (duration) =>
              setState(() => durationTimer = duration),
        ),
      );
}
