// lib/features/metabolism_test/presentation/widgets/test_data_list.dart
import 'package:flutter/material.dart';
import '../../data/models/test_data_record.dart';
import 'package:intl/intl.dart';

class TestDataList extends StatelessWidget {
  final List<TestDataRecord> records;
  const TestDataList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm:ss');
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = records[i];
        return Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Row 1: time + id
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time: ${timeFmt.format(r.dateTime)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('#${r.testId}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                // Scores grid
                _metricGrid(r),
                const Divider(height: 20),
                // Gas readings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kv('Acetone (ppm)', r.acetonePpm),
                    _kv('H₂ (ppm)', r.h2Ppm),
                    _kv('Ethanol (ppm)', r.ethanolPpm),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metricGrid(TestDataRecord r) {
    final items = [
      _kv('Absorptive', r.absorptiveScore),
      _kv('Fermentative', r.fermentativeScore),
      _kv('Fat', r.fatScore),
      _kv('Glucose', r.glucoseScore),
      _kv('Hepatic Stress', r.hepaticStressScore),
      _kv('Detox', r.detoxScore),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 480;
        return GridView.count(
          crossAxisCount:  1 ,
          shrinkWrap: true,
          childAspectRatio: 3.4,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: items,
        );
      },
    );
  }

  Widget _kv(String k, double? v) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 6),
          Text(v?.toStringAsFixed(2) ?? '—',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
