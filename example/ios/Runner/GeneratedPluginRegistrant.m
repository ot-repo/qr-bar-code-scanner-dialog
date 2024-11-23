//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<qr_bar_code_scanner_dialog/QrBarCodeScannerDialogPlugin.h>)
#import <qr_bar_code_scanner_dialog/QrBarCodeScannerDialogPlugin.h>
#else
@import qr_bar_code_scanner_dialog;
#endif

#if __has_include(<qr_code_scanner/FlutterQrPlugin.h>)
#import <qr_code_scanner/FlutterQrPlugin.h>
#else
@import qr_code_scanner;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [QrBarCodeScannerDialogPlugin registerWithRegistrar:[registry registrarForPlugin:@"QrBarCodeScannerDialogPlugin"]];
  [FlutterQrPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterQrPlugin"]];
}

@end
