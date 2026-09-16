import 'package:flutter/material.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view_outlined, size: 48, color: Color(0xFF2A3B4D)),
          SizedBox(height: 16),
          Text('Ambientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: Color(0xFFE8EAED))),
          SizedBox(height: 8),
          Text('Em construção — próximo passo!',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7D8C))),
        ],
      ),
    );
  }
}