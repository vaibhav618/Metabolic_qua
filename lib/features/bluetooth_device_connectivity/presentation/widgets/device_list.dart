import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';

class DeviceList extends StatelessWidget {
  final BluetoothConnectionState state;

  const DeviceList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final respyrDevices = state.devices.where((d) {
      final name = d.name.trim().toLowerCase();
      return name.contains("respyr");
    }).toList();

    if (respyrDevices.isEmpty && !state.isConnecting) {
      return Container(
        height: 111,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nearby devices will only be visible if you keep it on while connecting',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(10),
        thickness: 6,
        child: ListView.separated(
          itemCount: respyrDevices.length,
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final d = respyrDevices[i];

            final bool isThisConnecting =
                state.isConnecting && state.connectingDeviceId == d.id;

            final bool isThisConnected =
                state.isConnected && state.connectingDeviceId == d.id;

            final bool disableTap = state.isConnecting || state.isConnected;

            return InkWell(
              onTap: disableTap
                  ? null
                  : () => context
                  .read<BluetoothConnectionCubit>()
                  .connectById(d.id),
              child: Opacity(
                opacity:
                disableTap && !isThisConnecting && !isThisConnected ? 0.55 : 1.0,
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.bluetooth, color: Color(0xFF308BF9)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name.isEmpty ? '(no name)' : formatRespyrDeviceName(d.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isThisConnecting)
                            Text(
                              'Connecting...',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF535359),
                              ),
                            )
                          else if (isThisConnected)
                            Text(
                              'Connected',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF3FAF58),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isThisConnecting)
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (isThisConnected)
                      const Icon(Icons.check_circle,
                          size: 18, color: Color(0xFF3FAF58)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String formatRespyrDeviceName(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) {
      return "RESPYR METABOLISM - BT";
    }

    final match = RegExp(r'\d+').firstMatch(rawName);
    final id = match != null ? match.group(0)! : "";

    if (id.isEmpty) {
      return "RESPYR METABOLISM - BT";
    }

    return "RESPYR METABOLISM ($id) - BT";
  }
}
