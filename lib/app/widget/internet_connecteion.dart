// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';

// /// Widget that shows a banner when there is no internet connection
// class NoInternetBanner extends StatefulWidget {
//   final Widget child;
//   final Color backgroundColor;
//   final Color textColor;
//   final String message;
//   final double height;
//   final bool dismissible;
//   final bool isBannerVisible;
//   final VoidCallback? onRetry;

//   const NoInternetBanner({
//     super.key,
//     required this.child,
//     this.backgroundColor = Colors.red,
//     this.textColor = Colors.white,
//     this.message = 'No internet connection',
//     this.height = 40.0,
//     this.dismissible = false,
//     this.onRetry,
//     required this.isBannerVisible,
//   });

//   @override
//   State<NoInternetBanner> createState() => _NoInternetBannerState();
// }

// class _NoInternetBannerState extends State<NoInternetBanner> {
//   late NetworkInfo _networkInfo;
//   StreamSubscription? _connectivitySubscription;
//   bool _isConnected = true;
//   bool _isBannerVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _initConnectivity();
//   }

//   void _initConnectivity() {
//     try {
//       _networkInfo = GetIt.instance<NetworkInfo>();

//       // Check initial connection status
//       _checkConnectionStatus();

//       // Listen for connectivity changes
//       _connectivitySubscription =
//           _networkInfo.onConnectivityChanged.listen((connected) {
//         if (mounted) {
//           setState(() {
//             _isConnected = connected;
//             _updateBannerVisibility();
//           });
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing connectivity: $e');
//     }
//   }

//   Future<void> _checkConnectionStatus() async {
//     try {
//       final isConnected = await _networkInfo.isConnected;
//       if (mounted) {
//         setState(() {
//           _isConnected = isConnected;
//           _updateBannerVisibility();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error checking connection status: $e');
//       if (mounted) {
//         setState(() {
//           _isConnected = false;
//           _updateBannerVisibility();
//         });
//       }
//     }
//   }

//   void _updateBannerVisibility() {
//     _isBannerVisible = !_isConnected;
//   }

//   void _dismissBanner() {
//     if (widget.dismissible && _isBannerVisible) {
//       setState(() {
//         _isBannerVisible = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         widget.child,
//         if (_isBannerVisible)
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 height: widget.height,
//                 color: widget.backgroundColor,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.wifi_off,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       widget.message,
//                       style: TextStyle(
//                         color: widget.textColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (widget.onRetry != null) ...[
//                       const SizedBox(width: 8),
//                       TextButton(
//                         onPressed: widget.onRetry,
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           minimumSize: const Size(60, 30),
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                         ),
//                         child: Text(
//                           'Retry',
//                           style: TextStyle(
//                             color: widget.textColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                     if (widget.dismissible)
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: widget.textColor,
//                           size: 16,
//                         ),
//                         onPressed: _dismissBanner,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(
//                           minWidth: 36,
//                           minHeight: 36,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// /// Widget that shows a fullscreen message when there is no internet connection
// class NoInternetScreen extends StatelessWidget {
//   final VoidCallback onRetry;
//   final String title;
//   final String message;
//   final IconData icon;

//   const NoInternetScreen({
//     super.key,
//     required this.onRetry,
//     this.title = 'No Internet Connection',
//     this.message = 'Please check your internet connection and try again.',
//     this.icon = Icons.wifi_off,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   icon,
//                   size: 80,
//                   color: Theme.of(context).colorScheme.error,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   message,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton.icon(
//                   onPressed: onRetry,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Try Again'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     textStyle: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Widget that automatically shows a no internet message when offline
// class InternetAwareWidget extends StatefulWidget {
//   final Widget child;
//   final Widget Function(VoidCallback retryCallback)? offlineBuilder;
//   final bool showBanner;
//   final bool showFullscreenOnOffline;

//   const InternetAwareWidget({
//     super.key,
//     required this.child,
//     this.offlineBuilder,
//     this.showBanner = true,
//     this.showFullscreenOnOffline = false,
//   });

//   @override
//   State<InternetAwareWidget> createState() => _InternetAwareWidgetState();
// }

// class _InternetAwareWidgetState extends State<InternetAwareWidget> {
//   late NetworkInfo _networkInfo;
//   StreamSubscription? _connectivitySubscription;
//   bool _isConnected = true;

//   @override
//   void initState() {
//     super.initState();
//     _initConnectivity();
//   }

//   void _initConnectivity() {
//     try {
//       _networkInfo = GetIt.instance<NetworkInfo>();

//       _checkConnectionStatus();
//       _connectivitySubscription =
//           _networkInfo.onConnectivityChanged.listen((connected) {
//         if (mounted) {
//           setState(() {
//             _isConnected = connected;
//           });
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing connectivity: $e');
//     }
//   }

//   Future<void> _checkConnectionStatus() async {
//     try {
//       final isConnected = await _networkInfo.isConnected;
//       if (mounted) {
//         setState(() {
//           _isConnected = isConnected;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error checking connection status: $e');
//       if (mounted) {
//         setState(() {
//           _isConnected = false;
//         });
//       }
//     }
//   }

//   Future<void> _retry() async {
//     await _checkConnectionStatus();
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // If we're online, show the child with an optional banner
//     if (_isConnected) {
//       if (widget.showBanner) {
//         return NoInternetBanner(
//           onRetry: _retry,
//           child: widget.child,
//         );
//       }
//       return widget.child;
//     }

//     // If we're offline
//     if (widget.showFullscreenOnOffline) {
//       // Show a fullscreen offline message
//       return NoInternetScreen(onRetry: _retry);
//     } else if (widget.offlineBuilder != null) {
//       // Use custom offline builder
//       return widget.offlineBuilder!(_retry);
//     } else if (widget.showBanner) {
//       // Show child with a banner
//       return NoInternetBanner(
//         isBannerVisible: true,
//         onRetry: _retry,
//         child: widget.child,
//       );
//     }

//     // Default to just showing the child
//     return widget.child;
//   }
// }
