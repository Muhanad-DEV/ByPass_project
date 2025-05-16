import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/order_card.dart';
import '../widgets/app_drawer.dart';
import '../models/user_model.dart';
import 'order_list_page.dart';
import 'profile_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for search fields
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Online/offline status
  bool _isOnline = true;

  // Sample orders
  final List<Map<String, dynamic>> _availableOrders = [
    {
      'id': 'ORD-1234',
      'pickup': 'Al Mouj',
      'dropoff': 'City Centre Muscat',
      'customer': 'Sara Ahmed',
      'amount': '18.50',
      'distance': '12.5 km',
      'time': '15 mins away',
      'status': 'Pending',
    },
    {
      'id': 'ORD-1235',
      'pickup': 'Qurum',
      'dropoff': 'Muttrah Corniche',
      'customer': 'Khalid Mohammed',
      'amount': '22.00',
      'distance': '15.2 km',
      'time': '20 mins away',
      'status': 'Pending',
    },
    {
      'id': 'ORD-1236',
      'pickup': 'Sultan Qaboos University',
      'dropoff': 'Muscat International Airport',
      'customer': 'Ahmed Al-Balushi',
      'amount': '25.75',
      'distance': '18.3 km',
      'time': '25 mins away',
      'status': 'Pending',
    },
  ];

  // Sample vehicles for the driver
  final List<Map<String, dynamic>> _vehicles = [
    {
      'plateNumber': 'A 12345',
      'type': VehicleType.Sedan,
      'capacity': 4,
      'isActive': true,
    },
    {
      'plateNumber': 'B 54321',
      'type': VehicleType.SUV,
      'capacity': 6,
      'isActive': false,
    },
    {
      'plateNumber': 'C 98765',
      'type': VehicleType.Van,
      'capacity': 8,
      'isActive': false,
    },
    {
      'plateNumber': 'D 24680',
      'type': VehicleType.Motorcycle,
      'capacity': 1,
      'isActive': false,
    },
  ];

  // Selected vehicle
  Map<String, dynamic>? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    // Set the default selected vehicle
    _selectedVehicle = _vehicles.firstWhere((v) => v['isActive'], orElse: () => _vehicles.first);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onSearchOrders() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Searching for available orders...')),
    );
    await Future.delayed(const Duration(seconds: 1));
  }

  void _acceptOrder(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text('Accept order ${_availableOrders[index]['id']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14ABC3)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _availableOrders.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order accepted successfully')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildVehicleDetail('Plate Number', vehicle['plateNumber']),
              const SizedBox(height: 16),
              _buildVehicleDetail('Type', _getVehicleTypeString(vehicle['type'])),
              const SizedBox(height: 16),
              _buildVehicleDetail('Capacity', '${vehicle['capacity']} persons'),
              const SizedBox(height: 24),
              CustomButton(
                text: vehicle == _selectedVehicle ? 'CURRENTLY ACTIVE' : 'SET AS ACTIVE',
                onPressed: vehicle == _selectedVehicle 
                  ? null 
                  : () {
                    setState(() {
                      // Set all vehicles to inactive
                      for (var v in _vehicles) {
                        v['isActive'] = false;
                      }
                      // Set the selected vehicle to active
                      vehicle['isActive'] = true;
                      _selectedVehicle = vehicle;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${vehicle['plateNumber']} is now your active vehicle'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNavigationHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Navigation Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('• Use the Menu button to open the side drawer'),
              SizedBox(height: 8),
              Text('• Navigate using bottom bar tabs'),
              SizedBox(height: 8),
              Text('• "Vehicles" tab shows the GridView implementation'),
              SizedBox(height: 8),
              Text('• Tap on vehicle cards to see details'),
              SizedBox(height: 8),
              Text('• Orders tab shows the ListView implementation'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('GOT IT'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVehicleDetail(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  String _getVehicleTypeString(VehicleType type) {
    switch (type) {
      case VehicleType.Sedan:
        return 'Sedan';
      case VehicleType.SUV:
        return 'SUV';
      case VehicleType.Van:
        return 'Van';
      case VehicleType.Motorcycle:
        return 'Motorcycle';
      default:
        return 'Unknown';
    }
  }

  List<Widget> get _pages => [
        _buildHomeContent(),
        const OrderListPage(),
        _buildVehiclesGrid(),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.darkGrey,
        type: BottomNavigationBarType.fixed, // Required for more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.menu),
              tooltip: 'Open Side Drawer',
            ),
          ),
          Positioned(
            bottom: 80,
            right: 0,
            child: FloatingActionButton.small(
              onPressed: _showNavigationHelp,
              backgroundColor: AppConstants.secondaryColor,
              child: const Icon(Icons.help_outline),
              tooltip: 'Navigation Help',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showNavigationHelp,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Status & Earnings & Search panel
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,2))],
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    _buildStatusBar(),
                    const SizedBox(height: 16),
                    _buildEarningsRow(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        labelText: 'From',
                        hintText: 'Current Location',
                        prefixIcon: const Icon(Icons.location_on, color: AppConstants.primaryColor),
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        labelText: 'To',
                        hintText: 'Destination',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppConstants.primaryColor),
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onSearchOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Search Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Orders list / states
              _isOnline
                  ? (_availableOrders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _availableOrders.length,
                          itemBuilder: (ctx, i) => OrderCard(
                            orderId: _availableOrders[i]['id'],
                            pickupLocation: _availableOrders[i]['pickup'],
                            dropoffLocation: _availableOrders[i]['dropoff'],
                            customerName: _availableOrders[i]['customer'],
                            amount: _availableOrders[i]['amount'],
                            distance: _availableOrders[i]['distance'],
                            time: _availableOrders[i]['time'],
                            status: _availableOrders[i]['status'],
                            onTap: () => _showOrderDetails(_availableOrders[i]),
                            onAccept: () => _acceptOrder(i),
                          ),
                        ))
                  : _buildOfflineState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclesGrid() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles (GridView)'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This screen demonstrates the GridView requirement'),
                  backgroundColor: Colors.black87,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car, 
                    color: AppConstants.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Vehicle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedVehicle?['plateNumber'] ?? 'No vehicle selected',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Usage hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              '👆 Tap on any vehicle card to see details',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final bool isActive = vehicle['isActive'];
                
                return GestureDetector(
                  onTap: () => _showVehicleDetails(vehicle),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppConstants.primaryColor : Colors.grey[300]!,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Icon(
                          _getVehicleIcon(vehicle['type']),
                          size: 48,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            _getVehicleTypeString(vehicle['type']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            vehicle['plateNumber'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            '${vehicle['capacity']} Persons',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add vehicle feature coming soon'),
            ),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.Sedan:
        return Icons.directions_car;
      case VehicleType.SUV:
        return Icons.directions_car;
      case VehicleType.Van:
        return Icons.airport_shuttle;
      case VehicleType.Motorcycle:
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  // Input border constant
  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
  );

  Widget _buildStatusBar() {
    return Row(
      children: [
        Icon(_isOnline ? Icons.circle : Icons.circle_outlined,
             color: _isOnline ? Colors.green : Colors.red, size: 16),
        const SizedBox(width: 8),
        Text(
          _isOnline ? 'You are Online' : 'You are Offline',
          style: TextStyle(color: _isOnline ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Switch(value: _isOnline, onChanged: (v) => setState(() => _isOnline = v), activeColor: Colors.green, activeTrackColor: Colors.green.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildEarningsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildEarningItem('Trips', '5'),
        _buildEarningItem('Hours', '4.5'),
        _buildEarningItem('Distance', '68 km'),
      ],
    );
  }

  Widget _buildEarningItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No orders nearby',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search area or check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.offline_bolt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'You are currently offline',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Go online to start receiving orders.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _isOnline = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('GO ONLINE', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order['id']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      order['status'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Pickup', order['pickup'], Icons.location_on),
              const SizedBox(height: 16),
              _buildDetailRow('Dropoff', order['dropoff'], Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildDetailRow('Customer', order['customer'], Icons.person_outline),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow('Amount', '\$${order['amount']}', Icons.attach_money),
                  ),
                  Expanded(
                    child: _buildDetailRow('Distance', order['distance'], Icons.straighten),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('CLOSE'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _acceptOrder(_availableOrders.indexOf(order));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ACCEPT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
