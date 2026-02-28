import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/screens/app_webview_screen.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  void _openInWebView(BuildContext context,
      {required String url, required String title}) {
    if (url.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppWebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = <_RefSection>[
      _RefSection(
        title: "Breath Acetone (Fat-Use & Energy Balance)",
        description:
        "Studies supporting breath acetone as a non-invasive marker linked to fat oxidation and energy balance.",
        items: [
          _RefItem(
            index: 1,
            title:
            "Measuring breath acetone for monitoring fat loss: Review",
            journal: "Obesity (Silver Spring)",
            year: "2015",
            type: "DOI",
            link: "https://doi.org/10.1002/oby.21242",
          ),
          _RefItem(
            index: 2,
            title: "Breath acetone analyzer",
            journal: "Clinical Chemistry",
            year: "1993",
            type: "PubMed",
            link: "https://pubmed.ncbi.nlm.nih.gov/8419065/",
          ),
          _RefItem(
            index: 3,
            title: "Breath acetone concentrations in fasting volunteers",
            journal: "Clinical Chemistry",
            year: "1988",
            type: "PubMed",
            link: "https://pubmed.ncbi.nlm.nih.gov/3379925/",
          ),
          _RefItem(
            index: 4,
            title: "Breath acetone as a marker of energy balance",
            journal: "Nutrition & Diabetes",
            year: "2018",
            type: "PMC",
            link: "https://pmc.ncbi.nlm.nih.gov/articles/PMC6131485/",
          ),
        ],
      ),
      _RefSection(
        title: "Breath Hydrogen (Gut Fermentation)",
        description:
        "Evidence showing breath hydrogen originates from intestinal microbial fermentation and is used in clinical breath testing.",
        items: [
          _RefItem(
            index: 5,
            title: "Production and excretion of hydrogen gas in man",
            journal: "New England Journal of Medicine",
            year: "1969",
            type: "DOI",
            link: "https://doi.org/10.1056/NEJM196907172810303",
          ),
          _RefItem(
            index: 6,
            title: "Hydrogen and methane-based breath testing consensus",
            journal: "American Journal of Gastroenterology",
            year: "2017",
            type: "DOI",
            link: "https://doi.org/10.1038/ajg.2017.46",
          ),
        ],
      ),
      _RefSection(
        title: "Breath Ethanol (Endogenous & Microbiome)",
        description:
        "Research demonstrating endogenous ethanol presence and microbiome-derived ethanol links.",
        items: [
          _RefItem(
            index: 7,
            title: "Endogenous breath ethanol",
            journal: "Alcohol and Alcoholism",
            year: "1988",
            type: "PubMed",
            link: "https://pubmed.ncbi.nlm.nih.gov/3415770/",
          ),
          _RefItem(
            index: 8,
            title: "Detection of endogenous ethanol",
            journal: "Alcohol and Alcoholism",
            year: "1987",
            type: "PubMed",
            link: "https://pubmed.ncbi.nlm.nih.gov/3619015/",
          ),
          _RefItem(
            index: 9,
            title: "Microbiome-derived ethanol",
            journal: "Nature Medicine",
            year: "2022",
            type: "DOI",
            link: "https://doi.org/10.1038/s41591-021-01611-w",
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF252525)),
        title: Text(
          "Scientific References",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          _HeaderBlock(),
          const SizedBox(height: 16),
          ...sections.map((section) => _SectionBlock(
            section: section,
            onTap: (item) => _openInWebView(
              context,
              url: item.link,
              title: "Reference [${item.index}]",
            ),
          )),
        ],
      ),
    );
  }
}

/* ---------------- UI Blocks ---------------- */

class _HeaderBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EFFD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Source Library",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap any reference to open the publication. These sources support non-invasive breath-based metabolic insights.",
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5A5A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final _RefSection section;
  final void Function(_RefItem item) onTap;

  const _SectionBlock({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.description,
            style: GoogleFonts.poppins(
              fontSize: 12.2,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 12),
          ...section.items.map((item) => _ReferenceCard(
            item: item,
            onTap: () => onTap(item),
          )),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final _RefItem item;
  final VoidCallback onTap;

  const _ReferenceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // index pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF308BF9).withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF308BF9).withOpacity(0.25),
                ),
              ),
              child: Text(
                "[${item.index}]",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF308BF9),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF252525),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${item.journal} • ${item.year}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Badge(text: item.type),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: Color(0xFF308BF9),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF252525),
        ),
      ),
    );
  }
}

/* ---------------- Models ---------------- */

class _RefSection {
  final String title;
  final String description;
  final List<_RefItem> items;

  _RefSection({
    required this.title,
    required this.description,
    required this.items,
  });
}

class _RefItem {
  final int index;
  final String title;
  final String journal;
  final String year;
  final String type; // DOI / PubMed / PMC
  final String link;

  _RefItem({
    required this.index,
    required this.title,
    required this.journal,
    required this.year,
    required this.type,
    required this.link,
  });
}
