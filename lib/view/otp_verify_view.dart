import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OtpVerifyView extends StatefulWidget {
  const OtpVerifyView({Key? key}) : super(key: key);

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _timerSeconds = 60;
  String? _otpError;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (_) => FocusNode());
    _controllers = List.generate(6, (_) => TextEditingController());
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 75;
    _ticker = Ticker((_) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _ticker.dispose();
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _ticker.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int idx, String value) {
    if (value.length == 1 && idx < 5) {
      _focusNodes[idx + 1].requestFocus();
    }
    if (value.isEmpty && idx > 0) {
      _focusNodes[idx - 1].requestFocus();
    }
    setState(() {
      _otpError = null;
    });
  }

  Future<void> _verifyOtp(AuthProvider authProvider, LanguageProvider languageProvider) async {
    setState(() {
      _otpError = null;
    });
    if (_otp.length < 6) {
      setState(() {
        _otpError = languageProvider.translate('wrong_otp');
      });
      return;
    }
    final success = await authProvider.verifyOtp(context,_otp);
    if (!success) {
      setState(() {
        _otpError = authProvider.firebaseErrorMsg ?? languageProvider.translate('wrong_otp');
      });
    } else {
    }
  }

  void _resendOtp(AuthProvider authProvider) async {
    await authProvider.resendOtp();
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {
      _otpError = null;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, ""),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal:16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageProvider.translate('verification_code'),
                style: boldTextStyle(fontSize: 32.0, color: MyColors.blackColor),
              ),
              hsized12,
              Text(
                "${languageProvider.translate('otp_sent_to')} +91 98765 43210", // TODO: dynamic phone
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (idx) {
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      width: 80,
                      height:65,
                      child: TextField(
                        controller: _controllers[idx],
                        focusNode: _focusNodes[idx],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: MyColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: MyColors.appTheme),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) => _onOtpChanged(idx, v),
                      ),
                    ),
                  );
                }),
              ),
              if (_otpError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Expanded(child: Text(_otpError!, style: TextStyle(color: Colors.red, fontSize: 12))),
                    ],
                  ),
                ),
              if (authProvider.isVerifyingOtp || authProvider.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              hsized40,
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${languageProvider.translate('code_expires_in')}: 0:${_timerSeconds.toString().padLeft(2, '0')}',
                  style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                ),
              ),
              const SizedBox(height: 24),
              CommonButton(
                text: languageProvider.translate('next'),
                onTap: (){
                  _verifyOtp(authProvider,languageProvider);
                },
                backgroundColor: MyColors.appTheme,
                textColor: Colors.white,
                width: double.infinity,
                margin: EdgeInsets.all(0),
              ),
            hsized40,
              Center(
                child: Text.rich(
                  TextSpan(
                    text: languageProvider.translate('did_not_receive_otp'),
                    style: regularTextStyle(fontSize: 14.0, color:MyColors.lightText),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: (){
                            _timerSeconds == 0 ? _resendOtp(authProvider) : null;
                          },
                          child: Text(
                            languageProvider.translate('resend_code'),
                            style: regularTextStyle(
                              fontSize: 14.0,
                              color: _timerSeconds == 0 ? MyColors.appTheme : Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple ticker for timer
class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _isActive = false;

  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }

  void start() {
    _isActive = true;
    _stopwatch.start();
    _tick();
  }

  void _tick() async {
    while (_isActive) {
      await Future.delayed(_interval);
      if (!_isActive) break;
      onTick(_stopwatch.elapsed);
    }
  }

  void dispose() {
    _isActive = false;
    _stopwatch.stop();
  }
} 