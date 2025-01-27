import 'package:flutter/material.dart';

class EmergencyHotlineScreen extends StatelessWidget {
  const EmergencyHotlineScreen({Key? key}) : super(key: key);

  Widget _buildEmergencyCard({
    required String title,
    required String number,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Add phone call functionality here
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        number,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.phone_in_talk,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: Text(
          'Emergency Hotlines',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'In Case of Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Quick access to emergency services',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Emergency Numbers List
          Expanded(
            child: ListView(
              children: [
                _buildEmergencyCard(
                  title: 'Police Emergency',
                  number: '911',
                  description: '24/7 Police Emergency Services',
                  icon: Icons.local_police,
                ),
                _buildEmergencyCard(
                  title: 'Fire Department',
                  number: '912',
                  description: 'Fire and Rescue Services',
                  icon: Icons.fire_truck,
                ),
                _buildEmergencyCard(
                  title: 'Ambulance',
                  number: '913',
                  description: 'Medical Emergency Services',
                  icon: Icons.medical_services,
                ),
                _buildEmergencyCard(
                  title: 'Child Emergency',
                  number: '914',
                  description: 'Child Protection Services',
                  icon: Icons.child_care,
                ),
                _buildEmergencyCard(
                  title: 'Poison Control',
                  number: '915',
                  description: 'Poison Information Center',
                  icon: Icons.health_and_safety,
                ),
                _buildEmergencyCard(
                  title: 'National Emergency',
                  number: '916',
                  description: 'Natural Disasters and Major Emergencies',
                  icon: Icons.warning,
                ),
              ],
            ),
          ),
          // Bottom Warning
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.red,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on any card to immediately call the emergency number',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}