import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatefulWidget {
  const DateWidget({super.key});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  late Timer _timer;
  late DateTime _selectedDate;
  late List<DateTime> _visibleDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _updateVisibleDates();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      // This will trigger a rebuild and update the time display
    });
  });

  }


  void _updateVisibleDates() {
    DateTime now = DateTime.now();

    // Ensure dates are within the current month
    if (_selectedDate.month == now.month && _selectedDate.year == now.year) {
      _visibleDates = [
        _selectedDate.subtract(const Duration(days: 1)),
        _selectedDate,
        _selectedDate.add(const Duration(days: 1)),
      ];
    } else {

      _selectedDate = now;
      _visibleDates = [
        now.subtract(const Duration(days: 1)),
        now,
        now.add(const Duration(days: 1)),
      ];
    }
  }



  @override
  Widget build(BuildContext context) {
    return
                    //date section //feature 2
                Column(
                  children: [
                    SizedBox(
                      width: 500,
                      child: Card(
                        elevation: 8,
                        color:  Color(0xFFF2EFE7),
                        child: Padding (
                          padding: const EdgeInsets.all(16),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Parent, Let's Make This Month Count!",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                              ),
                              Text(
                                '(GMT+8:00) ${DateFormat('M/d/yyyy h:mm:ss a').format(DateTime.now())}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black45),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 90,
                                    child: Card(
                                      color: Colors.teal[100],
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.chevron_left,color: Colors.black),
                                        onPressed: () {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onHorizontalDragEnd: (details) {
                                        if (details.primaryVelocity! > 0) {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                          }
                                        } else if (details.primaryVelocity! < 0) {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.add(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: _visibleDates.map((date) {
                                          final isToday = date.day == DateTime.now().day &&
                                              date.month == DateTime.now().month &&
                                              date.year == DateTime.now().year;
                                          return AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: Card(
                                              key: ValueKey(date),
                                              color: isToday ? Colors.teal : Colors.white,
                                              child: SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      DateFormat('EEE').format(date),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: isToday ? Colors.white : null,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${DateFormat('MMM').format(date)} ${date.day}',
                                                      style: TextStyle(
                                                        color: isToday ? Colors.white : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 90,
                                    child: Card(
                                      color: Colors.teal[100],
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: IconButton(onPressed: () {
                                          if (_selectedDate.month == DateTime.now().month) {
                                            setState(() {
                                              _selectedDate = _selectedDate.add(const Duration(days: 1));
                                              _updateVisibleDates();
                                            });
                                          }
                                        } , icon: const Icon(Icons.chevron_right, color: Colors.black,)),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
    ;
  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }
}
