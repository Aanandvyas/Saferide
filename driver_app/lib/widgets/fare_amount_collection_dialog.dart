import 'package:driver_app/pages/Splash_Screen.dart';
import 'package:flutter/material.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({super.key, this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() =>
      _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState
    extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.blue,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              "Trip Fare Amount",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                  fontSize: 20),
            ),
            Text(
              "₹ ${widget.totalFareAmount}",
              style: TextStyle(fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
              fontSize: 50),
            ),
            const SizedBox(height: 10,),

            Padding(padding: const EdgeInsets.all(8),
            child: Text(
              "This is the total trip amount . Please collect it from the user",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkTheme ? Colors.amber.shade400 : Colors.white
              ),
            ),
            ),
            const SizedBox(height: 10,),
            Padding(padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: darkTheme ? Colors.amber.shade400 : Colors.white,
              ),
              onPressed: (){
                Future.delayed(const Duration(milliseconds: 2000),(){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>const SplashScreen()));
                });
              }, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Collect Cash",
                  style: TextStyle(
                    fontSize: 20,
                    color: darkTheme ? Colors.black : Colors.blue,
                    fontWeight: FontWeight.bold
                  ),),
                  Text("₹ ${widget.totalFareAmount}",
                  style: TextStyle(
                    fontSize: 20,
                    color: darkTheme ? Colors.black : Colors.blue,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              )),
            ),

          ],
        ),
      ),
    );
  }
}
