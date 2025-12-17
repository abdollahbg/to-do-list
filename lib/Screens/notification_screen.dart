import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    leading: Icon(
                      provider.enabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                    ),
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      provider.enabled
                          ? 'You will receive reminders for your tasks.'
                          : 'Notifications are currently disabled.',
                    ),
                    trailing: Switch(
                      value: provider.enabled,
                      onChanged: (bool value) {
                        provider.setEnabled(value);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Note: Turning off notifications will clear all scheduled reminders. You won\'t get any alerts until you turn it back on.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
