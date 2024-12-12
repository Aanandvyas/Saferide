import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class razorPayGateway extends StatefulWidget {
  const razorPayGateway({super.key});

  @override
  State<razorPayGateway> createState() => _razorPayGatewayState();
}

class _razorPayGatewayState extends State<razorPayGateway> {
  Razorpay razorpay = Razorpay();
  @override
  Widget build(BuildContext context) {
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Gateway'),
      ),
      body: Center(
        child: OutlinedButton(
            onPressed: () {
              var options = {
                'key': 'rzp_test_c12JmJoNzfrVOP',
                'key Secret':'Eu54gx2Z3MyDAYwEvkKa',
                'amount': 100,
                'name': 'Anand vyas',
                'description': 'Cab Subscription',
                'prefill': {
                  'contact': '8516894756',
                  'email': 'test@razorpay.com'
                }
              };
              razorpay.open(options);
            },
            child: const Text("Pay 150rs")),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    Fluttertoast.showToast(msg: "Payment Success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    Fluttertoast.showToast(msg: "Payment Failed");
  }

  @override
  void dispose() {
    super.dispose();
  try{
    razorpay.clear();
  }catch(e){
    print(e);
  }
  }
}
