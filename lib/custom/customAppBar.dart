import 'package:flutter/material.dart';

AppBar customAppbar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Row(
      children: [
        Text(title),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network('', height: 50),
          ),
        ),
      ],
    ),
  );
}
