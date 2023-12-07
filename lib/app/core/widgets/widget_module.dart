import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class WidgetModule extends StatelessWidget implements Module {
  const WidgetModule({super.key});

  Widget get view;

  @override
  void binds(Injector i);

  @override
  List<Module> get imports => [];

  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {}

  @override
  Widget build(BuildContext context) {
    return _WidgetModuleProvider(
      module: this,
      child: () => view,
    );
  }
}

class _WidgetModuleProvider<T extends Module> extends StatefulWidget {
  const _WidgetModuleProvider({super.key, required this.module, required this.child});

  final Module module;
  final Widget Function() child;

  @override
  State<_WidgetModuleProvider> createState() => _WidgetModuleProviderState();
}

class _WidgetModuleProviderState<T extends Module> extends State<_WidgetModuleProvider> {
  @override
  void initState() {
    super.initState();
    Modular.bindModule(widget.module);
    if (kDebugMode) {
      print('-- ${widget.module.runtimeType} INITIALIZED');
    }
  }

  @override
  void dispose() {
    Modular.unbindModule(type: widget.module.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child();
  }
}
