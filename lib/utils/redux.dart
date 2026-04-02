import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:hmis/bussiness/business.dart';
import 'package:hmis/main.dart';

/// GLOBAL DISPATCH
void dispatch(action) => store.dispatch(action);

/// REACTIVE UI - FOR AUTOREBUILDING ON REDUX ACTIVITY

abstract class UI extends StatefulWidget {
  const UI({super.key});
  void init() {}
  void dispose() {}
  void firstBuild() {}
  void preChange() {}
  void postChange() {}
  @override
  State<UI> createState() => _UIState();
  Widget build(BuildContext context);

  /// GLOBALLY ACCESSIBLE STATE
  Business get state => store.state;
}

class _UIState extends State<UI> {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<Business>(
      builder: (context, _) => widget.build(context),
      onInit: (_) => widget.init(),
      onDispose: (_) => widget.dispose(),
      onInitialBuild: (viewModel) => widget.firstBuild(),
      onWillChange: (_, _) => widget.preChange(),
      onDidChange: (_, _) => widget.postChange(),
    );
  }
}
