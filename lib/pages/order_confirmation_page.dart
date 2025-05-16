import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class OrderConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderConfirmationPage({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 32),
            _buildOrderDetails(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Order Placed Successfully!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Order ID: ${orderData['id']}',
          style: const TextStyle(
            fontSize: 16,
            color: AppConstants.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const Divider(height: 24),
          _buildDetailRow('Pickup Location', orderData['pickup']),
          _buildDetailRow('Dropoff Location', orderData['dropoff']),
          _buildDetailRow('Delivery Type', orderData['type']),
          if (orderData['date'] != null && orderData['time'] != null)
            _buildDetailRow('Scheduled For', '${orderData['date']} at ${orderData['time']}'),
          if (orderData['note'] != null && orderData['note'].isNotEmpty)
            _buildDetailRow('Notes', orderData['note']),
          _buildDetailRow('Has Attachment', orderData['hasAttachment'] ? 'Yes' : 'No'),
          const Divider(height: 24),
          _buildDetailRow('Estimated Fee', '${orderData['estimatedFee']} OMR', isHighlighted: true),
          _buildDetailRow('Estimated Delivery Time', orderData['estimatedTime'], isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: isHighlighted ? AppConstants.primaryColor : AppConstants.darkGrey,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? AppConstants.primaryColor : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'RETURN HOME',
          onPressed: () {
            // Show success dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Order Confirmed'),
                content: const Text('Your order has been confirmed and is being processed. You can track its status in the Orders section.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to home page and clear stack
                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        '/customer_home', 
                        (route) => false
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            // Navigate to place order page
            Navigator.pushNamed(context, '/place_order');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'PLACE ANOTHER ORDER',
            style: TextStyle(color: AppConstants.primaryColor),
          ),
        ),
      ],
    );
  }
}
