import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/widgets/assets_video_play.dart';
import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import '../cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'device_list.dart';

class DeviceSection extends StatelessWidget {
  final BluetoothConnectionState state;

  const DeviceSection({super.key, required this.state});

  bool get isConnected =>
      state.isConnected || state.status == BluetoothConnectionStatus.connected;

  bool get isScanning =>
      state.isScanning || state.status == BluetoothConnectionStatus.scanning;

  bool get hasDevices => state.devices.isNotEmpty;

  bool get validDeviceId =>
      state.connectingDeviceId != null &&
          RegExp(r'^\d+$').hasMatch(state.connectingDeviceId!);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: rh(context: context, px: 82)),
        Padding(
          padding: EdgeInsets.all(rh(context: context, px: 8)),
          child: _buildTopVisualSmooth(state),
        ),
        if (!isConnected) _buildContent(context),
        if (isConnected) ...[
          SizedBox(height: rh(context: context, px: 20)),
          if (validDeviceId)
            _buildDeviceInfo(context)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.deviceReady)
                  SvgPicture.asset("assets/images/device_connection/device_id.svg"),
                if (state.deviceReady) const SizedBox(width: 10),
                Text(
                  state.deviceReady
                      ? "Device is ready"
                      : "getting your device ready...",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          SizedBox(height: rh(context: context, px: 30)),
          Text(
            "Device Connected",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (!isConnected) ...[
          SizedBox(height: rh(context: context, px: 20)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 20)),
            child: DeviceList(state: state),
          ),
        ],
      ],
    );
  }

  Widget _buildTopVisualSmooth(BluetoothConnectionState state) {
    final child = _buildTopVisualWithThumbnailFallback(state);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: SizedBox(
        key: ValueKey<String>(_topVisualKey(state)),
        width: double.infinity,
        child: child,
      ),
    );
  }

  String _topVisualKey(BluetoothConnectionState state) {
    if (state.isConnected) return "connected";
    if (state.isScanning) return "scanning";
    return "not_connected";
  }

  Widget _buildTopVisualWithThumbnailFallback(BluetoothConnectionState state) {
    const thumb = "assets/images/device_connection/new_device_not_connected.png";

    if (state.isConnected) {
      return Image.asset(
        "assets/images/device_connection/new_device_connected.png",
        fit: BoxFit.contain,
      );
    }

    if (isScanning) {
      return Stack(
        alignment: Alignment.center,
        children: const [
          Image(image: AssetImage(thumb), fit: BoxFit.contain),
          AssetVideoWidget(
            videoPath: 'assets/images/device_connection/device_scanning.mp4',
            thumbnailPath: thumb,
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: const [
        Image(image: AssetImage(thumb), fit: BoxFit.contain),
        AssetVideoWidget(
          videoPath: 'assets/images/device_connection/device_not_connected_video.mp4',
          thumbnailPath: thumb,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isScanning) {
      return Center(
        child: Text(
          "Finding....",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (!hasDevices) {
      return _buildNoDevice(context);
    }

    if (state.isConnecting) {
      return Text(
        'Connecting...',
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: rh(context: context, px: 20),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return _buildDeviceList(context);
  }

  Widget _buildDeviceInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/images/device_connection/device_id.svg'),
        SizedBox(width: rh(context: context, px: 4)),
        Text(
          'Device Id:',
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.24,
          ),
        ),
        SizedBox(width: rh(context: context, px: 4)),
        Text(
          'RESPYR${state.connectingDeviceId}',
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.24,
          ),
        ),
        SizedBox(width: rh(context: context, px: 10)),
      ],
    );
  }

  Widget _buildNoDevice(BuildContext context) {
    return Column(
      children: [
        Text(
          'No Device Found',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: rh(context: context, px: 10)),
        _retryButton(context),
      ],
    );
  }

  Widget _buildDeviceList(BuildContext context) {
    return Column(
      children: [
        Text(
          'Found ${state.devices.length} Devices',
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: rh(context: context, px: 10)),
        _retryButton(context),
      ],
    );
  }

  Widget _retryButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<BluetoothConnectionCubit>().startScan(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/images/device_connection/retry.svg"),
          SizedBox(width: rh(context: context, px: 5)),
          Text(
            'Retry',
            style: GoogleFonts.poppins(
              color: const Color(0xFF308BF9),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
