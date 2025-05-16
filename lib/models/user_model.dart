import 'dart:io';
import 'dart:math';

enum UserType { Client, Driver }
enum VehicleType { Sedan, SUV, Van, Motorcycle }
enum OrderStatus { Pending, Accepted, InProgress, Completed, Cancelled }

class User {
  int _id;
  String _name;
  String _email;
  String _phone;
  UserType _userType;

  User(this._id, this._name, this._email, this._phone, this._userType);

  int get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  UserType get userType => _userType;

  set name(String name) => _name = name;
  set email(String email) => _email = email;
  set phone(String phone) => _phone = phone;

  void display() {
    print(
        "User ID: $_id | Name: $_name | Email: $_email | Phone: $_phone | Type: $_userType");
  }
}

class Vehicle {
  String _plateNumber;
  VehicleType _type;
  int _capacity;
  int _driverId;
  bool _isAvailable;

  Vehicle(this._plateNumber, this._type, this._capacity, this._driverId, {bool isAvailable = true}) 
      : _isAvailable = isAvailable;

  String get plateNumber => _plateNumber;
  VehicleType get type => _type;
  int get capacity => _capacity;
  int get driverId => _driverId;
  bool get isAvailable => _isAvailable;

  set isAvailable(bool value) => _isAvailable = value;

  void display() {
    print("Vehicle: $_plateNumber | Type: $_type | Capacity: $_capacity | Available: $_isAvailable");
  }
}

// Order Class
class Order {
  String _id;
  int _clientId;
  int _driverId;
  String _pickupLocation;
  String _dropoffLocation;
  double _fare;
  OrderStatus _status;
  DateTime _createdAt;

  Order(this._id, this._clientId, this._pickupLocation, this._dropoffLocation, 
      {int? driverId, double fare = 0.0, OrderStatus status = OrderStatus.Pending}) 
      : _driverId = driverId ?? 0,
        _fare = fare,
        _status = status,
        _createdAt = DateTime.now();

  String get id => _id;
  int get clientId => _clientId;
  int get driverId => _driverId;
  String get pickupLocation => _pickupLocation;
  String get dropoffLocation => _dropoffLocation;
  double get fare => _fare;
  OrderStatus get status => _status;
  DateTime get createdAt => _createdAt;

  set driverId(int id) => _driverId = id;
  set fare(double value) => _fare = value;
  set status(OrderStatus newStatus) => _status = newStatus;

  void display() {
    print("Order: $_id | From: $_pickupLocation | To: $_dropoffLocation | Status: $_status | Fare: \$${_fare.toStringAsFixed(2)}");
  }
}

// New file: lib/models/user_model.dart
class UserModel {
  String id; // Added an ID for uniqueness
  String name;
  String email;
  String? phone;
  String? profileImageUrl; // Store image path or URL

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
  });

  // Optional: Add methods like toJson/fromJson if needed for persistence
}
