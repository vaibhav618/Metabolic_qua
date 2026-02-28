import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../features/diet_plan/presentation/pages/diet_plan_screen.dart';
import '../../data/model/diet_plan_strategy_model.dart';
import '../../extras/date_helper.dart';
import '../widgets/diet_plan_card.dart';

class DietPlanCard extends StatelessWidget {
  final DietitianDetailModel dietitianDetailModel;
  final ClientProfileModel clientProfileModel;
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;

  const DietPlanCard({
    super.key,
    required this.activeData,
    required this.completedData,
    required this.canceledData,
    required this.dietitianDetailModel, required this.clientProfileModel,
  });

  static const _outerBg = Color(0xFFF0F0F0);
  static const _divider = Color(0xFFD7D6D6);
  static const _textDark = Color(0xFF252525);
  static const _textMid = Color(0xFF535359);
  static const _primary = Color(0xFF308BF9);
  static const _sectionHPad = EdgeInsets.symmetric(horizontal: 10);
  static const _titlePad = EdgeInsets.symmetric(horizontal: 5);

  @override
  Widget build(BuildContext context) {
    if (activeData.isEmpty) {
      return Padding(
        padding: _sectionHPad,
        child: _OuterCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 31),
              _Title(text: 'Diet Plan Strategy'),
              const SizedBox(height: 10),
              _AsPerRow(dietitianDetailModel: dietitianDetailModel),
              const SizedBox(height: 10),
              _SubtleText('Not yet updated'),
              const SizedBox(height: 23),
              PlanCard(activeData: [], completedData: [], canceledData: [], clientProfileModel: clientProfileModel, dietitianDetailModel: dietitianDetailModel,),
              const SizedBox(height: 15),
              _GoalsSection(goals: const []),
              const _Hr(),
              _ApproachSection(approaches: const []),
              const SizedBox(height: 36),
              const _Hr(),
              _ViewButton(onTap: () {

              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    // Active data list
    return Column(
      children: activeData.map((model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: _OuterCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 31),
                const _Title(text: 'Diet Plan Strategy'),
                const SizedBox(height: 10),
                _AsPerRow(dietitianDetailModel: dietitianDetailModel),
                const SizedBox(height: 10),
                _SubtleText('Updated at ${formatToDateTimeString(model.updatedAt)}'),
                const SizedBox(height: 23),
                PlanCard(
                  activeData: activeData,
                  completedData: completedData,
                  canceledData: canceledData, clientProfileModel: clientProfileModel, dietitianDetailModel: dietitianDetailModel,
                ),
                const SizedBox(height: 15),
                _GoalsSection(goals: model.goals.map((g) => g.name).toList()),
                const _Hr(),
                _ApproachSection(approaches: model.approaches),
                const SizedBox(height: 36),
                const _Hr(),
                _ViewButton(onTap: () {


                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DietPlanScreen(
                      dieticianId: dietitianDetailModel.dietitianId,
                      profileId: clientProfileModel.profileId,
                      dietPlanStrategyModel: activeData.first,)),
                  );


                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// === Small, focused widgets below ===

class _OuterCard extends StatelessWidget {
  const _OuterCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: DietPlanCard._outerBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._titlePad,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: DietPlanCard._textDark,
          fontSize: 25,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _AsPerRow extends StatelessWidget {
  const _AsPerRow({required this.dietitianDetailModel});

  final DietitianDetailModel dietitianDetailModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._titlePad,
      child: Row(
        children: [
          Text(
            'As per',
            style: GoogleFonts.poppins(
              color: DietPlanCard._textDark,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(width: 5),
          _DietitianAvatar(url: dietitianDetailModel.logoUrl, radius: 12),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              dietitianDetailModel.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: DietPlanCard._textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleText extends StatelessWidget {
  const _SubtleText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._titlePad,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: DietPlanCard._textMid,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.10,
          letterSpacing: -0.24,
        ),
      ),
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});
  final List<String> goals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._sectionHPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SvgPicture.asset('assets/images/icons/ic_goal.svg'),
            const SizedBox(width: 5),
            Text(
              'Goal',
              style: GoogleFonts.poppins(
                color: DietPlanCard._textDark,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            ),
          ]),
          const SizedBox(height: 13),
          if (goals.isEmpty)
            Text(
              '-',
              style: GoogleFonts.poppins(
                color: DietPlanCard._textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(goals.length * 2 - 1, (i) {
                if (i.isEven) {
                  return Text(
                    goals[i ~/ 2],
                    style: GoogleFonts.poppins(
                      color: DietPlanCard._textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -0.24,
                    ),
                  );
                }
                return Container(width: 1, height: 12, color: DietPlanCard._textMid);
              }),
            ),
        ],
      ),
    );
  }
}

class _ApproachSection extends StatelessWidget {
  const _ApproachSection({required this.approaches});
  final List<String> approaches;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._sectionHPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SvgPicture.asset('assets/images/icons/ic_approach.svg'),
            const SizedBox(width: 5),
            Text(
              'Approach',
              style: GoogleFonts.poppins(
                color: DietPlanCard._textDark,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            ),
          ]),
          const SizedBox(height: 13),
          if (approaches.isEmpty)
            Text(
              '-',
              style: GoogleFonts.poppins(
                color: DietPlanCard._textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.24,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: approaches
                  .map((a) => Container(
                decoration: ShapeDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  a,
                  style: GoogleFonts.poppins(
                    color: DietPlanCard._textMid,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
              ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DietPlanCard._sectionHPad,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          padding: EdgeInsets.zero
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'View diet plan',
              style: GoogleFonts.poppins(
                color: DietPlanCard._primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.30,
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_outlined, color: DietPlanCard._primary),
          ],
        ),
      ),
    );
  }
}

class _Hr extends StatelessWidget {
  const _Hr();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 14.5),
        Divider(color: DietPlanCard._divider, height: 1, thickness: 1),
        SizedBox(height: 10),
      ],
    );
  }
}

class _DietitianAvatar extends StatelessWidget {
  const _DietitianAvatar({required this.url, this.radius = 12});
  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: const AssetImage('assets/images/icons/default2.png'),
      );
    }

    final size = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/icons/default2.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
