import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

import '../../../common/dialogs/floating_message.dart';
import '../../../core/utils/date_helper.dart';
import '../../../features/chat_manger/data/bloc/chat_bloc.dart';
import '../../../features/chat_manger/data/repository/chat_repository.dart';
import '../../../features/chat_manger/presentation/screen/chat_screen.dart';
import '../../../features/menu/presentation/pages/settings.dart';
import '../../data/bloc/client_bloc.dart';
import '../../extras/meal_type_helper.dart';

class DashboardAppbar extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel? dietitianDetailModel;
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;
  final bool isDefaultColor;

  const DashboardAppbar({
    super.key,
    required this.clientProfileModel,
    this.dietitianDetailModel,
    this.isDefaultColor = false,
    required this.activeData,
    required this.completedData,
    required this.canceledData,
  });

  @override
  Widget build(BuildContext context) {
    final hasDietitian = dietitianDetailModel != null;

    void showNoDietitianSnack() {
      FloatingMessage.show(context, message: "No Dietitian linked yet");
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi ${clientProfileModel.profileName}",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.30,
                height: 1.2,
              ),
            ),
            Text(
              DateHelper.getGreeting(),
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
                height: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),

        /// Chat button
        IconButton(
          onPressed: () {
            if (!hasDietitian) {
              showNoDietitianSnack();
              return;
            }

            final dietitian = dietitianDetailModel!;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => ChatBloc(
                    repository: ChatRepository(
                      sender: ChatUser(
                        id: clientProfileModel.profileId,
                        firstName: clientProfileModel.profileName,
                      ),
                      receiver: ChatUser(
                        id: dietitian.dietitianId,
                        firstName: dietitian.name,
                      ),
                    ),
                  ),
                  child: ChatScreen(
                    dietitianModel: dietitian,
                    clientProfileModel: clientProfileModel,
                  ),
                ),
              ),
            );
          },
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor:
            isDefaultColor ? Colors.white : ThemeHelper().getThemeDarkColor(),
          ),
          icon: SvgPicture.asset(
            "assets/images/icons/ic_message.svg",
            color: isDefaultColor
                ? const Color(0xFF308BF9)
                : Colors.white,
          ),
        ),

        /// Settings button
        IconButton(
          onPressed: () {

            final clientBloc = context.read<ClientBloc>();
            // final dietitian = dietitianDetailModel!;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: clientBloc, // reuse existing instance
                  child: Settings(
                    clientProfileModel: clientProfileModel,
                    activeData: activeData,
                    completedData: completedData,
                    canceledData: canceledData,
                  ),
                ),
              ),
            );
          },
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor:
            isDefaultColor ? Colors.white : ThemeHelper().getThemeDarkColor(),
          ),
          icon: SvgPicture.asset(
            "assets/images/icons/ic_profile.svg",
            color: isDefaultColor
                ? const Color(0xFF308BF9)
                : Colors.white,
          ),
        ),
      ],
    );
  }
}
