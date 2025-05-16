import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../services/firebase_service.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({Key? key}) : super(key: key);

  @override
  _PlaceOrderPageState createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedDeliveryType = 'Standard';
  bool _isScheduled = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasAttachment = false;
  bool _isLoading = false;

  final List<String> _deliveryTypes = ['Standard', 'Express', 'Same Day', 'Scheduled'];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ordersRef = FirebaseServiceLocator.instance.database.ref('orders');
      final newOrderRef = ordersRef.push();

      await newOrderRef.set({
        'orderId': newOrderRef.key,
        'pickup': _pickupController.text,
        'dropoff': _dropoffController.text,
        'deliveryType': _selectedDeliveryType,
        'note': _noteController.text,
        'hasAttachment': _hasAttachment,
        'status': 'Pending',
        'scheduledDate': _isScheduled ? _selectedDate.toIso8601String() : null,
        'scheduledTime': _isScheduled ? '${_selectedTime.hour}:${_selectedTime.minute}' : null,
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted successfully')),
      );

      Navigator.of(context).pop(); // Or navigate to confirmation if you prefer

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputField(
                  label: 'Pickup Location',
                  hint: 'Enter pickup address',
                  prefixIcon: Icons.location_on,
                  controller: _pickupController,
                  validator: (value) => Validators.validateRequired(value, 'Pickup location'),
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Dropoff Location',
                  hint: 'Enter dropoff address',
                  prefixIcon: Icons.location_on_outlined,
                  controller: _dropoffController,
                  validator: (value) => Validators.validateRequired(value, 'Dropoff location'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDeliveryType,
                  decoration: const InputDecoration(labelText: 'Delivery Type'),
                  items: _deliveryTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeliveryType = value!;
                      _isScheduled = value == 'Scheduled';
                    });
                  },
                ),
                if (_isScheduled) ...[
                  const SizedBox(height: 16),
                  TextButton(onPressed: () => _selectDate(context), child: Text('Select Date')),
                  TextButton(onPressed: () => _selectTime(context), child: Text('Select Time')),
                ],
                const SizedBox(height: 16),
                InputField(
                  label: 'Note (Optional)',
                  hint: 'Add any special instructions',
                  prefixIcon: Icons.note_alt_outlined,
                  controller: _noteController,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'PLACE ORDER',
                  onPressed: _submitOrder,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}