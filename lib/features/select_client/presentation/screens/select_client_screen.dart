import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/select_client/presentation/widgets/profile_item.dart';

class SelectClientScreen extends StatefulWidget {
  const SelectClientScreen({super.key});

  @override
  State<SelectClientScreen> createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Select Client",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            letterSpacing: rh(context: context, px: -0.30),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 20),
            vertical: rh(context: context, px: 10),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: rh(context: context, px: 13),
                  vertical: rh(context: context, px: 14),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(rh(context: context, px: 15)),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/icons/ic_search.svg",
                      width: rh(context: context, px: 18),
                      height: rh(context: context, px: 18),
                    ),
                    SizedBox(width: rh(context: context, px: 10)),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                          "Name, Mobile number, Email address",
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFFA1A1A1),
                            fontSize: rh(context: context, px: 12),
                            fontWeight: FontWeight.w400,
                            letterSpacing:
                            rh(context: context, px: -0.24),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: rh(context: context, px: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius:
                      BorderRadius.circular(rh(context: context, px: 10)),
                      border: Border.all(
                        color: const Color(0xFFD9D9D9),
                        width: rh(context: context, px: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: rh(context: context, px: 10)),
                        Text(
                          "Sort By",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 12),
                            fontWeight: FontWeight.w400,
                            height: rh(context: context, px: 1.10),
                            letterSpacing:
                            rh(context: context, px: -0.24),
                          ),
                        ),
                        SizedBox(width: rh(context: context, px: 10)),
                        Container(
                          width: rh(context: context, px: 1),
                          color: const Color(0xFFD9D9D9),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(
                                width: rh(context: context, px: 1),
                                color: const Color(0xFFD9D9D9),
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(rh(context: context, px: 10)),
                              bottomRight: Radius.circular(rh(context: context, px: 10)),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: rh(context: context, px: 13),
                                horizontal: rh(context: context, px: 10),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Recently Added",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: rh(context: context, px: 12),
                                    fontWeight: FontWeight.w400,
                                    height: rh(context: context, px: 1.10),
                                    letterSpacing: rh(context: context, px: -0.24),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: const Color(0xFF535359),
                                  size: rh(context: context, px: 20),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: rh(context: context, px: 12)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 20),
                    vertical: rh(context: context, px: 19),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(rh(context: context, px: 15)),
                  ),
                  child: ListView.separated(
                    itemBuilder: (context, index) =>
                    const ProfileItem(),
                    separatorBuilder: (context, index) =>
                        SizedBox(
                          height: rh(context: context, px: 30),
                        ),
                    itemCount: 250,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}