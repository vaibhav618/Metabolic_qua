import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../features/chat_manger/data/bloc/chat_bloc.dart';
import '../../../features/chat_manger/data/repository/chat_repository.dart';
import '../../../features/chat_manger/presentation/screen/chat_screen.dart';

class ConsultantInfoCard extends StatefulWidget {
  final DietitianDetailModel dietitianModel;
  final ClientProfileModel clientProfileModel;
  const ConsultantInfoCard({super.key, required this.dietitianModel, required this.clientProfileModel});

  @override
  State<ConsultantInfoCard> createState() => _ConsultantInfoCardState();
}

class _ConsultantInfoCardState extends State<ConsultantInfoCard> with TickerProviderStateMixin {
  bool isExpanded = true;




  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your consultant",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 12,),
          Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory, // disables ripple
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTile(
              // Let "More Info" button control expansion
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpanded = expanded;
                });
              },

              tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              collapsedShape: const RoundedRectangleBorder(),
              shape: const RoundedRectangleBorder(),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 31),

              title: Row(
                children: [

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: Image.network(
                        widget.dietitianModel.logoUrl,
                        width: 80, height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/icons/default2.png',
                          width: 80, height: 80, fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dietitianModel.name,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.80,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const ShapeDecoration(
                              color: Color(0xFFD9D9D9),
                              shape: OvalBorder(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.dietitianModel.email,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.24,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Visibility(
                        visible: false,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                isExpanded ? "Less Info" : "More Info",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF308BF9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                                color: const Color(0xFF308BF9),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              children: [
                isExpanded ? Column(
                  children: [
                    consultantDetailsRow(
                      title: 'Company Name',
                      titleValue: widget.dietitianModel.name,
                      iconSrc: 'assets/images/icons/ic_location.svg',
                    ),
                    const SizedBox(height: 27),
                    consultantDetailsRow(
                      title: 'Telephone',
                      titleValue: widget.dietitianModel.phoneNo,
                      iconSrc: 'assets/images/icons/ic_call.svg',
                    ),
                    const SizedBox(height: 27),
                    consultantDetailsRow(
                      title: 'Email address',
                      titleValue: widget.dietitianModel.email,
                      iconSrc: 'assets/images/icons/ic_email.svg',
                    ),
                  ],
                ):SizedBox.shrink()
              ],
            ),
          ),
          SizedBox(height: 42,),
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => ChatBloc(
                        repository: ChatRepository(
                          sender: ChatUser(
                            id: widget.clientProfileModel.profileId,
                            firstName: widget.clientProfileModel.profileName,
                          ),
                          receiver: ChatUser(
                            id: widget.dietitianModel.dietitianId,
                            firstName: widget.dietitianModel.name,
                          ),
                        ),
                      ),
                      child: ChatScreen(
                        dietitianModel: widget.dietitianModel,
                        clientProfileModel: widget.clientProfileModel,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),   // removes inner padding
                minimumSize: Size(0, 0),    // removes minimum size
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // removes extra height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Send message",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -0.30,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined,size: 24, color: Colors.white,)
                ],
              )
          )
        ],
      ),
    );
  }

  Widget consultantDetailsRow({
    required String title,
    required String titleValue,
    required String iconSrc,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.24,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              titleValue,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.2,
                letterSpacing: -0.30,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFF308BF9),
              ),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: SvgPicture.asset(iconSrc),
        )
      ],
    );
  }
}
