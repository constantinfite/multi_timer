import 'package:timer/models/timer.dart';
import 'package:timer/repositories/repository_timer.dart';


class TimerService {
  late Repository _repository;

  TimerService() {
    _repository = Repository();
  }

  //Create data
  saveTimer(TimerSport timer) async {
    return await _repository.insertData('timers', timer.timerMap());
  }

  //Update data
  updateTimer(TimerSport timer) async {
    return await _repository.updateData('timers', timer.timerMap());
  }

  // Read data from table
  readTimers() async {
    
    return await _repository.readData('timers');
  }

  //Read data from table by Id
  readTimerById(timerId) async {
    return await _repository.readDataById('timers', timerId);
  }

  // Delete data from table
  deleteTimer(timerId) async {
    return await _repository.deleteData('timers', timerId);
  }
}
