import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/dialogs/Add_Dialog.dart';
import 'package:to_do_list/services/notification_service.dart';

import 'AllTasks.dart';
import 'CompletedTask.dart';
import 'unCompletedTasks.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(child: null),

              ListTile(
                leading: Icon(Icons.person),
                title: Text("account"),
                trailing: Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {},
                splashColor: Colors.purple.withOpacity(0.1),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pushNamed(context, 'settings');
                },
                splashColor: Colors.purple.withOpacity(0.1),
              ),
              ListTile(
                leading: Icon(Icons.archive),
                title: Text("Archived Tasks"),
                trailing: Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  Navigator.of(context).pushNamed('archivedTasks');
                },
                splashColor: Colors.purple.withOpacity(0.1),
              ),

              ListTile(
                leading: Icon(Icons.show_chart),
                title: Text("Statistics"),
                trailing: Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  Navigator.of(context).pushNamed('Statistics');
                },
                splashColor: Colors.purple.withOpacity(0.1),
              ),
              ListTile(
                leading: Icon(Icons.show_chart),
                title: Text("Statistics"),
                trailing: Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  NotificationService.showTestNotification();
                },
                splashColor: Colors.purple.withOpacity(0.1),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
          child: FloatingActionButton(
            onPressed: () {
              showAddTaskDialog(context);
            },
            child: Icon(Icons.add),
          ),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,

          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "To-Do App",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Completed"),
              Tab(text: "Not Completed"),
            ],
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Archive Tasks ',
                  desc: 'do you want archive today tasks ?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    context.read<TasksProvider>().archiveTodayTasks();
                  },
                ).show();
              },
            ),
          ],
        ),

        body: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width - 30,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),

              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('EEEE').format(DateTime.now()),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [AllTasks(), CompletedTasks(), UncompletedTasks()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
