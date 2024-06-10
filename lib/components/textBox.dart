import 'package:flutter/material.dart';
class MyTextBox extends StatelessWidget {

  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionName),
              IconButton(onPressed: onPressed , icon: Icon(Icons.settings))
            ],
          ),
          Text(text)
        ],
      ),
    );
  }
}
