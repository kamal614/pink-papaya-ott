import 'dart:async';

import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../pages/bottombar.dart';
import '../tvpages/tvhome.dart';
import '../webservice/apiservices.dart';



class OTPVerifyWeb extends StatefulWidget {
  final String? mobileNumber;
  const OTPVerifyWeb(this.mobileNumber, {Key? key}) : super(key: key);

  @override
  State<OTPVerifyWeb> createState() => _OTPVerifyWebState();
}


class _OTPVerifyWebState extends State<OTPVerifyWeb> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPre sharePref = SharedPre();
  final numberController = TextEditingController();
  final pinPutController = TextEditingController();
  ScrollController scollController = ScrollController();
  String? verificationId, finalOTP;
  int? forceResendingToken;
  bool codeResended = false;

   late Timer _resendTimer;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    // _getDeviceToken();
    startResendTimer();
    _sendWhatsappOTP();
    //prDialog = ProgressDialog(context);
    // codeSend(false);
  }

   void startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendTimer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

   _sendWhatsappOTP() async {
    await ApiService().loginWithWhatsapp(widget.mobileNumber);
  }





  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    numberController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      constraints: const BoxConstraints(
        minWidth: 300,
        minHeight: 0,
        maxWidth: 350,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                focusColor: white.withOpacity(0.5),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    child: MyImage(
                      fit: BoxFit.fill,
                      imagePath: "backwith_bg.png",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            MyText(
              color: white,
              text: "verifyphonenumber",
              fontsizeNormal: 26,
              fontsizeWeb: 21,
              multilanguage: true,
              fontweight: FontWeight.bold,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 8),
            MyText(
              color: otherColor,
              text: "code_sent_desc",
              fontsizeNormal: 15,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 3,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              multilanguage: true,
              fontstyle: FontStyle.normal,
            ),
            MyText(
              color: otherColor,
              text: widget.mobileNumber ?? "",
              fontsizeNormal: 15,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 3,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              multilanguage: false,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 40),

            /* Enter Received OTP */
          
           Pinput(
                  length: 4,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  controller: pinPutController,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  defaultPinTheme: PinTheme(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorPrimary, width: 0.7),
                      shape: BoxShape.rectangle,
                      color: edtBG,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: GoogleFonts.montserrat(
                      color: white,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            
            const SizedBox(height: 30),

            /* Confirm Button */
          InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    debugPrint(
                        "Clicked sms Code =====> ${pinPutController.text}");
                    if (pinPutController.text.toString().isEmpty) {
                      Utils.showSnackbar(
                          context, "info", "enterreceivedotp", true);
                    } else {
                      // if (verificationId == null || verificationId == "") {
                      //   Utils.showSnackbar(
                      //       context, "info", "otp_not_working", true);
                      //   return;
                      // }
                     // Utils.showProgress(context, prDialog);
                      _checkOTPAndLogin();
                    
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primaryLight,
                          primaryDark,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child:Text('confirm')
                    //  MyText(
                    //   color: white,
                    //   text: "confirm",
                    //   fontsizeNormal: 17,
                    //   multilanguage: true,
                    //   fontweight: FontWeight.w700,
                    //   maxline: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   textalign: TextAlign.center,
                    //   fontstyle: FontStyle.normal,
                    // ),
                  ),
                ),
           const SizedBox(height: 30),
           

            /* Resend */
            InkWell(
                  borderRadius: BorderRadius.circular(10),
                   onTap: _resendCountdown == 0 ? () {
                    _sendWhatsappOTP();
                    setState(() {
                      _resendCountdown = 30; // Reset the countdown
                    });
                    startResendTimer(); // Start the countdown again
                  } : null, 
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 70),
                    padding: const EdgeInsets.all(5),
                    child: _resendCountdown == 0
                        ? Text(
                            "Resend",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500  ,
                                fontSize: 20),
                          )
                        : Text("Resend OTP in 00:${_resendCountdown} second" ,style: TextStyle(
                                color: whiteLight,
                                fontWeight: FontWeight.w400  ,
                                fontSize: 14)),
                    
                  ),
                ),
            
              
          ],
        ),
      ),
    );
  }

  // codeSend(bool isResend) async {
  //   codeResended = isResend;
  //   await phoneSignIn(
  //       phoneNumber: widget.mobileNumber.toString(), isResend: isResend);
  // }



   Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }
 
  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    debugPrint("verification completed ======> ${authCredential.smsCode}");
    setState(() {
      pinPutController.text = authCredential.smsCode ?? "";
    });
  }
 
  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      debugPrint("The phone number entered is invalid!");
      Utils.showSnackbar(context, "fail", "invalidphonenumber", true);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    debugPrint("verificationId =======> $verificationId");
    debugPrint("resendingToken =======> ${forceResendingToken.toString()}");
    debugPrint("code sent");
  }
  





  // _onCodeSent(String verificationId, int? forceResendingToken) {
  //   this.verificationId = verificationId;
  //   this.forceResendingToken = forceResendingToken;
  //   debugPrint("resendingToken =======> ${forceResendingToken.toString()}");
  //   debugPrint("code sent");
  // }

 _onCodeTimeout(String verificationId) {
    debugPrint("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
   // prDialog.hide();
    codeResended = false;
    return null;
  }





  _checkOTPAndLogin() async {
    // bool error = false;
    // UserCredential? userCredential;
 
    debugPrint("_checkOTPAndLogin verificationId =====> $verificationId");
    debugPrint("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
 
    // Create a PhoneAuthCredential with the code
    // PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
    //   verificationId: verificationId ?? "",
    //   smsCode: pinPutController.text.toString(),
    // );
 
    // debugPrint(
    //     "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}");
    // debugPrint(
    //     "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
 
    await ApiService()
        .verifyLoginWithWhatsapp(widget.mobileNumber.toString(), pinPutController.text)
        .then((value) async {
      if (value) {
        _login(widget.mobileNumber.toString());
      } else {
       // await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(context, "info", "otp_invalid", true);
        return;
      }
    });

 
    // try {
    //   userCredential = await _auth.signInWithCredential(phoneAuthCredential);
    //   debugPrint(
    //       "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
    // } on FirebaseAuthException catch (e) {
    //   await prDialog.hide();
    //   debugPrint("_checkOTPAndLogin error Code =====> ${e.code}");
    //   if (e.code == 'invalid-verification-code' ||
    //       e.code == 'invalid-verification-id') {
    //     if (!mounted) return;
    //     Utils.showSnackbar(context, "info", "otp_invalid", true);
    //     return;
    //   } else if (e.code == 'session-expired') {
    //     if (!mounted) return;
    //     Utils.showSnackbar(context, "fail", "otp_session_expired", true);
    //     return;
    //   } else {
    //     error = true;
    //   }
    // }
    // debugPrint(
    //     "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
 
    // if (!error && userCredential != null) {
    //   _login(widget.mobileNumber.toString());
    // } else {
    //   await prDialog.hide();
    //   if (!mounted) return;
    //   Utils.showSnackbar(context, "fail", "otp_login_fail", true);
    // }
  }


_login(String mobile) async {
    debugPrint("click on Submit mobile => $mobile");
    var generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    // if (!prDialog.isShowing()) {
    //   //Utils.showProgress(context, prDialog);
    // }
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    await generalProvider.loginWithOTP(mobile);
 
    if (!generalProvider.loading) {
      if (generalProvider.loginOTPModel.status == 200) {
        debugPrint(
            'loginOTPModel ==>> ${generalProvider.loginOTPModel.toString()}');
        debugPrint('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginOTPModel.result?[0].id.toString(),
          userName: generalProvider.loginOTPModel.result?[0].name.toString(),
          userEmail: generalProvider.loginOTPModel.result?[0].email.toString(),
          userMobile:
              generalProvider.loginOTPModel.result?[0].mobile.toString(),
          userImage: generalProvider.loginOTPModel.result?[0].image.toString(),
          userPremium:
              generalProvider.loginOTPModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginOTPModel.result?[0].type.toString(),
        );
 
        // Set UserID for Next
        Constant.userID =
            generalProvider.loginOTPModel.result?[0].id.toString();
        debugPrint('Constant userID ==>> ${Constant.userID}');
 
        await homeProvider.setLoading(true);
        await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1");
 
       // await prDialog.hide();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>  TVHome(pageName: "")),
          (Route<dynamic> route) => false,
        );
      } else {
       // await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, "fail", "${generalProvider.loginOTPModel.message}", false);
      }
    }
  }
}
