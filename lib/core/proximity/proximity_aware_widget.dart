import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your ProximityCubit
import 'package:tottouchordertastemobileapplication/core/proximity/proximity_cubit.dart';

/// A widget wrapper that adapts its UI based on proximity sensor state
class ProximityAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? proximityActiveChild;
  final bool applyDimming;
  final bool disableTouches;

  const ProximityAwareWidget({
    super.key,
    required this.child,
    this.proximityActiveChild,
    this.applyDimming = true,
    this.disableTouches = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProximityCubit, ProximityState>(
      builder: (context, state) {
        if (state.isNear) {
          // Device is near face or covered
          Widget activeWidget = proximityActiveChild ?? child;

          if (applyDimming) {
            // Apply screen dimming effect
            activeWidget = ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.5,
                0,
                0,
                0,
                0,
                0,
                0.5,
                0,
                0,
                0,
                0,
                0,
                0.5,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: activeWidget,
            );
          }

          if (disableTouches) {
            // Prevent accidental touches when device is near face
            activeWidget = AbsorbPointer(
              absorbing: true,
              child: activeWidget,
            );
          }

          return activeWidget;
        } else {
          // Normal mode - device is not near face
          return child;
        }
      },
    );
  }
}

/// A proximity-aware scaffold that implements common proximity behaviors
class ProximityScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool autoDisableTouches;
  final bool autoDimScreen;

  const ProximityScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.drawer,
    this.endDrawer,
    this.autoDisableTouches = true,
    this.autoDimScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalScaffold = Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      drawer: drawer,
      endDrawer: endDrawer,
    );

    return ProximityAwareWidget(
      applyDimming: autoDimScreen,
      disableTouches: autoDisableTouches,
      child: normalScaffold,
    );
  }
}

/// Example usage
/// 
/// ```dart
/// class MyScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ProximityScaffold(
///       appBar: AppBar(title: Text('Proximity Demo')),
///       body: Center(
///         child: ProximityAwareWidget(
///           child: Text('Normal state'),
///           proximityActiveChild: Text('Phone near face!'),
///         ),
///       ),
///     );
///   }
/// }
/// ```