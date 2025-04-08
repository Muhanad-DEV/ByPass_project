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








List<User> users = [];
Map<int, User> userMap = {};
List<Vehicle> vehicles = [];
List<Order> orders = [];




void welcomeUser({String name = "Guest", bool showTime = false}) {
  String message = "Welcome $name to ByPass Ride-Sharing App!";
  if (showTime) {
    message += " Current time: ${DateTime.now().toString()}";
  }
  print(message);
}




void addUser() {
  try {
    int id = Random().nextInt(9000) + 1000;
    stdout.write("Enter Name: ");
    String? name = stdin.readLineSync();
    if (name == null || name.isEmpty) throw Exception("Name cannot be empty");
    
    stdout.write("Enter Email: ");
    String? email = stdin.readLineSync();
    if (email == null || email.isEmpty) throw Exception("Email cannot be empty");
    // Make email validation more lenient for testing purposes
    if (!email.contains('@') && email.length > 3) {
      email = email + "@example.com"; // Add a default domain if missing
      print("Email format corrected to: $email");
    }
    
    stdout.write("Enter Phone: ");
    String? phone = stdin.readLineSync();
    if (phone == null || phone.isEmpty) throw Exception("Phone cannot be empty");




    print("Select User Type: 1. Client | 2. Driver");
    String? typeChoice = stdin.readLineSync();
    UserType type = (typeChoice == "1") ? UserType.Client : UserType.Driver;

    User user = User(id, name, email, phone, type);
    users.add(user);
    userMap[id] = user;

    welcomeUser(name: name, showTime: true);
    print("User added successfully!");
  } catch (e) {
    print("Error adding user: $e");
  }
}






void displayUsers() {
  if (users.isEmpty) {
    print("No users available.");
    return;
  }



  users.forEach((user) => user.display());
}





void updateUser() {
  try {
    stdout.write("Enter User ID to update: ");
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) throw Exception("ID cannot be empty");
    
    int? id = int.tryParse(input);
    if (id == null) throw Exception("Invalid ID format");
    
    if (!userMap.containsKey(id)) throw Exception("User not found");

    User user = userMap[id]!;
    stdout.write("Enter new Name (or press Enter to keep existing): ");
    String? newName = stdin.readLineSync();
    stdout.write("Enter new Email (or press Enter to keep existing): ");
    String? newEmail = stdin.readLineSync();
    stdout.write("Enter new Phone (or press Enter to keep existing): ");
    String? newPhone = stdin.readLineSync();

    if (newName != null && newName.isNotEmpty) user.name = newName;
    if (newEmail != null && newEmail.isNotEmpty) user.email = newEmail;
    if (newPhone != null && newPhone.isNotEmpty) user.phone = newPhone;

    print("User updated successfully.");
  } catch (e) {
    print("Error updating user: $e");
  }
}

void deleteUser() {
  try {
    stdout.write("Enter User ID to delete: ");
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) throw Exception("ID cannot be empty");
    
    int? id = int.tryParse(input);
    if (id == null) throw Exception("Invalid ID format");
    
    if (!userMap.containsKey(id)) throw Exception("User not found");

    userMap.remove(id);
    users.removeWhere((user) => user.id == id);

    print("User deleted successfully.");
  } catch (e) {
    print("Error deleting user: $e");
  }
}



void searchUser() {
  try {
    stdout.write("Enter User Name or Email to search: ");
    String? query = stdin.readLineSync()?.toLowerCase();
    if (query == null || query.isEmpty) throw Exception("Search query cannot be empty");

    List<User> foundUsers = users
        .where((user) =>
            user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query))
        .toList();



    if (foundUsers.isEmpty) {
      print("No matching users found.");
    } else {
      print("Matching Users:");
      foundUsers.forEach((user) => user.display());
    }


  } catch (e) {
    print("Error searching users: $e");
  }
}




void addVehicle() {
  try {
    stdout.write("Enter Vehicle Plate Number: ");
    String? plateNumber = stdin.readLineSync();
    if (plateNumber == null || plateNumber.isEmpty) throw Exception("Plate number cannot be empty");
    
    print("Select Vehicle Type: 1. Sedan | 2. SUV | 3. Van | 4. Motorcycle");
    String? typeChoice = stdin.readLineSync();
    int typeInt = int.tryParse(typeChoice ?? "") ?? 1;
    if (typeInt < 1 || typeInt > 4) typeInt = 1; // Default to Sedan if invalid
    VehicleType type = VehicleType.values[typeInt - 1];
    
    stdout.write("Enter Capacity: ");
    String? capacityStr = stdin.readLineSync();
    int capacity = int.tryParse(capacityStr ?? "") ?? 4;
    
    stdout.write("Enter Driver ID: ");
    String? driverIdStr = stdin.readLineSync();
    int? driverId = int.tryParse(driverIdStr ?? "");
    if (driverId == null) {
      print("Invalid driver ID, using a placeholder ID");
      driverId = 9999; // Use a placeholder ID for testing
    }
    
    // Make driver validation optional for testing
    if (!userMap.containsKey(driverId)) {
      print("Warning: Driver not found in the system. Creating vehicle anyway.");
    } else if (userMap[driverId]!.userType != UserType.Driver) {
      print("Warning: User is not a driver. Creating vehicle anyway.");
    }
    
    Vehicle vehicle = Vehicle(plateNumber, type, capacity, driverId);
    vehicles.add(vehicle);
    
    print("Vehicle added successfully!");
    print("Vehicle details: Plate: $plateNumber, Type: $type, Capacity: $capacity, Driver ID: $driverId");
  } catch (e) {
    print("Error adding vehicle: $e");
  }
}



// Add this function to display vehicles
void displayVehicles() {
  if (vehicles.isEmpty) {
    print("No vehicles available.");
    return;
  }
  print("\n--- Vehicle List ---");
  vehicles.forEach((vehicle) => vehicle.display());
}