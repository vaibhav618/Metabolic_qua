// ====================== score_chart.dart ======================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../target/bloc/metabolism_target_bloc.dart';
import '../../target/bloc/metabolism_target_event.dart';
import '../../target/bloc/metabolism_target_state.dart';
import '../../target/data/repository/metabolism_target_repository.dart';
import '../../target/data/services/metabolism_target_service.dart';
import 'linechart.dart';

class ScoreChart extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final double latestScore;
  final double latestScoreMinRange;
  final double latestScoreMaxRange;

  const ScoreChart({
    super.key,
    required this.clientProfileModel,
    this.latestScore = -1,
    this.latestScoreMinRange=-1,
    this.latestScoreMaxRange=-1,
  });

  @override
  State<ScoreChart> createState() => _ScoreChartState();
}

class _ScoreChartState extends State<ScoreChart> {
  late final MetabolismTargetBloc _bloc;
  bool noData = false;




  @override
  void initState() {
    super.initState();


    final service = MetabolismTargetService();
    final repo = MetabolismTargetRepository(service);
    _bloc = MetabolismTargetBloc(repo: repo);
    _bloc.add(
      FetchMetabolismTarget(
        age: int.tryParse(widget.clientProfileModel.age) ?? 0,
        gender: widget.clientProfileModel.gender,
        heightCm: double.tryParse(widget.clientProfileModel.height) ?? 0.0,
        currentWeight: double.tryParse(widget.clientProfileModel.weight) ?? 0.0,
        diabetic: false,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (noData) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Score Chart",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.24,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 20),

          // Status Message Logic
          _buildStatusText(widget.latestScoreMinRange),

          const SizedBox(height: 20),

          // Range Box
          _buildRangeBox(widget.latestScoreMinRange),

          const SizedBox(height: 51),

          // Chart Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: MetabolismChartContainer(
              dietitianId: widget.clientProfileModel.dietitianId,
              profileId: widget.clientProfileModel.profileId,
              minRange: widget.latestScoreMinRange,
              maxRange: widget.latestScoreMaxRange,
              noDataAvailable: (bool noDataAvailable) {
                if (mounted && noData != noDataAvailable) {
                  setState(() {
                    noData = noDataAvailable;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(double  minRange) {
    String text;
    if (widget.latestScore < 0) {
      text = "You have not yet tracked";
    } else if (widget.latestScore >= minRange) {
      text = "Nice. You've maintained score range!";
    } else {
      text = "You've not maintained score range!";
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
      ),
    );
  }

  Widget _buildRangeBox(double minRange) {
    if(widget.latestScore<0){
      return SizedBox.shrink();
    }
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFE0E0E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "RECOMMENDED SCORE RANGE",
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          Text(
            "> ${minRange.toStringAsFixed(0)}% ",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          )
        ],
      ),
    );
  }
}

