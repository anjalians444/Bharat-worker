import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/url_constants.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/provider/payment_provider.dart';
import 'package:bharat_worker/helper/router.dart';

class PhonePeWebView extends StatefulWidget {
  final String redirectLink;
  final String title;
  final VoidCallback? onPaymentStatusDetected; // Add callback parameter

  const PhonePeWebView({
    super.key,
    required this.redirectLink,
    this.title = 'PhonePe Payment',
    this.onPaymentStatusDetected, // Add callback parameter
  });

  @override
  State<PhonePeWebView> createState() => _PhonePeWebViewState();
}

class _PhonePeWebViewState extends State<PhonePeWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  // bool _hasProcessedPaymentStatus = false; // Flag to prevent multiple API calls

  @override
  void initState() {
    super.initState();
    if (widget.redirectLink != "connect ETIMEDOUT 2606:4700::6811:4bc3:443") {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'UrlChange',
          onMessageReceived: (JavaScriptMessage message) {
            print('JavaScript URL: ${message.message}');
            _checkUrlForPaymentStatus(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar based on WebView loading progress.
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
              print('WebView started loading: $url');
            },
            onNavigationRequest: (NavigationRequest request) {
              print('WebView navigation request: ${request.url}');

              // Check for the specific payment status URL
              // _checkUrlForPaymentStatus(request.url);
              // if (request.url.contains(UrlConstants.paymentStatusUrl)) {
              //   _handlePaymentStatusUrl();
              // }

              return NavigationDecision.navigate;
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });

              print('WebView URL: $url');

              // Check for the specific payment status URL
              _checkUrlForPaymentStatus(url);
              // if (url.contains(UrlConstants.paymentStatusUrl)) {
              //   _handlePaymentStatusUrl();
              // }
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.redirectLink))
        ..addJavaScriptChannel(
          'UrlMonitor',
          onMessageReceived: (JavaScriptMessage message) {
            print('URL Monitor: ${message.message}');
            _checkUrlForPaymentStatus(message.message);
          },
        )
        ..runJavaScript('''
        // Monitor URL changes
        let currentUrl = window.location.href;
        UrlMonitor.postMessage(currentUrl);
        
        // Monitor for URL changes
        const observer = new MutationObserver(function() {
          if (window.location.href !== currentUrl) {
            currentUrl = window.location.href;
            UrlMonitor.postMessage(currentUrl);
          }
        });
        
        observer.observe(document, { subtree: true, childList: true });
        
        // Also monitor console errors for CORS
        const originalError = console.error;
        console.error = function(...args) {
          const message = args.join(' ');
          if (message.includes('CORS') || message.includes('Access-Control-Allow-Origin')) {
            UrlMonitor.postMessage('CORS_ERROR:' + message);
          }
          originalError.apply(console, args);
        };
      ''');
    }
  }

  void _checkUrlForPaymentStatus(String url) {
    print('Checking URL for payment status: $url');

    // Check for the specific payment status URL
    if (url.contains(UrlConstants.paymentStatusUrl)) {
      if (mounted) {
        // Call the callback if provided
        if (widget.onPaymentStatusDetected != null) {
          widget.onPaymentStatusDetected!();
        }
        Navigator.pop(context);
        // _handlePaymentStatusUrl();
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Prevent back navigation during payment processing
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Disable back button
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              if (widget.redirectLink !=
                  "connect ETIMEDOUT 2606:4700::6811:4bc3:443")
                WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(MyColors.appTheme),
                  ),
                ),
            ],
          ),
        ));
  }
}
