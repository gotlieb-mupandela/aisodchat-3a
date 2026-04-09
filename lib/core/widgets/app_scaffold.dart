import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions = const [],
    this.leading,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;
  final Widget? leading;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!, style: const TextStyle(fontFamily: 'PlayfairDisplay')),
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              actions: actions,
              leading: leading,
            ),
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
