import 'package:flutter/material.dart';
import '../models/graph_model.dart';
import '../widgets/progress_graph.dart';

class LiveGraphPage extends StatelessWidget {
  const LiveGraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GraphModel> myGraphData = [
      GraphModel(date: DateTime(2023, 8, 5), value: 65),
      GraphModel(date: DateTime(2023, 8, 6), value: 67),
      GraphModel(date: DateTime(2023, 8, 7), value: 90),
      GraphModel(date: DateTime(2023, 8, 8), value: 88),
      GraphModel(date: DateTime(2023, 8, 9), value: 77),
      GraphModel(date: DateTime(2023, 8, 10), value: 95),
    ];
    return Scaffold(
      body: Center(child: ProgressGraph(data: myGraphData)),
    );
  }
}
