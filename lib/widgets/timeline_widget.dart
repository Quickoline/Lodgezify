import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;

  const TimelineWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No timeline events for today',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent hotel activities and events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...events.map((event) => _buildTimelineItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: _getEventColor(event.event).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _getEventColor(event.event),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Event content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getEventIcon(event.event),
                      size: 16,
                      color: _getEventColor(event.event),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.event,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.guest} - Room ${event.room}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String event) {
    switch (event.toLowerCase()) {
      case 'check-in':
        return Icons.login;
      case 'check-out':
        return Icons.logout;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String event) {
    switch (event.toLowerCase()) {
      case 'check-in':
        return Colors.green;
      case 'check-out':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
