import 'package:flutter/material.dart';

extension GetAgrument on BuildContext {
  T? getArgument<T>() {
    final modelRoute = ModalRoute.of(this);
    if (modelRoute != null) {
      final args = modelRoute.settings.arguments;
      if (args != null) {
        return args as T;
      }
    }
    return null;
  }
}
