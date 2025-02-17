import 'dart:math';

import 'package:flutter/material.dart';
import 'package:walletconnect_qrcode_modal_dart/src/components/modal_segment_thumb_widget.dart';
import 'package:walletconnect_qrcode_modal_dart/src/components/modal_selector_widget.dart';

import '../models/wallet.dart';
import '../store/wallet_store.dart';
import '/src/modal_main_page.dart';
import '/src/utils/utils.dart';
import '/src/components/modal_qrcode_widget.dart';
import 'modal_platform_overrides.dart';
import 'modal_wallet_list_widget.dart';
import 'modal_wallet_button_widget.dart';

/// Custom segment thumb builder
typedef ModalSelectorBuilder = Widget Function(
  BuildContext context,
  ModalSelectorWidget defaultSelectorWidget,
);

/// Custom segment thumb builder
typedef ModalSegmentThumbBuilder = Widget Function(
  BuildContext context,
  ModalSegmentThumbWidget defaultSegmentThumbWidget,
);

/// Custom wallet button builder
typedef ModalWalletButtonBuilder = Widget Function(
  BuildContext context,

  /// Represents one click button on Android
  ModalWalletButtonWidget defaultWalletButtonWidget,
);

/// Custom wallet list builder
typedef ModalWalletListBuilder = Widget Function(
  BuildContext context,

  /// Represents selection list on iOS/desktop
  ModalWalletListWidget defaultWalletListWidget,
);

/// Custom QR code builder
typedef ModalQrCodeBuilder = Widget Function(
  BuildContext context,

  /// Represents QR code
  ModalQrCodeWidget defaultQrCodeWidget,
);

class ModalWidget extends StatefulWidget {
  const ModalWidget({
    required this.uri,
    this.walletCallback,
    this.width,
    this.height,
    this.cardColor,
    this.cardPadding,
    this.cardShape,
    this.selectorBuilder,
    this.walletButtonBuilder,
    this.walletListBuilder,
    this.qrCodeBuilder,
    this.platformOverrides,
    this.shouldVerifyNativeLinks = false,
    this.onOpenWalletFailure,
    this.onOpenWalletSuccess,
    this.chain,
    Key? key,
  }) : super(key: key);

  /// WallectConnect URI
  final String uri;

  /// Wallet callback (when wallet is selected)
  final WalletCallback? walletCallback;

  /// Height of the modal
  final double? width;

  /// Width of the modal
  final double? height;

  /// Content card color
  final Color? cardColor;

  /// Content card padding
  final EdgeInsets? cardPadding;

  /// Content card shape
  final ShapeBorder? cardShape;

  /// Modal selector widget (for choosing between list and QR)
  final ModalSelectorBuilder? selectorBuilder;

  /// Modal content for Android
  final ModalWalletButtonBuilder? walletButtonBuilder;

  /// Modal content for iOS/desktop
  final ModalWalletListBuilder? walletListBuilder;

  /// Modal content QR code
  final ModalQrCodeBuilder? qrCodeBuilder;

  /// Platform overrides for wallet widgets
  final ModalWalletPlatformOverrides? platformOverrides;

  /// Whether it should try to verify the native link is openable.
  /// This would require the native link scheme to be added to
  /// `LSApplicationQueriesSchemes`. Default is false.
  final bool shouldVerifyNativeLinks;

  /// This callback is invoked when the Wallet link fails to open.
  /// Parameter is the failed Wallet object.
  final Function(Wallet)? onOpenWalletFailure;

  final Function(Wallet)? onOpenWalletSuccess;

  final String? chain;

  @override
  State<ModalWidget> createState() => _ModalWidgetState();

  ModalWidget copyWith({
    double? width,
    double? height,
    EdgeInsets? cardPadding,
    Color? cardColor,
    ShapeBorder? cardShape,
    ModalSelectorBuilder? selectorBuilder,
    ModalWalletButtonBuilder? walletButtonBuilder,
    ModalWalletListBuilder? walletListBuilder,
    ModalQrCodeBuilder? qrCodeBuilder,
    ModalWalletPlatformOverrides? platformOverrides,
    bool? shouldVerifyNativeLinks,
    Function(Wallet)? onOpenWalletFailure,
    Function(Wallet)? onOpenWalletSuccess,
    String? chain,
    Key? key,
  }) =>
      ModalWidget(
        uri: uri,
        walletCallback: this.walletCallback,
        width: width ?? this.width,
        height: height ?? this.height,
        cardPadding: cardPadding ?? this.cardPadding,
        cardColor: cardColor ?? this.cardColor,
        cardShape: cardShape ?? this.cardShape,
        selectorBuilder: selectorBuilder ?? this.selectorBuilder,
        walletButtonBuilder: walletButtonBuilder ?? this.walletButtonBuilder,
        walletListBuilder: walletListBuilder ?? this.walletListBuilder,
        qrCodeBuilder: qrCodeBuilder ?? this.qrCodeBuilder,
        platformOverrides: platformOverrides ?? this.platformOverrides,
        shouldVerifyNativeLinks:
            shouldVerifyNativeLinks ?? this.shouldVerifyNativeLinks,
        onOpenWalletFailure: onOpenWalletFailure ?? this.onOpenWalletFailure,
        chain: chain,
        onOpenWalletSuccess: onOpenWalletSuccess ?? this.onOpenWalletSuccess,
        key: key ?? this.key,
      );
}

class _ModalWidgetState extends State<ModalWidget> {
  int selectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final defaultSelectorWidget = ModalSelectorWidget(
      selection: selectionIndex,
      onSelectionChanged: (selection) =>
          setState(() => selectionIndex = selection),
    );

    final Widget selectorWidget;
    if (widget.selectorBuilder != null) {
      selectorWidget =
          widget.selectorBuilder!.call(context, defaultSelectorWidget);
    } else {
      selectorWidget = defaultSelectorWidget;
    }

    return Center(
      child: SizedBox(
        width: widget.width ?? MediaQuery.of(context).size.width * 0.9,
        height:
            widget.height ?? max(500, MediaQuery.of(context).size.height * 0.5),
        child: Card(
          color: widget.cardColor,
          shape: widget.cardShape,
          child: Padding(
            padding: widget.cardPadding ?? const EdgeInsets.all(8),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  selectorWidget,
                  Expanded(
                    child: _ModalContent(
                        groupValue: selectionIndex,
                        walletCallback: widget.walletCallback,
                        uri: widget.uri,
                        walletButtonBuilder: widget.walletButtonBuilder,
                        walletListBuilder: widget.walletListBuilder,
                        qrCodeBuilder: widget.qrCodeBuilder,
                        platformOverrides: widget.platformOverrides,
                        shouldVerifyNativeLinks: widget.shouldVerifyNativeLinks,
                        onOpenWalletFailure: widget.onOpenWalletFailure,
                        onOpenWalletSuccess: widget.onOpenWalletSuccess,
                        chain: widget.chain),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent({
    required this.groupValue,
    required this.uri,
    required this.shouldVerifyNativeLinks,
    this.walletCallback,
    this.walletButtonBuilder,
    this.walletListBuilder,
    this.qrCodeBuilder,
    this.platformOverrides,
    this.onOpenWalletFailure,
    this.onOpenWalletSuccess,
    this.chain,
    Key? key,
  }) : super(key: key);

  final int groupValue;
  final String uri;
  final WalletCallback? walletCallback;
  final ModalWalletButtonBuilder? walletButtonBuilder;
  final ModalWalletListBuilder? walletListBuilder;
  final ModalQrCodeBuilder? qrCodeBuilder;
  final ModalWalletPlatformOverrides? platformOverrides;
  final bool shouldVerifyNativeLinks;
  final Function(Wallet)? onOpenWalletFailure;
  final Function(Wallet)? onOpenWalletSuccess;
  final String? chain;

  @override
  Widget build(BuildContext context) {
    void showLinkError(BuildContext context, Wallet wallet) {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Unable to open ${wallet.name} app!'),
          children: [
            SimpleDialogOption(
              child: const Text(
                'OK',
                textAlign: TextAlign.center,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }

    Widget platformOverride(ModalWalletType type) {
      switch (type) {
        case ModalWalletType.button:
          return ModalWalletButtonWidget(uri: uri);
        case ModalWalletType.listMobile:
          return ModalWalletListWidget(
            url: uri,
            wallets: _mobileWallets,
            walletCallback: walletCallback,
            onWalletTap: (wallet, url) async {
              final result = await Utils.iosLaunch(
                wallet: wallet,
                uri: url,
                verifyNativeLink: shouldVerifyNativeLinks,
              );
              if (!result) {
                if (onOpenWalletFailure != null) {
                  onOpenWalletFailure!.call(wallet);
                } else {
                  if (context.mounted) {
                    showLinkError(context, wallet);
                  }
                }
              } else {
                if (onOpenWalletSuccess != null) {
                  onOpenWalletSuccess!.call(wallet);
                }
              }
            },
          );
        case ModalWalletType.listDesktop:
          return ModalWalletListWidget(
            url: uri,
            wallets: _desktopWallets,
            walletCallback: walletCallback,
            onWalletTap: (wallet, url) async {
              final result = await Utils.desktopLaunch(
                wallet: wallet,
                uri: uri,
              );
              if (!result) {
                if (onOpenWalletFailure != null) {
                  onOpenWalletFailure!.call(wallet);
                } else {
                  if (context.mounted) {
                    showLinkError(context, wallet);
                  }
                }
              } else {
                if (onOpenWalletSuccess != null) {
                  onOpenWalletSuccess!.call(wallet);
                }
              }
            },
          );
      }
    }

    Widget callBuilder(ModalWalletType type, Widget defaultWidget) {
      switch (type) {
        case ModalWalletType.button:
          if (walletButtonBuilder != null) {
            return walletButtonBuilder!.call(
              context,
              defaultWidget as ModalWalletButtonWidget,
            );
          } else {
            return defaultWidget;
          }
        case ModalWalletType.listMobile:
        case ModalWalletType.listDesktop:
          if (walletListBuilder != null) {
            return walletListBuilder!
                .call(context, defaultWidget as ModalWalletListWidget);
          } else {
            return defaultWidget;
          }
      }
    }

    if (groupValue == (Utils.isDesktop ? 1 : 0)) {
      final ModalWalletType type;
      if (Utils.isIOS) {
        if (platformOverrides?.ios != null) {
          type = platformOverrides!.ios!;
        } else {
          type = ModalWalletType.listMobile;
        }
      } else if (Utils.isAndroid) {
        if (platformOverrides?.android != null) {
          type = platformOverrides!.android!;
        } else {
          type = ModalWalletType.button;
        }
      } else {
        if (platformOverrides?.desktop != null) {
          type = platformOverrides!.desktop!;
        } else {
          type = ModalWalletType.listDesktop;
        }
      }
      final defaultWidget = platformOverride(type);
      return callBuilder(type, defaultWidget);
    }

    final qrCodeWidget = ModalQrCodeWidget(uri: uri);

    if (qrCodeBuilder != null) {
      return qrCodeBuilder!.call(context, qrCodeWidget);
    }
    return qrCodeWidget;
  }

  Future<List<Wallet>> get _mobileWallets {
    Future<bool> shouldShow(wallet) async =>
        await Utils.openableLink(wallet.mobile.universal) ||
        await Utils.openableLink(wallet.mobile.native) ||
        (!Utils.isDesktop &&
            await Utils.openableLink(
                Utils.isAndroid ? wallet.app.android : wallet.app.ios));

    return const WalletStore().load().then(
      (wallets) async {
        final filter = <Wallet>[];
        for (final wallet in wallets) {
          try {
            if (await shouldShow(wallet)) {
              if (this.chain == null ||
                  (this.chain != null && wallet.chains.contains(this.chain))) {
                filter.add(wallet);
              }
            }
          } catch (e) {
            debugPrint('Some links invalid for ${wallet.name}');
          }
        }
        return filter;
      },
    );
  }

  Future<List<Wallet>> get _desktopWallets {
    return const WalletStore().load().then(
          (wallets) => wallets
              .where(
                (wallet) =>
                    Utils.linkHasContent(wallet.desktop.universal) ||
                    Utils.linkHasContent(wallet.desktop.native),
              )
              .toList(),
        );
  }
}
