import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OtpVerifyView extends StatefulWidget {
  const OtpVerifyView({Key? key}) : super(key: key);

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  late List<FocusNode> _focusNodes;
  // late List<TextEditingController> _controllers;
  late TextEditingController _otpControllers;
  int _timerSeconds = 30;
  String? _otpError;
  late final Ticker _ticker;
  String _currentOtp = '';
  bool _shouldClearOtp = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (_) => FocusNode());
    _otpControllers = TextEditingController(); // ✅ Add this line
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 30;
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
    _otpControllers.dispose(); // ✅ Add this line
    _ticker.dispose();
    super.dispose();
  }





  Future<void> _verifyOtp(AuthProvider authProvider, LanguageProvider languageProvider) async {
    setState(() {
      _otpError = null;
    });
    if (_otpControllers.text.length < 6) {
      setState(() {
        _otpError = languageProvider.translate('wrong_otp');
      });
      return;
    }
    final success = await authProvider.verifyOtp(context,_otpControllers.text);
    if (!success) {
      setState(() {
        _otpError = authProvider.firebaseErrorMsg ?? languageProvider.translate('wrong_otp');
      });
    } else {
    }
  }

  void _resendOtp(AuthProvider authProvider) async {
    await authProvider.resendOtp();
    //for (final c in _controllers) {
    _otpControllers.clear();
    _currentOtp = '';
    _shouldClearOtp = true;
    // }
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
      }, isLeading: false,""),
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
                "${languageProvider.translate('otp_sent_to')} +${authProvider.selectedCountry!.phoneCode}${authProvider.phoneController.text}", // TODO: dynamic phone
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
              const SizedBox(height: 32),
              OtpTextField(
                numberOfFields: 6,
                //controller: _otpControllers,
                clearText: _shouldClearOtp,
                showCursor: true,
                fieldWidth: 45,
                fieldHeight: 60,
                borderColor: Color(0xFF512DA8),
                //set to true to show as box or false to show as dash
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(12),
                enabledBorderColor:MyColors.borderColor,
                disabledBorderColor:  MyColors.borderColor,
                focusedBorderColor: MyColors.appTheme,
                borderWidth: 1,
                enabled: !(authProvider.isVerifyingOtp || authProvider.isLoading),
                // styles: [boldTextStyle(fontSize: 24.0, color: MyColors.blackColor)],
                textStyle: boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
                //runs when a code is typed in
                onCodeChanged: (String code) {
                  //handle validation or checks here
                  _otpControllers.text = code;
                  _currentOtp = code;
                  if (_shouldClearOtp) {
                    setState(() {
                      _shouldClearOtp = false;
                    });
                  }
                },
                //runs when every textfield is filled
                onSubmit: (String verificationCode){
                  _otpControllers.text = verificationCode;
                  _currentOtp = verificationCode;
                  if (_shouldClearOtp) {
                    setState(() {
                      _shouldClearOtp = false;
                    });
                  }

                }, // end onSubmit
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

              hsized40,
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${languageProvider.translate('code_expires_in')}: 0:${_timerSeconds.toString().padLeft(2, '0')}',
                  style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                ),
              ),
              const SizedBox(height: 24),
              authProvider.isVerifyingOtp || authProvider.isLoading?
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ) :
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