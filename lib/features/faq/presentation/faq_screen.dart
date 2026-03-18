import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/faq/presentation/report_issue_screen.dart';
import 'package:respyr_dietitian/features/support/presentation/screens/support.dart';
import '../../../../../core/size/get_height.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚨 ADDED: Responsive scale factor
    final s = rh(context: context, px: 1);

    // Mock data for the FAQs
    final List<Map<String, String>> faqs = [
      {
        "question": "1. Device not connecting issue?",
        "answer":
            "Ensure your device is fully charged and Bluetooth is turned on. Try restarting the device or resetting the connection from the dashboard."
      },
      {
        "question": "2. How to add new profile?",
        "answer":
            "Navigate to the client dashboard, click on the profile selector at the top, and select 'Add New Profile' from the dropdown menu."
      },
      {
        "question": "3. how switch from one profile to another?",
        "answer":
            "Tap on the current profile name at the top of the dashboard. A list will appear allowing you to select and switch to another active profile."
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFF252525), size: 24 * s),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          "Help Center",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15 * s,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Scrollable FAQ Content
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: 14 * s, vertical: 2 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FAQ",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                  SizedBox(height: 28 * s),
                  Text(
                    "Here are some frequently asked question with solutions",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: -0.30),
                  ),
                  SizedBox(height: 18 * s),

                  // Render the list of FAQ cards
                  ...faqs.map((faq) => _FaqTile(
                        question: faq["question"]!,
                        answer: faq["answer"]!,
                      )),
                ],
              ),
            ),
          ),

          // Fixed Bottom Support Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 24 * s,
              left: 14 * s,
              right: 14 * s,
              bottom: 40 * s,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Didn't find what you're looking for?",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.24),
                ),
                SizedBox(height: 15 * s),

                // Contact Support Button
                SizedBox(
                  width: double.infinity,
                  height: 61 * s,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportScreen(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF252525),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30 * s),
                      ),
                    ),
                    child: Text(
                      "Contact Support",
                      style: GoogleFonts.poppins(
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                SizedBox(height: 15 * s),

                // Report An Issue Button
                SizedBox(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportIssueScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF252525),
                      side: BorderSide(
                          color: const Color(0xFFC7C6CE), width: 1 * s),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25 * s),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(
                        horizontal: 45 * s,
                        vertical: 8 * s,
                      ),
                    ),
                    child: Text(
                      "Report An Issue",
                      style: GoogleFonts.poppins(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM EXPANDABLE FAQ TILE
// ============================================================================

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 🚨 ADDED: Responsive scale factor for the custom tile as well
    final s = rh(context: context, px: 1);

    int dotIndex = widget.question.indexOf('. ');
    String numberPart = "";
    String textPart = widget.question;

    if (dotIndex != -1) {
      numberPart = widget.question.substring(0, dotIndex + 2);
      textPart = widget.question.substring(dotIndex + 2);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5 * s),
      ),
      child: Theme(
        // Remove the default ExpansionTile dividers
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              EdgeInsets.symmetric(horizontal: 20 * s, vertical: 4 * s),
          childrenPadding:
              EdgeInsets.only(left: 20 * s, right: 20 * s, bottom: 20 * s),
          iconColor: const Color(0xFF308BF9),
          collapsedIconColor: const Color(0xFF308BF9),
          trailing: Icon(
            _isExpanded ? Icons.remove : Icons.add,
            size: 24 * s,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (numberPart.isNotEmpty)
                Text(
                  numberPart,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
              Expanded(
                child: Text(
                  textPart,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INVISIBLE SPACER: perfectly aligns the answer with the question text
                if (numberPart.isNotEmpty)
                  Text(
                    numberPart,
                    style: GoogleFonts.poppins(
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.30,
                      color: Colors.transparent, // Completely invisible
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.answer,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF666666),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
