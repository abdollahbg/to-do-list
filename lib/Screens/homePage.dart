import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list/dialogs/Add_Dialog.dart';

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
          iconTheme: const IconThemeData(
            color: Colors.white, // Set your desired color here
          ),
          backgroundColor: Colors.red,
          elevation: 4,
          centerTitle: true,

          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "To-Do List",
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
        ),

        body: Column(
          children: [
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
