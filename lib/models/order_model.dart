import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class OrderModel {
  final String id;
  final String pickupLocation;
  final String dropoffLocation;
  final String customerName;
  final String amount;
  final String distance;
  final String time;
  final String status;
  final String type;
  final String? note;
  final bool hasAttachment;
  final String? date;
  final String? scheduledTime;
  final String estimatedFee;
  final String estimatedTime;

  OrderModel({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.customerName,
    required this.amount,
    required this.distance,
    required this.time,
    required this.status,
    required this.type,
    this.note,
    this.hasAttachment = false,
    this.date,
    this.scheduledTime,
    required this.estimatedFee,
    required this.estimatedTime,
  });
}

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-1234',
      pickupLocation: 'Al Mouj',
      dropoffLocation: 'City Centre Muscat',
      customerName: 'Sara Ahmed',
      amount: '18.50',
      distance: '12.5 km',
      time: '15 mins away',
      status: 'Pending',
      type: 'Standard',
      estimatedFee: '18.50',
      estimatedTime: '30 minutes',
    ),
    OrderModel(
      id: 'ORD-1235',
      pickupLocation: 'Qurum',
      dropoffLocation: 'Muttrah Corniche',
      customerName: 'Khalid Mohammed',
      amount: '22.00',
      distance: '15.2 km',
      time: '20 mins away',
      status: 'In Progress',
      type: 'Express',
      estimatedFee: '22.00',
      estimatedTime: '25 minutes',
    ),
    OrderModel(
      id: 'ORD-1236',
      pickupLocation: 'Sultan Qaboos University',
      dropoffLocation: 'Muscat International Airport',
      customerName: 'Ahmed Al-Balushi',
      amount: '25.75',
      distance: '18.3 km',
      time: 'Delivered',
      status: 'Completed',
      type: 'Same Day',
      estimatedFee: '25.75',
      estimatedTime: '35 minutes',
    ),
  ];

  List<OrderModel> get orders => _orders;

  List<OrderModel> getFilteredOrders(String filter) {
    if (filter == 'All') {
      return _orders;
    } else {
      return _orders.where((order) => order.status == filter).toList();
    }
  }

  void addOrder(OrderModel order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = OrderModel(
        id: order.id,
        pickupLocation: order.pickupLocation,
        dropoffLocation: order.dropoffLocation,
        customerName: order.customerName,
        amount: order.amount,
        distance: order.distance,
        time: order.time,
        status: newStatus,
        type: order.type,
        note: order.note,
        hasAttachment: order.hasAttachment,
        date: order.date,
        scheduledTime: order.scheduledTime,
        estimatedFee: order.estimatedFee,
        estimatedTime: order.estimatedTime,
      );
      notifyListeners();
    }
  }
}
