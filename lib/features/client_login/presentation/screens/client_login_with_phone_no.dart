import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_routes.dart';



class ClientLoginWithPhoneNo extends StatefulWidget {
  const ClientLoginWithPhoneNo({super.key});

  @override
  State<ClientLoginWithPhoneNo> createState() => _ClientLoginWithPhoneNoState();
}

class _ClientLoginWithPhoneNoState extends State<ClientLoginWithPhoneNo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: (){
                  context.go(AppRoutes.selectCountryCode);
                },
                child: Text("Select country code")
            )
          ],
        ),
      ),
    );
  }
}


class SelectCountryCode extends StatefulWidget {
  const SelectCountryCode({super.key});

  @override
  State<SelectCountryCode> createState() => _SelectCountryCodeState();
}

class _SelectCountryCodeState extends State<SelectCountryCode> {
  @override
  Widget build(BuildContext context) => new Scaffold(
    body: Center(
      child: CountryCodePicker(
        onChanged: print,
        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
        initialSelection: 'IT',
        favorite: ['+39','FR'],
        // optional. Shows only country name and flag
        showCountryOnly: false,
        // optional. Shows only country name and flag when popup is closed.
        showOnlyCountryWhenClosed: false,
        // optional. aligns the flag and the Text left
        alignLeft: false,
      ),
    ),
  );
}
