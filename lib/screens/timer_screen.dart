import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timer/models/timer.dart';
import 'package:timer/services/timer_service.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

class TimerWorkoutScreen extends StatefulWidget {
  const TimerWorkoutScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<TimerWorkoutScreen> createState() => _TimerWorkoutScreenState();
}

class _TimerWorkoutScreenState extends State<TimerWorkoutScreen> {
  final _timerService = TimerService();
  final _timer = TimerSport();
  var nowDate = DateTime.now().toUtc();

  var f = NumberFormat("00");

  int _seconds = 0;
  int _minutes = 0;

  final commentControler = TextEditingController();

  final scrollController = ScrollController();

  //Sound
  late AudioPlayer player;

  //Timer
  Timer _timerExercice = Timer(Duration(milliseconds: 1), () {});
  Timer _totalTimer = Timer(Duration(milliseconds: 1), () {});
  int totalSecond = 0;
  double progress = 1.0;

  @override
  void initState() {
    player = AudioPlayer();
    super.initState();

    _timer.duration = 10;
    getTimer();
    _startTimer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  getTimer() async {
    var timer = await _timerService.readTimerById(widget.id);

    setState(() {
      _timer.id = timer[0]['id'];
      _timer.duration = timer[0]['duration'] ?? '0';

      //set minute and second for timerRest and timerExercice
      _minutes = _timer.duration! ~/ 60;
      _seconds = _timer.duration!.toInt() % 60;
    });
  }

  reInitializeTime() {
    _minutes = _timer.duration! ~/ 60;
    _seconds = _timer.duration!.toInt() % 60;
  }

  _startTimer() {
    if (_minutes > 0) {
      _seconds = _seconds + _minutes * 60;
    }
    if (_seconds > 0) {
      _minutes = (_seconds / 60).floor();
      _seconds = _seconds - (_minutes * 60);
    }
    _timerExercice = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds == 1 && _minutes == 0) {
          playSong();
        }
        if ((_seconds > 0) || (_seconds <= 0 && _minutes < 1)) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _seconds = 59;
            _minutes--;
          } else {
            //_timerExercice.cancel();
          }
        }
      });
    });
  }

  playSong() async {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        title: const Text('Timer'),
        content: const Text('Timer finished'),
        actions: <Widget>[
          Center(
            child: SizedBox(
              height: 50,
              width: 160,
              child: TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                onPressed: () {
                  _timerExercice.cancel();
                  player.stop();
                  Navigator.pop(context, 'OK');
                },
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );

    await player.setAsset('assets/sounds/alarm.mp3');
    player.play();
    print("play");
  }

  //Scroll automatically when touch card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 29, 29, 29),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.clear),
              color: Color.fromARGB(255, 255, 255, 255),
              iconSize: 40,
              onPressed: () => {Navigator.pop(context), _timerExercice.cancel()}

              // 2
              ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            SizedBox(height: 150),
            Center(
              child: Stack(
                children: [
                  //Text(currentRepetition.toString()),
                  GestureDetector(
                    onTap: () => {
                      HapticFeedback.mediumImpact(),
                      // on exercice Card

                      if (!_timerExercice.isActive)
                        {
                          _startTimer(),
                        }
                      else
                        {_timerExercice.cancel()}

                      //End card

                      //on rest card
                    },
                    child: SizedBox(
                        width: 300,
                        height: 300,
                        child: LiquidCircularProgressIndicator(
                          value: (_seconds + _minutes * 60) / _timer.duration!,
                          // Defaults to 0.5.
                          valueColor: AlwaysStoppedAnimation(const Color
                                  .fromARGB(255, 55, 226,
                              175)), // Defaults to the current Theme's accentColor.
                          backgroundColor: const Color.fromARGB(255, 60, 60,
                              60), // Defaults to the current Theme's backgroundColor.
                          borderColor: Colors.transparent,
                          borderWidth: 5.0,
                          direction: Axis
                              .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          center: textCercle(),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget textCercle() {
    return Text(
      "${f.format(_minutes)}:${f.format(_seconds)}",
      style: const TextStyle(
        fontSize: 80,
        fontFamily: 'BalooBhai',
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
