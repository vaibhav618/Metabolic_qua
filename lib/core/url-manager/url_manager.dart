class UrlManager {

  final String companyDomain = "https://humorstech.com/";


  late final String mainPath1 = "${companyDomain}humors_app/app_final/dieticianapp/";
  late final String mainPath2 = "${companyDomain}dietitian/api/app/";

  late final String urlSaveFcmToken;
  late final String urlGetTestLogStatus;
  late final String urlSaveTestLog;
  late final String urlCreateClientProfile;
  late final String urlGetDietitianDetails;
  late final String urlGetCompleteTestHistory;
  late final String urlUserCheckProfile;

  UrlManager() {
    urlSaveFcmToken = "${mainPath1}api/insert_fcm_token.php";
    urlGetTestLogStatus = "${mainPath1}api/get_test_log_status.php";
    urlSaveTestLog = "${mainPath1}api/insert_test_log.php";
    urlCreateClientProfile = "${mainPath1}api/create_client.php";
    urlGetDietitianDetails = "${mainPath1}api/get_dietician.php";
    urlGetCompleteTestHistory = "${mainPath1}api/get_dietician.php";
    urlUserCheckProfile = "${mainPath2}/check_client_profile.php";
  }
}

