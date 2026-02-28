import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../core/url-manager/url_manager.dart';
import 'create_profile_state.dart';
import 'package:flutter/services.dart';

class CreateProfileCubit extends Cubit<CreateProfileState> {
  CreateProfileCubit({this.debug = true}) : super(CreateProfileInitial());

  final bool debug;

  void _log(String msg) {
    if (!debug) return;
    final ts = DateTime.now().toIso8601String();
    for (final line in msg.split('\n')) {
      if (line.trim().isEmpty) continue;
      // ignore: avoid_print
      print('[CreateProfileCubit][$ts] $line');
    }
  }

  String _mask(String v, {int keepEnd = 2}) {
    if (v.isEmpty) return v;
    if (v.length <= keepEnd) return '*' * v.length;
    return ('*' * (v.length - keepEnd)) + v.substring(v.length - keepEnd);
  }

  // helpers
  int _asInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final p = int.tryParse(v.toString());
    return p ?? def;
  }

  String _asString(dynamic v, {String def = ''}) {
    if (v == null) return def;
    return v is String ? v : v.toString();
  }

  // --- updated normalizer ---
  Map<String, dynamic> _normalizeForClientProfile(Map<String, dynamic> data) {
    return {
      ...data,

      'id': _asInt(data['id'], def: 0),

      'dietician_id': _asString(data['dietician_id'] ?? data['dietitian_id']),
      'age': _asString(data['age']),
      'height': _asString(data['height']),
      'weight': _asString(data['weight']),

      'profile_image': _asString(data['profile_image'] ?? data['image_url'] ?? ''),

      'plans_count': _asInt(data['plans_count'], def: 0),
      'tests_count': _asInt(data['tests_count'], def: 0),
      'is_active': _asInt(data['is_active'], def: 1),

      'phone_no': _asString(data['phone_no'], def: 'NA'),
      'email': _asString(data['email']),
      'profile_name': _asString(data['profile_name']),
      'profile_id': _asString(data['profile_id']),
      'gender': _asString(data['gender']),
      'region': _asString(data['region']),
      'location': _asString(data['location']),
      'dttm': _asString(data['dttm']),

      'is_notification_enabled': _asInt(data['is_notification_enabled'], def: 1),
      'is_dietitian_linked': _asInt(data['is_dietitian_linked'], def: 1),
    };
  }

  Future<void> createProfile({
    required String dietitianId,
    required String phoneNo,
    required String email,
    required String profileName,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String region,
    required String location,
    required String password,
    required String profileImagePath,
    required bool imageIsAvailable,
  }) async {
    final swTotal = Stopwatch()..start();
    emit(CreateProfileLoading());
    _log('STATE => CreateProfileLoading');

    try {
      File imageFile = await prepareProfileImage(
        profileImagePath,
        imageIsAvailable: imageIsAvailable,
      );

      final uri = Uri.parse(UrlManager().urlCreateClientProfile);
      final request = http.MultipartRequest('POST', uri)
        ..fields['dietitian_id'] = dietitianId
        ..fields['phone_no'] = "NA"
        ..fields['email'] = email
        ..fields['profile_name'] = profileName
        ..fields['age'] = age.toString()
        ..fields['gender'] = gender
        ..fields['height'] = height.toString()
        ..fields['weight'] = weight.toString()
        ..fields['region'] = region
        ..fields['location'] = location
        ..fields['password'] = password
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();

      Map<String, dynamic>? jsonResponse;
      try {
        jsonResponse = jsonDecode(body) as Map<String, dynamic>?;
      } catch (_) {}

      if (streamed.statusCode == 200) {
        final success = jsonResponse?['success'] == true;
        final hasData = jsonResponse?['data'] != null;

        if (success && hasData) {
          final data = Map<String, dynamic>.from(jsonResponse!['data']);
          final mapped = _normalizeForClientProfile(data);

          _log('DATA(mapped→model): ${const JsonEncoder.withIndent('  ').convert(mapped)}');

          final profile = ClientProfileModel.fromJson(mapped);
          emit(CreateProfileSuccess(profile: profile));
          _log('STATE => CreateProfileSuccess');
        } else {
          emit(CreateProfileFailure(jsonResponse?['message'] ?? 'Unknown error'));
        }
      } else {
        final msg = jsonResponse?['message']?.toString() ?? 'Server error';
        emit(CreateProfileFailure('$msg (HTTP ${streamed.statusCode})',
            statusCode: streamed.statusCode));
      }
    } catch (e, st) {
      _log('CATCH: $e\nSTACK:\n$st');
      emit(CreateProfileFailure('Unexpected error: $e'));
    } finally {
      swTotal.stop();
      _log('TOTAL TIME: ${swTotal.elapsedMilliseconds}ms');
    }
  }

  Future<File> prepareProfileImage(
      String? profileImagePath, {
        bool imageIsAvailable = false,
      }) async {
    try {
      File? file;
      if (imageIsAvailable &&
          profileImagePath != null &&
          profileImagePath.isNotEmpty) {
        file = File(profileImagePath);
        if (file.existsSync()) return file;
      }

      final byteData = await rootBundle.load('assets/images/icons/default2.png');
      final imageBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, 'default2.png');
      return await File(filePath).writeAsBytes(imageBytes);
    } catch (e) {
      rethrow;
    }
  }
}
