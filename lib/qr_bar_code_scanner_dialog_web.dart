// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html
//     show window, Element, ScriptElement, StyleElement, querySelector, Text;

import 'dart:js_interop';
import 'dart:js_util' as js_util;

import 'package:web/web.dart' as web;
// show window, Element, HTMLScriptElement, HTMLStyleElement, Text;

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// import 'dart:js' as js;

import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog_platform_interface.dart';

const String _kQrBarCodeScannerModelDomId = '__qr_bar_code_scanner_web-model';

/// A web implementation of the QrBarCodeScannerDialogPlatform of the QrBarCodeScannerDialog plugin.
class QrBarCodeScannerDialogWeb extends QrBarCodeScannerDialogPlatform {
  /// Constructs a QrBarCodeScannerDialogWeb
  QrBarCodeScannerDialogWeb() {
    _ensureInitialized(_kQrBarCodeScannerModelDomId);
  }

  static void registerWith(Registrar registrar) {
    QrBarCodeScannerDialogPlatform.instance = QrBarCodeScannerDialogWeb();
  }

  /// Initializes a DOM container where we can host input elements.
  web.Element _ensureInitialized(String id) {
    var target = web.document.querySelector('#$id');
    if (target == null) {
      final web.Element targetElement = web.HTMLDivElement()
        ..id = id
        ..className = "modal";

      final web.Element content = web.HTMLDivElement()
        ..className = "modal-content";

      final web.Element div = web.HTMLDivElement()
        ..setAttribute("style", "container");

      final web.Element reader = web.HTMLDivElement()
        ..id = "qr-reader"
        ..setAttribute("width", "400px");
      div.appendChild(reader);

      content.appendChild(div);
      targetElement.appendChild(content);

      final body = web.document.querySelector('body')!;

      body.appendChild(targetElement);

      final script = web.HTMLScriptElement()
        ..src = "https://unpkg.com/html5-qrcode";
      body.appendChild(script);

      final head = web.document.querySelector('head')!;

      final style = web.HTMLStyleElement();

      final styleContent = web.Text("""
        
        /* The Modal (background) */
        .modal {
          display: none; /* Hidden by default */
          position: fixed; /* Stay in place */
          z-index: 1; /* Sit on top */
          padding-top: 100px; /* Location of the box */
          left: 0;
          top: 0;
          width: 100%; /* Full width */
          height: 100%; /* Full height */
          overflow: auto; /* Enable scroll if needed */
          background-color: rgb(0,0,0); /* Fallback color */
          background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
        }
        
        /* Modal Content */
        .modal-content {
          margin: auto;
          max-width: 600px;
          border-radius: 10px;
        }
        
        #qr-reader {
          position: relative;
          background: white;
          margin: 25px;
          border-radius: 10px;
          border: none;
        }
        
        #qr-reader__filescan_input,
        #qr-reader__camera_permission_button {
          background: #3b99e8;
          border: none;
          padding: 8px;
          border-radius: 5px;
          color: white;
          cursor:pointer;
          margin-bottom: 10px;
        }
      
      """);

      final codeScript = web.HTMLScriptElement();
      final scriptText = web.Text(r"""
        
        var html5QrcodeScanner;

        // Get the modal
        var modal = document.getElementById("__qr_bar_code_scanner_web-model");
        
        // When the user clicks anywhere outside of the modal, close it
        window.onclick = function(event) {
          if (event.target == modal) {
            modal.style.display = "none";
              if(html5QrcodeScanner!=null)
                html5QrcodeScanner.clear();
          }
        }

        async function scanCode(message) {
        
            html5QrcodeScanner = new Html5QrcodeScanner("qr-reader", { fps: 20, qrbox: 250 });
        
            modal.style.display = "block";
            html5QrcodeScanner.render((decodedText, decodedResult) => {
                console.log(`Code scanned = ${decodedText}`, decodedResult);
                message(`Code scanned = ${decodedText}`);
                html5QrcodeScanner.clear();
                modal.style.display = "none";
            });
        
        
        }
        
      """);
      codeScript.appendChild(scriptText);
      // codeScript.childNodes.add(scriptText);
      // codeScript.nodes.add(scriptText);

      // style.childNodes.add(styleContent);
      style.appendChild(styleContent);

      // style.nodes.add(styleContent);
      // head.children.add(style);
      head.appendChild(style);
      // head.children.add(codeScript);
      head.appendChild(codeScript);
      target = targetElement;
    }
    return target;
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  void scanBarOrQrCode(
      {BuildContext? context, required Function(String?) onScanSuccess}) {
    js_util.callMethod(
        js_util.globalThis, "scanCode", [js_util.allowInterop(onScanSuccess)]);
  }
}