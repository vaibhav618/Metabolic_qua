import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/device_update_cubit.dart';
import '../cubit/device_update_state.dart';

class FirmwareUpdateScreen extends StatelessWidget {
  const FirmwareUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Firmware"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<DeviceUpdateCubit, DeviceUpdateState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(state.status),
                  const SizedBox(height: 32),
                  _buildStatusText(state),
                  const SizedBox(height: 48),
                  _buildActionArea(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(DeviceUpdateStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case DeviceUpdateStatus.success:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case DeviceUpdateStatus.error:
        iconData = Icons.error;
        color = Colors.red;
        break;
      case DeviceUpdateStatus.flashing:
        iconData = Icons.system_update_tv;
        color = Colors.blue;
        break;
      case DeviceUpdateStatus.updateAvailable:
        iconData = Icons.new_releases;
        color = Colors.orange;
        break;
      case DeviceUpdateStatus.upToDate:
        iconData = Icons.verified;
        color = Colors.green;
        break;
      default:
        iconData = Icons.memory;
        color = Colors.grey;
    }

    return Icon(iconData, size: 100, color: color);
  }

  Widget _buildStatusText(DeviceUpdateState state) {
    String title = "Check for Updates";
    String subtitle = "Ensure your Respyr device is connected.";

    switch (state.status) {
      case DeviceUpdateStatus.checkingVersion:
        title = "Checking Version...";
        subtitle = "Asking the device for its current firmware.";
        break;
      case DeviceUpdateStatus.updateAvailable:
        title = "Update Available!";
        subtitle =
            "Version ${state.latestVersion} is ready to install.\n(Current: ${state.currentVersion})";
        break;
      case DeviceUpdateStatus.upToDate:
        title = "Up to Date";
        subtitle =
            "Your device is running the latest firmware (${state.currentVersion}).";
        break;
      case DeviceUpdateStatus.enteringBootloader:
        title = "Preparing Device...";
        subtitle = "Rebooting device into update mode. Do not turn off.";
        break;
      case DeviceUpdateStatus.flashing:
        title = "Updating Firmware";
        subtitle = "Please keep your phone near the device.";
        break;
      case DeviceUpdateStatus.success:
        title = "Update Complete!";
        subtitle = "Your device is restarting with the new firmware.";
        break;
      case DeviceUpdateStatus.error:
        title = "Update Failed";
        subtitle = state.errorMessage ?? "An unknown error occurred.";
        break;
      case DeviceUpdateStatus.initial:
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionArea(BuildContext context, DeviceUpdateState state) {
    final cubit = context.read<DeviceUpdateCubit>();

    if (state.status == DeviceUpdateStatus.initial ||
        state.status == DeviceUpdateStatus.error ||
        state.status == DeviceUpdateStatus.upToDate) {
      return ElevatedButton(
        onPressed: () => cubit.checkForUpdate(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text("Check for Updates", style: TextStyle(fontSize: 18)),
      );
    }

    if (state.status == DeviceUpdateStatus.updateAvailable) {
      return ElevatedButton(
        onPressed: () => cubit.startUpdateSequence(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text("Install Update Now", style: TextStyle(fontSize: 18)),
      );
    }

    if (state.status == DeviceUpdateStatus.flashing) {
      // 🚨 THE MAGIC OTA PROGRESS BAR
      return Column(
        children: [
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 16),
          Text(
            "${(state.progress * 100).toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (state.status == DeviceUpdateStatus.checkingVersion ||
        state.status == DeviceUpdateStatus.enteringBootloader) {
      return const CircularProgressIndicator();
    }

    if (state.status == DeviceUpdateStatus.success) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Done"),
      );
    }

    return const SizedBox.shrink();
  }
}
