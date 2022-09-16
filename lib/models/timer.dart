class TimerSport {
  int? id;
  int? duration;

  timerMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['duration'] = duration;

    return mapping;
  }
}
