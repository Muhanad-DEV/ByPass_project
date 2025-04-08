import 'dart:io';
import 'dart:math'; // Add this import for Random class
import 'models/user_model.dart';

void main() {
  welcomeUser(name: "ByPass User", showTime: true);
  
  while (true) {
    print("\n--- ByPass Ride-Sharing Console App ---");
    print("1. Display Users");
    print("2. Add User");
    print("3. Update User");
    print("4. Delete User");
    print("5. Search User");
    print("6. Add Vehicle");
    print("7. Display Vehicles");
    print("8. Add Order");
    print("9. Display Orders");
    print("10. Exit");
    stdout.write("Choose an option: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case "1":
        displayUsers();
        break;
      case "2":
        addUser();
        break;
      case "3":
        updateUser();
        break;
      case "4":
        deleteUser();
        break;
      case "5":
        searchUser();
        break;
      case "6":
        addVehicle();
        break;
      case "7":
        displayVehicles();
        break;
      case "8":
        addOrder();
        break;
      case "9":
        displayOrders();
        break;
      case "10":
        print("Exiting program...");
        return;
      default:
        print("Invalid choice! Try again.");
    }
  }
}








void displayVehicles() {
  if (vehicles.isEmpty) {
    print("No vehicles available.");
    return;
  }
  print("\n--- Vehicle List ---");
  vehicles.forEach((vehicle) => vehicle.display());
}





void addOrder() {
  try {
    if (users.isEmpty) {
      print("No users available. Please add users first.");
      return;
    }
    
    String orderId = "ORD-${Random().nextInt(9000) + 1000}";
    
    // Display available clients
    print("\nAvailable Clients:");
    users.where((user) => user.userType == UserType.Client).forEach((user) => 
      print("ID: ${user.id} | Name: ${user.name}")
    );
    
    stdout.write("Enter Client ID: ");
    String? clientIdStr = stdin.readLineSync();
    int? clientId = int.tryParse(clientIdStr ?? "");
    if (clientId == null) throw Exception("Invalid client ID");
    
    if (!userMap.containsKey(clientId)) {
      throw Exception("Client not found in the system");
    }
    
    if (userMap[clientId]!.userType != UserType.Client) {
      throw Exception("User is not a client");
    }
    



    stdout.write("Enter Pickup Location: ");
    String? pickup = stdin.readLineSync();
    if (pickup == null || pickup.isEmpty) throw Exception("Pickup location cannot be empty");
    
    stdout.write("Enter Dropoff Location: ");
    String? dropoff = stdin.readLineSync();
    if (dropoff == null || dropoff.isEmpty) throw Exception("Dropoff location cannot be empty");
    
    stdout.write("Enter Fare Amount: ");
    String? fareStr = stdin.readLineSync();
    double fare = double.tryParse(fareStr ?? "") ?? 0.0;
    
    Order order = Order(orderId, clientId, pickup, dropoff, fare: fare);
    orders.add(order);
    
    print("Order added successfully!");
  } catch (e) {
    print("Error adding order: $e");
  }
}






void displayOrders() {
  if (orders.isEmpty) {
    print("No orders available.");
    return;
  }
  print("\n--- Order List ---");
  orders.forEach((order) => order.display());
}