import 'package:flutter/material.dart';

/// Provides navigation selection state to nested tab screens (home / favorites /
/// settings) so the menu button can open a floating sheet.
class AppNavScope extends InheritedWidget {
  const AppNavScope({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required super.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static AppNavScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppNavScope>();
    assert(scope != null, 'AppNavScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppNavScope oldWidget) =>
      oldWidget.selectedIndex != selectedIndex;
}
