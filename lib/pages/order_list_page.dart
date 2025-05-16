import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/order_card.dart';
import '../services/firebase_service.dart';

class OrderListPage extends StatefulWidget {
  final String? filterStatus;
  const OrderListPage({Key? key, this.filterStatus}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late final DatabaseReference _dbRef;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseServiceLocator.instance.database.ref('orders');
    if (widget.filterStatus != null) {
      _selectedFilter = widget.filterStatus!.split(',')[0];
    }
    _loadOrders();
  }

  void _loadOrders() {
    // Listen for data changes
    _dbRef.onValue.listen((event) {
      setState(() {
        _isLoading = false;
        if (event.snapshot.value != null) {
          try {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            _orders = data.entries.map((e) {
              try {
                final val = Map<String, dynamic>.from(e.value as Map);
                return {'id': e.key, ...val};
              } catch (mapError) {
                print('Error mapping individual order: $mapError');
                return <String, dynamic>{'id': e.key};
              }
            }).toList();
          } catch (e) {
            print('Error parsing order data: $e');
            // Use fallback mock data if there's an error
            _loadMockOrders();
          }
        } else {
          // Use mock data if no orders exist
          _loadMockOrders();
        }
      });
    }, onError: (error) {
      print('Error loading orders: $error');
      setState(() {
        _isLoading = false;
        _loadMockOrders();
      });
    });
  }

  // Fallback method to load mock data
  void _loadMockOrders() {
    _orders = [
      {
        'id': 'ORD-001',
        'pickup': 'Al Khuwair, Muscat',
        'dropoff': 'Qurum Beach, Muscat',
        'customer': 'Ahmed Al-Balushi',
        'amount': '3.500 OMR',
        'distance': '5.2 km',
        'time': '15 min',
        'status': 'Pending',
      },
      {
        'id': 'ORD-002',
        'pickup': 'Muttrah Corniche',
        'dropoff': 'Grand Mall, Muscat',
        'customer': 'Fatima Al-Zadjali',
        'amount': '4.250 OMR',
        'distance': '8.3 km',
        'time': '22 min',
        'status': 'In Progress',
      },
      {
        'id': 'ORD-003',
        'pickup': 'Sultan Qaboos University',
        'dropoff': 'Muscat City Centre',
        'customer': 'Mohammed Al-Habsi',
        'amount': '6.750 OMR',
        'distance': '12.6 km',
        'time': '30 min',
        'status': 'Completed',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> filtered = _selectedFilter == 'All'
        ? _orders
        : _orders.where((o) => o['status'] == _selectedFilter).toList();
    if (query.isNotEmpty) {
      filtered = filtered.where((o) =>
        o['id'].toString().toLowerCase().contains(query) ||
        (o['customer'] ?? '').toString().toLowerCase().contains(query) ||
        (o['status'] ?? '').toString().toLowerCase().contains(query)
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), backgroundColor: AppConstants.primaryColor),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterSection(),
                _buildSearchBar(),
                Expanded(
                  child: _filteredOrders.isEmpty ? _buildEmptyState() : _buildOrdersList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: _filterOptions.map((filter) {
          return FilterChip(
            label: Text(filter),
            selected: _selectedFilter == filter,
            onSelected: (_) => setState(() => _selectedFilter = filter),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by Order ID, Customer Name, or Status',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No orders found'),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Place New Order',
            onPressed: () => Navigator.pushNamed(context, '/place_order'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return OrderCard(
          orderId: order['id'].toString(),
          pickupLocation: order['pickup'] ?? '',
          dropoffLocation: order['dropoff'] ?? '',
          customerName: order['customer'] ?? '',
          amount: order['amount'] ?? '',
          distance: order['distance'] ?? '',
          time: order['time'] ?? '',
          status: order['status'] ?? 'Pending',
          onTap: () => _showOrderDetails(order),
          onAccept: order['status'] == 'Pending' ? () => _acceptOrder(order['id'].toString()) : null,
        );
      },
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final pickupController = TextEditingController(text: order['pickup']);
        final dropoffController = TextEditingController(text: order['dropoff']);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Order ${order['id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Pickup Location')),
              TextField(controller: dropoffController, decoration: const InputDecoration(labelText: 'Dropoff Location')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _dbRef.child(order['id'].toString()).update({
                    'pickup': pickupController.text,
                    'dropoff': dropoffController.text,
                  }).then((_) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order updated.')));
                  }).catchError((error) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $error')));
                  });
                },
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _cancelOrder(order['id'].toString());
                },
                child: const Text('Cancel Order'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _acceptOrder(String orderId) {
    _dbRef.child(orderId).update({'status': 'In Progress'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order $orderId accepted.')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept order: $error')));
    });
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order $orderId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              _dbRef.child(orderId).update({'status': 'Cancelled'}).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order $orderId cancelled.')));
              }).catchError((error) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel order: $error')));
              });
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}