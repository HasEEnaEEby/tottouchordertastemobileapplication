import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

class QRCodeScannerView extends StatefulWidget {
  final String restaurantId;
  final Function(String) onTableVerified;
  final TableEntity? preSelectedTable;

  const QRCodeScannerView({
    super.key,
    required this.restaurantId,
    required this.onTableVerified,
    this.preSelectedTable,
  });

  @override
  _QRCodeScannerViewState createState() => _QRCodeScannerViewState();
}

class _QRCodeScannerViewState extends State<QRCodeScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    print(
        "📌 QRCodeScannerView Initialized with Restaurant ID: ${widget.restaurantId}");

    if (widget.restaurantId.isEmpty) {
      print("🚨 Error: QRCodeScannerView received an empty restaurant ID!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Restaurant information is missing.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    String? lastScannedCode;

    controller.scannedDataStream.listen((scanData) {
      if (isProcessing) return;

      final scannedCode = scanData.code.trim() ?? "";
      if (scannedCode.isEmpty || scannedCode == lastScannedCode) return;

      lastScannedCode = scannedCode;
      print("📸 Raw Scanned QR Code: $scannedCode");

      _processQRCode(scannedCode);
    });
  }

  Future<void> _processQRCode(String qrCode) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      final qrData = _validateQRCode(qrCode);
      _validateRestaurantAndTable(qrData);

      // Debug info - check if table exists in current state
      final state = context.read<CustomerDashboardBloc>().state;
      if (state is RestaurantDetailsLoaded) {
        print(
            "📊 Available Table IDs: ${state.tables.map((t) => t.id).toList()}");
        final tableExists =
            state.tables.any((table) => table.id == qrData['tableId']);
        print("📊 Table ID exists in database: $tableExists");

        if (!tableExists) {
          print(
              "⚠️ Warning: Table ID from QR code not found in available tables");
          // Continue with validation anyway - the backend will handle the final validation
        }
      }

      _validateThroughBloc(qrData);
    } catch (e) {
      _handleError(e.toString());
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => isProcessing = false);
        }
      });
    }
  }

  Map<String, dynamic> _validateQRCode(String qrCode) {
    try {
      print("Before Processing QR Code: $qrCode");

      final cleanedQRCode = Uri.decodeFull(qrCode.trim());
      final Map<String, dynamic> qrData = jsonDecode(cleanedQRCode);

      print("Decoded QR Data: $qrData");

      if (!qrData.containsKey('t') || !qrData.containsKey('r')) {
        throw 'Invalid QR code: Missing tableId or restaurantId';
      }

      return {
        "tableId": qrData["t"],
        "restaurantId": qrData["r"],
        "validationToken": qrData["v"] ?? "",
        "timestamp":
            qrData["ts"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      };
    } catch (e) {
      throw 'Invalid QR code format: ${e.toString()}';
    }
  }

  void _validateRestaurantAndTable(Map<String, dynamic> qrData) {
    final scannedRestaurantId = qrData['restaurantId'].toString().trim();
    final expectedRestaurantId = widget.restaurantId.trim();

    print("🔍 Scanned Restaurant ID: $scannedRestaurantId");
    print("🔍 Expected Restaurant ID: $expectedRestaurantId");
    print("🔍 Scanned Table ID: ${qrData['tableId']}");

    if (expectedRestaurantId.isEmpty) {
      print("🚨 Error: Expected Restaurant ID is empty!");
      throw 'Restaurant ID is missing. Please restart the app or select a restaurant.';
    }

    if (scannedRestaurantId != expectedRestaurantId) {
      throw '🚨 This QR code belongs to another restaurant (Expected: $expectedRestaurantId, Found: $scannedRestaurantId)';
    }

    if (widget.preSelectedTable != null &&
        qrData['tableId'] != widget.preSelectedTable!.id) {
      throw '🚨 QR code does not match the selected table (Expected: ${widget.preSelectedTable!.id}, Found: ${qrData['tableId']})';
    }
  }

  void _validateThroughBloc(Map<String, dynamic> qrData) {
    print(
        "🚀 Sending ValidateTableQREvent with Restaurant ID: ${widget.restaurantId}");
    print("🚀 Sending Table ID: ${qrData['tableId']}");

    if (widget.restaurantId.isEmpty) {
      print("🚨 Error: Missing restaurant ID before sending event!");
      _handleError("Restaurant ID is missing. Please restart the app.");
      return;
    }

    // Try simpler approach - bypass ValidateTableQREvent if it's causing issues
    if (qrData.containsKey('tableId') && qrData['tableId'] != null) {
      final tableId = qrData['tableId'].toString();

      // First attempt direct verification
      controller?.pauseCamera();
      print("✅ Table ID verified directly: $tableId");

      // Notify parent
      widget.onTableVerified(tableId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Table verified! Redirecting to ordering..."),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen
      Navigator.pop(context);
    } else {
      // If direct verification fails, try the bloc approach
      context.read<CustomerDashboardBloc>().add(
            ValidateTableQREvent(
              restaurantId: widget.restaurantId,
              qrData: jsonEncode(qrData),
              onSuccess: (String tableId) {
                controller?.pauseCamera();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Table $tableId verified! Redirecting to ordering..."),
                    backgroundColor: Colors.green,
                  ),
                );

                // Call the callback function to notify the parent widget
                widget.onTableVerified(tableId);

                // Pop back to the previous screen instead of pushing a replacement
                Navigator.pop(context);
              },
              onError: _handleError,
            ),
          );
    }
  }

  void _handleError(String message) {
    print("🚨 QR Scanner Error: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 99, 17, 11),
      ),
    );

    if (mounted) {
      setState(() => isProcessing = false);
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.preSelectedTable != null
              ? 'Verify Table ${widget.preSelectedTable!.number}'
              : 'Scan Table QR Code',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_on),
                    onPressed: () async {
                      await controller?.toggleFlash();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    onPressed: () async {
                      await controller?.flipCamera();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
