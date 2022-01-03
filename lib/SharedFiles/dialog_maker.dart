import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GradiantBtn extends StatelessWidget {
  var txt, dO, width, height, txtClr;
  var clr;

  GradiantBtn({
    @required this.txt,
    @required this.width,
    @required this.height,
    @required this.dO,
    @required this.clr,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      // ignore: deprecated_member_use
      child: RaisedButton(
        onPressed: dO,
        padding: const EdgeInsets.all(0.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color.fromARGB(255, 0, 113, 219),
                  Color.fromARGB(255, 0, 100, 209),
                  Color.fromARGB(255, 0, 113, 219),
                  Color.fromARGB(255, 0, 100, 209),
                  Color.fromARGB(255, 0, 113, 219)
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              )),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            txt,
            style: TextStyle(
              color: clr,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


cDialog(BuildContext context, Icon iC, String headerTxt, String content,
    double containerH, Color hClr, Color dClr, [dOO]) {

  AlertDialog alert = AlertDialog(
    backgroundColor: Color.fromRGBO(208, 216, 239, 1),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
    content: Container(
      height: containerH,
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                iC,
                Text(
                  headerTxt,
                  style: TextStyle(fontWeight: FontWeight.bold, color: hClr),
                )
              ],
            ),
            Divider(
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              content,
              style: TextStyle(fontWeight: FontWeight.w300, color: dClr),
            ),
            SizedBox(
              height: 5,
            ),
            dOO,
          ],
        ),
      ),
    ),
  );

  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(seconds: 1),
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget child) =>
          SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(a1),
              child: alert),
      pageBuilder: (context, anim1, anim2) {
        return Transform.rotate(
          angle: anim1.value,
        );
      });
}