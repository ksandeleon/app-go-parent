import 'package:flutter/material.dart';

class EditInfoScreen extends StatefulWidget {
  final String title;
  final String initialValue;

  const EditInfoScreen({
    Key? key,
    required this.title,
    required this.initialValue,
  }) : super(key: key);

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  late TextEditingController _controller;
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      setState(() {
        _isEdited = _controller.text != widget.initialValue;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Family Address':
        return Icons.home;
      case 'Emergency Contact':
        return Icons.phone;
      case 'Family Doctor':
        return Icons.local_hospital;
      case 'School':
        return Icons.school;
      default:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: Text(
          'Edit ${widget.title}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_isEdited) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Discard Changes?'),
                  content: Text('You have unsaved changes. Are you sure you want to discard them?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Discard'),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close edit screen
                      },
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          AnimatedOpacity(
            opacity: _isEdited ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: _isEdited
                  ? () {
                      Navigator.pop(context, _controller.text);
                    }
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.teal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SizedBox(height: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getIconForTitle(widget.title),
                              color: Colors.teal,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter ${widget.title.toLowerCase()}',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isEdited)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.teal,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap the check mark in the top right corner to save your changes.',
                              style: TextStyle(
                                color: Colors.teal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}