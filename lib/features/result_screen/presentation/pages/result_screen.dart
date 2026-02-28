import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/result_screen/data/repository/result_repository.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/cubit/result_cubit.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/cubit/result_state.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/widgets/result_content.dart';

class ResultScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const ResultScreen({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ResultCubit(ResultRepository());
        cubit.fetchResultData();
        return cubit;
      },
      child: const ResultScreenView(),
    );
  }
}

class ResultScreenView extends StatelessWidget {
  const ResultScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Shubham Deshmukh',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.36,
              ),
            ),
            Text(
              '25 June 2025, 12:00pm',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: CloseButton(color: Colors.black)),
        ],
        elevation: 2,
        shadowColor: Colors.black,
        backgroundColor: Color(0xFFF5F7FA),
        surfaceTintColor: Color(0xFFF5F7FA),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<ResultCubit, ResultState>(
        builder: (context, state) {
          if (state is ResultLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (state is ResultLoaded) {
            return ResultContent(result: state.result);
          } else if (state is ResultError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
