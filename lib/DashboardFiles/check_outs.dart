// /// Copyright 2021 Google LLC
// ///
// /// Licensed under the Apache License, Version 2.0 (the "License");
// /// you may not use this file except in compliance with the License.
// /// You may obtain a copy of the License at
// ///
// ///     https://www.apache.org/licenses/LICENSE-2.0
// ///
// /// Unless required by applicable law or agreed to in writing, software
// /// distributed under the License is distributed on an "AS IS" BASIS,
// /// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// /// See the License for the specific language governing permissions and
// /// limitations under the License.
//
// import 'package:flutter/material.dart';
// import 'package:pay/pay.dart';
//
// const _paymentItems = [
//   PaymentItem(
//     label: 'MNY',
//     amount: '1.0',
//     status: PaymentItemStatus.final_price,
//   )
// ];
//
// class PaySampleApp extends StatefulWidget {
//   PaySampleApp({Key? key}) : super(key: key);
//
//   @override
//   _PaySampleAppState createState() => _PaySampleAppState();
// }
//
// class _PaySampleAppState extends State<PaySampleApp> {
//   void onGooglePayResult(paymentResult) {
//     debugPrint(paymentResult.toString());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text('Pay'),
//       ),
//       backgroundColor: Colors.white,
//       body: Container(
//         child: Center(
//           child: GooglePayButton(
//             paymentConfigurationAsset: 'gpay.json',
//             paymentItems: _paymentItems,
//             style: GooglePayButtonStyle.black,
//             type: GooglePayButtonType.checkout,
//             margin: const EdgeInsets.only(top: 15.0),
//             onPaymentResult: onGooglePayResult,
//             loadingIndicator: const Center(
//               child: CircularProgressIndicator(
//                 backgroundColor: Colors.blue,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
