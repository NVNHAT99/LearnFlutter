import 'package:flutter/material.dart';
import 'package:mynotes/commonViews/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: 'An eror occured.',
    content: text,
    optionBuilder: () => {'OK': null},
  );
}
