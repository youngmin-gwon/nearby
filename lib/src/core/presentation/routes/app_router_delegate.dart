import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/home_screen.dart';
import 'package:poc/src/core/presentation/widgets/not_found_screen.dart';
import 'package:poc/src/core/presentation/widgets/white_text_message_dialog.dart';
import 'package:poc/src/nearby/presentation/dialogs/nearby_precondition_bluetooth_dialog.dart';
import 'package:poc/src/nearby/presentation/dialogs/nearby_precondition_denied_permission_dialog.dart';
import 'package:poc/src/nearby/presentation/dialogs/nearby_precondition_permission_dialog.dart';
import 'package:poc/src/nearby/presentation/nearby_screen.dart';
import 'package:poc/src/nearby/presentation/receiver/nearby_receiver_screen.dart';
import 'package:poc/src/nearby/presentation/receiver/widgets/bottom_sheets/nearby_receive_confirm_bottom_sheet.dart';
import 'package:poc/src/nearby/presentation/receiver/widgets/dialogs/nearby_receive_failure_dialog.dart';
import 'package:poc/src/nearby/presentation/receiver/widgets/dialogs/nearby_receive_success_dialog.dart';
import 'package:poc/src/nearby/presentation/sender/nearby_sender_screen.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/bottom_sheets/nearby_send_confirm_bottom_sheet.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/dialogs/nearby_send_failure_dialog.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/dialogs/nearby_send_interrupt_dialog.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/dialogs/nearby_send_rejection_dialog.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/dialogs/nearby_send_success_dialog.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/dialogs/not_yet_implemented_dialog.dart';

class AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        assert(settings.name?.indexOf("/") == 0,
            "[ROUTER] routing MUST Begin with '/'");

        log('[ROUTER] ${settings.name}, ${settings.arguments}');

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/'),
              builder: (_) => const HomeScreen(),
            );
          case '/nearby':
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/nearby'),
              builder: (_) => const NearbyScreen(),
            );
          case '/nearby/precondition/bluetooth':
            return DialogRoute(
              settings:
                  const RouteSettings(name: '/nearby/precondition/bluetooth'),
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (_) {
                return const NearbyPreconditionBluetoothDialog();
              },
            );
          case '/nearby/precondition/permission':
            return DialogRoute<bool>(
              settings:
                  const RouteSettings(name: '/nearby/precondition/permission'),
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (_) {
                return const NearbyPreconditionPermissionDialog();
              },
            );
          case '/nearby/precondition/no-permission':
            return DialogRoute<bool>(
              settings: const RouteSettings(
                  name: '/nearby/precondition/no-permission'),
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (_) {
                return const NearbyPreconditionDeniedPermissionDialog();
              },
            );

          /// `/nearby/receive` 관련
          case '/nearby/receive':
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/nearby/receive'),
              builder: (_) => const NearbyReceiverScreen(),
            );
          case '/nearby/receive/confirm':
            final arguments = settings.arguments as Map<String, dynamic>;
            final userName = arguments['userName'] as String;
            final dataName = arguments['dataName'] as String;
            return ModalBottomSheetRoute<bool>(
              settings: const RouteSettings(name: '/nearby/receive/confirm'),
              builder: (_) {
                return NearbyReceiveConfirmBottomSheet(
                  userName: userName,
                  dataName: dataName,
                );
              },
              isScrollControlled: false,
              isDismissible: true,
              enableDrag: true,
              showDragHandle: false,
              useSafeArea: false,
            );

          case '/nearby/receive/process':
            final arguments = settings.arguments as Map<String, dynamic>;
            final message = arguments['message'] as String;
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/receive/process'),
              context: context,
              useSafeArea: true,
              builder: (context) => WhiteTextMessageDialog(message: message),
            );
          case '/nearby/receive/success':
            final arguments = settings.arguments as Map<String, dynamic>;
            final dataName = arguments['dataName'] as String;
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/receive/success'),
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (context) =>
                  NearbyReceiveSuccessDialog(dataName: dataName),
            );
          case '/nearby/receive/failure':
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/receive/failure'),
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (context) => const NearbyReceiveFailureDialog(),
            );

          /// `/nearby/send` 관련
          case '/nearby/send':
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/nearby/send'),
              builder: (_) => const NearbySenderScreen(),
            );
          case '/nearby/send/remote':
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/remote'),
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => const NotYetImplementedDialog(),
            );
          case '/nearby/send/confirm':
            return ModalBottomSheetRoute(
              settings: const RouteSettings(name: '/nearby/send/confirm'),
              builder: (_) {
                return const NearbySendConfirmBottomSheet();
              },
              isScrollControlled: false,
              isDismissible: true,
              enableDrag: true,
              showDragHandle: false,
              useSafeArea: false,
            );
          case '/nearby/send/reject':
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/reject'),
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => const NearbySendRejectionDialog(),
            );
          case '/nearby/send/success':
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/success'),
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => const NearbySendSuccessDialog(),
            );
          case '/nearby/send/fail':
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/fail'),
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => const NearbySendFailureDialog(),
            );
          case '/nearby/send/interrupt':
            final arguments = settings.arguments as Map<String, dynamic>;
            final deviceName = arguments['deviceName'] as String;
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/interrupt'),
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => NearbySendInterruptDialog(
                deviceName: deviceName,
              ),
            );
          case '/nearby/send/process':
            final arguments = settings.arguments as Map<String, dynamic>;
            final message = arguments['message'] as String;
            return DialogRoute(
              settings: const RouteSettings(name: '/nearby/send/process'),
              context: context,
              useSafeArea: true,
              builder: (context) => WhiteTextMessageDialog(message: message),
            );
          default:
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/404'),
              builder: (_) => const NotFoundScreen(),
            );
        }
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: const RouteSettings(name: '/404'),
        builder: (_) => const NotFoundScreen(),
      ),
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  /// Web application 이 아니기 때문에 해당 메소드는 발현되지 않으므로 구현하지 않음
  @override
  Future<void> setNewRoutePath(configuration) {
    return Future.value();
  }
}
