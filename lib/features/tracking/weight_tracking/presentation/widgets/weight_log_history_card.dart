import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/tracking/weight_tracking/presentation/widgets/weight_log_item.dart';

import '../../data/model/weight_log_model.dart';

class WeightLogHistoryCard extends StatelessWidget {
  final List<WeightLogModel> logs;

  /// 🔥 Updated: use int instead of String
  final void Function(int logId)? onDelete;

  const WeightLogHistoryCard({
    super.key,
    required this.logs,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    if(logs.isEmpty){
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "History",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            child: logs.isEmpty
                ? Center(
              child: Text(
                "No history available",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFA1A1A1),
                  fontSize: 13,
                ),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final log = logs[index];

                return WeightLogItem(
                  weight: log.weightKg,
                  dateTime: DateTime.tryParse(
                    "${log.logDate} ${log.logTime.isNotEmpty ? log.logTime : "00:00:00"}",
                  ) ??
                      DateTime.now(),
                  weightProgress:
                  log.weightProgress, // off_track / on_track
                  onDeleteWeightLogPressed: () {
                    if (onDelete != null) {
                      // 🔥 Updated: pass int id
                      onDelete!(int.parse(log.id));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
