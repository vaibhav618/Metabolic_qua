import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [


            Positioned(
              bottom: -314,
              child: Hero(
                tag: "test1",
                child: Material(
                  type: MaterialType.transparency, // 🔥 IMPORTANT
                  child: InnerShadow(
                    shadows: [
                      Shadow(
                          color: Color(0xFFFFD0CA),
                          blurRadius: 58.1,

                          offset: Offset(12, 36))
                    ],
                    child: Container(
                      width: 628,
                      height: 628,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFDA5747),
                        shape: OvalBorder(),
                      ),



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

class Test2 extends StatelessWidget {
  const Test2({super.key});



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -450/2,
            right: -450/2,
            child: Hero(
              tag: "test1",
              child: Material(
                type: MaterialType.transparency, // 🔥 IMPORTANT
                child: InnerShadow(
                  shadows: [
                    Shadow(
                        color: Color(0xFFFFD0CA),
                        blurRadius: 58.1,

                        offset: Offset(12, -36))
                  ],

                  child: Container(
                    width: 450,
                    height: 450,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFDA5747),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
