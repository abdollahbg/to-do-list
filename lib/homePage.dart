import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Add_Dialog.dart';

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
          backgroundColor: Colors.deepPurple,
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
