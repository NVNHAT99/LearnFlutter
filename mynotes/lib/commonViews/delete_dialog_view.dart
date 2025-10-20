import 'package:flutter/material.dart';
import 'package:mynotes/commonViews/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure want to delete this item?',
    optionBuilder: () => {'Cancel': false, 'Delete': true},
  ).then((value) => value ?? false);
}
