import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// 🚨 Adjust this path to point to your actual get_height.dart file
import '../../../../../core/size/get_height.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  // 🚨 ADDED: List of predefined issues and a list to track user selections
  final List<String> _issueTopics = [
    "Device connection problem",
    "App crashes or freezes",
    "Data not syncing",
    "Profile management issue",
    "Other"
  ];
  final List<String> _selectedTopics = [];

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateSubmitState);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 🚨 UPDATED: Submit is enabled if they typed something OR selected a topic
  void _updateSubmitState() {
    setState(() {
      _isSubmitEnabled = _descriptionController.text.trim().isNotEmpty ||
          _selectedTopics.isNotEmpty;
    });
  }

  // 🚨 ADDED: Bottom sheet function for multi-select topics
  void _openTopicSelector(double s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20 * s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      child: Text(
                        "Select Topics",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),
                    ..._issueTopics.map((topic) {
                      return CheckboxListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20 * s),
                        title: Text(
                          topic,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        value: _selectedTopics.contains(topic),
                        activeColor: const Color(0xFF252525),
                        onChanged: (bool? value) {
                          setModalState(() {
                            if (value == true) {
                              _selectedTopics.add(topic);
                            } else {
                              _selectedTopics.remove(topic);
                            }
                          });
                          _updateSubmitState(); // Update main screen state
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = rh(context: context, px: 1); // Responsive scale factor

    // Dynamic text for the select box
    String selectBoxText = _selectedTopics.isEmpty
        ? "Select all that apply"
        : _selectedTopics.join(", ");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFF252525), size: 24 * s),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.pop(context);
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      "Report An Issue",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    SizedBox(height: 16 * s),

                    // Subtitle
                    Text(
                      "Choose one or more topics below that best describe your issue.",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: -0.30,
                      ),
                    ),
                    SizedBox(height: 24 * s),

                    // Topic Selector Box
                    InkWell(
                      onTap: () => _openTopicSelector(s),
                      borderRadius: BorderRadius.circular(10 * s),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * s,
                          vertical: 18 * s,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10 * s),
                          border: Border.all(
                            color: const Color(0xFFC7C6CE),
                            width: 1 * s,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectBoxText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF252525),
                              size: 24 * s,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * s),

                    // Description Text Area
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10 * s),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 8,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Type here to describe...",
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFF888888),
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.all(16 * s),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * s),
                            borderSide: BorderSide(
                              color: const Color(0xFFC7C6CE),
                              width: 1 * s,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * s),
                            borderSide: BorderSide(
                              color: const Color(0xFFC7C6CE),
                              width: 1 * s,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * s),
                            borderSide: BorderSide(
                              color: const Color(0xFF308BF9),
                              width: 1.5 * s,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Submit Button
            Padding(
              padding: EdgeInsets.only(
                left: 16 * s,
                right: 16 * s,
                bottom: 30 * s, // Bottom safe area padding
                top: 10 * s,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54 * s,
                child: ElevatedButton(
                  onPressed: _isSubmitEnabled
                      ? () {
                          // TODO: Handle Submit Logic
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF252525), // Active color
                    disabledBackgroundColor:
                        const Color(0xFFDCDCDC), // Disabled grey
                    foregroundColor: Colors.white, // Active text color
                    disabledForegroundColor:
                        const Color(0xFF888888), // Disabled text grey
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30 * s),
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.poppins(
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3 * s,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
