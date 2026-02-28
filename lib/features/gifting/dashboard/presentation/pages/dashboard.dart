import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../test_history/test_history_by_date/data/models/test_data_record.dart';
import '../widgets/appbar.dart';
import '../widgets/test_result_history.dart';

class GiftingDashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const GiftingDashboard({super.key, required this.clientProfileModel});

  @override
  State<GiftingDashboard> createState() => _DashboardState();
}

class _DashboardState extends State<GiftingDashboard> {
  @override
  Widget build(BuildContext context) {

    final TestDataRecord dummyRecord = TestDataRecord(
      testId: 101,
      profileId: 'profile001',
      dateTime: DateTime.parse('2025-08-13 17:38:34'),
      absorptiveScore: 78.0,
      fermentativeScore: 62.0,
      fatScore: 55.0,
      glucoseScore: 81.0,
      hepaticStressScore: 40.0,
      detoxScore: 70.0,
      acetonePpm: 1.8,
      h2Ppm: 12.4,
      ethanolPpm: 0.30,
    );



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading:false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          // IconButton(onPressed: (){
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => NotificationScreen(clientProfileModel: widget.clientProfileModel,
          //       ),
          //     ),
          //   );
          // }, icon: Icon(CupertinoIcons.bell)),
          SizedBox(width: 10,),
          InkWell(
            onTap: (){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => Settings(clientProfileModel: widget.clientProfileModel, dietitianDetailModel: widget.d,
              //     ),
              //   ),
              // );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDEDED),
              // Only set image if it's a valid URL
              foregroundImage: (widget.clientProfileModel.profileImage.isNotEmpty && widget.clientProfileModel.profileImage != 'NA') ? NetworkImage(widget.clientProfileModel.profileImage) : null,
              onForegroundImageError: (_, __) {
                // optional: log or handle error
              },
              // Fallback shown if image is null or fails to load
              child: const Icon(Icons.person, color: Color(0xFF9E9E9E), size: 24),
            ),
          ),
          SizedBox(width: 20,),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            DashboardAppbar(),
            SizedBox(height: 20,),
          //  TestResultHistory(testDataRecord: dummyRecord, clientProfileModel: widget.clientProfileModel,),

          ],
        ),
      ),
      bottomNavigationBar:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

        ],
      ),
    );
  }
}
