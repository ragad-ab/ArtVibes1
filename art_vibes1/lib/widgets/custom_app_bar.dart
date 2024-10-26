import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  CustomAppBar({this.title = '', this.height = 60});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title.isNotEmpty ? Text(title, style: TextStyle(color: Colors.black)) : null,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/images/Art_vibes_Logo.png', // Update to asset path
          height: 40,
          width: 40,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
