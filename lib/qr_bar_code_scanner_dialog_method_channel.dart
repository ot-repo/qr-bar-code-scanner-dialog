import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'qr_bar_code_scanner_dialog_platform_interface.dart';

/// An implementation of [QrBarCodeScannerDialogPlatform] that uses method channels.
class MethodChannelQrBarCodeScannerDialog extends QrBarCodeScannerDialogPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qr_bar_code_scanner_dialog');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void scanBarOrQrCode({BuildContext? context, required Function(String? code) onScanSuccess}) {
    /// context is required to show alert in non-web platforms
    assert(context != null);

    showDialog(
      context: context!,
      builder: (context) => Container(
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: 600,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ScannerWidget(
            onScanSuccess: (code) {
              if (code != null) {
                Navigator.pop(context);
                onScanSuccess(code);
              }
            },
          ),
        ),
      ),
    );
  }
}

class ScannerWidget extends StatefulWidget {
  final void Function(String? code) onScanSuccess;

  const ScannerWidget({super.key, required this.onScanSuccess});

  @override
  createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  QRViewController? controller;
  GlobalKey qrKey = GlobalKey(debugLabel: 'scanner');

  bool isScanned = false;
  bool isFlashOn = false;
  bool hasFlash = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    /// dispose the controller
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                _buildQrView(context),
                if (hasFlash)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        onPressed: () async {
                          if (controller != null) {
                            await controller?.toggleFlash();
                            isFlashOn = (await controller?.getFlashStatus()) ?? false;
                            setState(() {
                              debugPrint("isFlashOn: $isFlashOn");
                            });
                          }
                        },
                        icon: Icon(
                          isFlashOn ? Icons.flashlight_on_outlined : Icons.flashlight_off_rounded,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    double smallestDimension = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    smallestDimension = min(smallestDimension, 550);

    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.back,
      onQRViewCreated: (controller) {
        _onQRViewCreated(controller);
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.black,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: smallestDimension - 140,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;

    var result = await controller.getSystemFeatures();

    controller.scannedDataStream.listen((Barcode scanData) async {
      if (!isScanned) {
        isScanned = true;
        widget.onScanSuccess(scanData.code);
      }
    });
    setState(() {
      hasFlash = result.hasFlash;
    });
  }
}
