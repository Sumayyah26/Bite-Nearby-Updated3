import 'package:flutter/material.dart';
import 'package:bite_nearby/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bite_nearby/screens/home/prefrences.dart';
import 'package:bite_nearby/screens/home/orders.dart';
import 'package:bite_nearby/screens/home/Restaurants.dart';
import 'package:bite_nearby/services/location.dart';
import 'package:bite_nearby/Coolors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  final AuthService _auth = AuthService();
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String? _currentLocation;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<String?> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          // Add proper null checks and formatting
          String username = snapshot.get('username') ?? 'User';
          return username.trim().isNotEmpty ? username : 'User';
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
    return "Guest";
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      LocationService locationService = LocationService();
      Map<String, dynamic> locationData =
          await locationService.getCurrentLocation();

      setState(() {
        _currentLocation = " ${locationData['address']}";
        _isFetchingLocation = false;
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _currentLocation = "Location unavailable";
        _isFetchingLocation = false;
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildHeader(String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Coolors.charcoalBlack,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10), // Reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for compact size
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align items vertically center
            children: [
              // Welcome Section
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back,",
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 14, // Reduced from 16
                        color: Coolors.lightOrange.withOpacity(0.7),
                      )),
                  SizedBox(height: 10), // Reduced spacing
                  FutureBuilder<String?>(
                    future: _getUsername(),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? "Guest",
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 20, // Reduced from 20
                        fontWeight: FontWeight.bold,
                        color: Coolors.lightOrange,
                      ),
                    ),
                  ),
                ],
              ),

              // Location + Logout
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Location Row
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6, vertical: 5), // Tighter padding
                    decoration: BoxDecoration(
                      color: Coolors.oliveGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 12, // Smaller icon
                            color: Coolors.oliveGreen),
                        SizedBox(width: 4),
                        SizedBox(
                          width: 200, // Narrower width
                          child: Text(
                            _currentLocation ?? "Locating...",
                            style: TextStyle(
                              fontSize: 10, // Smaller text
                              color: Coolors.oliveGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logout Button
                  TextButton.icon(
                    onPressed: () async => await _auth.signOut(),
                    icon: Icon(Icons.logout,
                        size: 18, // Smaller icon
                        color: Coolors.lightOrange),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14, // Smaller text
                        color: Coolors.lightOrange,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Title removed to end after logout
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coolors.ivoryCream,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: onTabTapped,
          children: [
            // Home Page
            Column(
              children: [
                _buildHeader(""),
                Expanded(
                  child: Center(
                    child: Text(
                      "Home Page Content",
                      style: TextStyle(
                          fontSize: 18.0, color: Coolors.charcoalBlack),
                    ),
                  ),
                ),
              ],
            ),

            // Preferences Page
            const PreferencesPage(),

            // Orders Page
            OrdersPage(
              orderId: '',
              restaurantName: 'All Restaurants',
            ),

            // Restaurants Page
            const RestaurantListPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Coolors.charcoalBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Coolors.gold,
          unselectedItemColor: Coolors.ivoryCream,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Dietary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Restaurants',
            ),
          ],
        ),
      ),
    );
  }
}
