import 'package:flutter/material.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import '../../qua_dashboard/presentation/screens/qua_dashboard_screen.dart';


class Dashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const Dashboard({super.key, required this.clientProfileModel});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return QuaDashboardScreen(clientProfileModel: widget.clientProfileModel,);
  }
}
