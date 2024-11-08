import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  final bool showLeading; // New parameter to control back button display

  CustomAppBar({this.title = '', this.height = 60, this.showLeading = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title.isNotEmpty ? Text(title, style: TextStyle(color: Colors.black)) : null,
      leading: showLeading // Conditionally show leading widget based on showLeading
          ? Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Image.asset(
                'assets/images/Art_vibes_Logo.png',
                height: 40,
                width: 40,
              ),
            )
          : null, // Set to null if showLeading is false
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
