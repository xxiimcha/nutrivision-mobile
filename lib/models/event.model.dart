class Event {
  int id;
  final String title;
  final String place;
  final String time;
  final String date;

  Event({
    this.id = 0,
    this.title = '',
    this.place = '',
    this.time = '',
    this.date = '',
  });

  // Convert Event model to Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'time': time,
      'date': date,
    };
  }

  // Convert Json to Event model
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      place: json['place'] ?? '',
      time: json['time'] ?? '',
      date: json['date'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Event: $title, Location: $place, Date: $date';
  }
}
