import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({super.key});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  bool _isLoading = false;
  String _cardNumber = '';

  // Detect card brand by prefix
  Widget _getCardIcon(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
        width: 40,
        height: 24,
        fit: BoxFit.contain,
      );
    } else if (cardNumber.startsWith('5')) {
      return Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png',
        width: 40,
        height: 24,
        fit: BoxFit.contain,
      );
    }
    return const Icon(Icons.credit_card, size: 24, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close icon and TEST MODE label right aligned
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.close, color: Colors.black, size: 16),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'TEST MODE',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Add your payment information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Card information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card Number with US label and card brand icon
                  Row(
                    children: [
                      // Expanded card number input with card icon suffix
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Card Number',

                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _getCardIcon(_cardNumber),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _cardNumber = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // MM/YY, CVC, ZIP Code all in one row
                  Row(
                    children: [
                      // MM/YY
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'MM/YY',

                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // CVC
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'CVC',

                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ZIP Code
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'ZIP Code',

                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  // Name on Card
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        await Future.delayed(const Duration(seconds: 3));

                        setState(() {
                          _isLoading = false;
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Successfully Sent!'),
                            ),
                          );
                        }
                      },
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: SpinKitFadingCircle(
                          color: Colors.blue,
                          size: 20.0,
                        ),
                      )
                      : const Icon(Icons.payment),
              label: Text(_isLoading ? 'Processing...' : 'Pay Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
