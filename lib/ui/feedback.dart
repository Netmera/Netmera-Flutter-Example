import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum FeedbackStyle { info, success, error }

/// Shows a SnackBar from anywhere in the app. Unlike native toasts it lives in
/// the widget tree, so widget and integration tests can find its text.
void showFeedback(String message, {FeedbackStyle style = FeedbackStyle.info}) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: switch (style) {
          FeedbackStyle.info => null,
          FeedbackStyle.success => AppColors.success,
          FeedbackStyle.error => AppColors.destructive,
        },
      ),
    );
}
