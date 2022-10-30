import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ModalWalletAndroidWidget extends StatelessWidget {
  const ModalWalletAndroidWidget({
    required this.uri,
    this.text = 'Connect',
    this.buttonStyle,
    this.textStyle,
    this.textAlign,
    Key? key,
  }) : super(key: key);

  final String uri;
  final String text;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: () => launchUrl(Uri.parse(uri)),
        child: Text(
          text,
          style: textStyle,
          textAlign: textAlign,
        ),
      ),
    );
  }

  ModalWalletAndroidWidget copyWith({
    ButtonStyle? buttonStyle,
    TextStyle? textStyle,
    TextAlign? textAlign,
    Key? key,
  }) =>
      ModalWalletAndroidWidget(
        uri: uri,
        text: text,
        buttonStyle: buttonStyle,
        textStyle: textStyle ?? this.textStyle,
        textAlign: textAlign ?? textAlign,
        key: key ?? this.key,
      );
}
