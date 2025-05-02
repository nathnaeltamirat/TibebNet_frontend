import 'package:flutter/material.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Explore\nCommunities',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Changed from green to blue
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Share knowledge, find support, and explore new paths.\nYour journey to success starts here.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/header.png', 
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
