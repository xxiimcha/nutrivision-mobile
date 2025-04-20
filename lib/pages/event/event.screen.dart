import 'package:flutter/material.dart';
import 'package:sjq/pages/event/_event_list.dart';
import 'package:sjq/services/services.dart';
import 'package:sjq/themes/themes.dart';
import 'package:table_calendar/table_calendar.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  EventService eventService = EventService();
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
  }

  void _onDateSelected(DateTime selected, DateTime focused) {
    setState(() {
      selectedDay = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A276C), // AppBar color
        title: const Text("PROGRAM SCHEDULE", style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
        elevation: 3,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 254, 255), // Set background color for the calendar
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color.fromARGB(255, 64, 87, 202), width: 1), // Border around the calendar
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2040),
                  focusedDay: selectedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: _onDateSelected,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: headingM.copyWith(
                      color: Colors.black, // Changed to black for better visibility
                      fontWeight: FontWeight.bold,
                    ),
                    formatButtonVisible: false,
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 228, 254, 255),  // Set header background to white
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF003366), // Darker blue for selected date
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1), // White border for selected date
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    defaultTextStyle: TextStyle(color: Colors.grey.shade800),
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    cellMargin: const EdgeInsets.all(4), // Decreased margin around each day cell
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.red),
                    weekdayStyle: TextStyle(color: Colors.black),
                  ),
                  rowHeight: 50, // Decreased row height for less space between dates
                  availableGestures: AvailableGestures.all,
                ),
              ),
              const SizedBox(height: 20), // Increased spacing
              Expanded(
                child: EventListViewer(date: selectedDay.toIso8601String()), // Pass the selected date
              ),
            ],
          ),
        ),
      ),
    );
  }
}
