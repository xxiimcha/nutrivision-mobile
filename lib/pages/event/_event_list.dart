import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sjq/models/event.model.dart';
import 'package:sjq/themes/themes.dart';
import '../auth/http_service.dart'; // Import your HttpService

class EventListViewer extends StatelessWidget {
  final String date; // Add a date field to filter events by date

  const EventListViewer({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed
      body: FutureBuilder<List<Event>>(
        future: HttpService().fetchEvents(date: date), // Fetch events by date
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No events for this day'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return EventCard(event: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    final eventDateTime = DateTime.parse(event.date);
    final formattedDate = DateFormat.yMMMMd().format(eventDateTime);

    // Ensure event.location is not null, and provide a default value if it is null
    final eventLocation = event.location;

    // Parse event.time and format it to 12-hour format
    final eventTime = DateFormat.jm().format(DateFormat.Hm().parse(event.time));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6, // Slightly higher elevation for better shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // More visible border radius
          side: const BorderSide(
            color: Color.fromARGB(255, 167, 167, 171), // Make the border more visible
            width: 1, // Thicker border width
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              displayWithIcon(
                icon: Icons.event,
                label: 'PROGRAM: ${event.title}',
              ),
              const SizedBox(height: 8),
              displayWithIcon(
                icon: Icons.calendar_today,
                label: 'DATE: $formattedDate',
              ),
              const SizedBox(height: 8),
              displayWithIcon(
                icon: Icons.location_on,
                label: 'LOCATION: $eventLocation',
              ),
              const SizedBox(height: 8),
              displayWithIcon(
                icon: Icons.access_time,
                label: 'TIME: $eventTime',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayWithIcon({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: paragraphS.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
