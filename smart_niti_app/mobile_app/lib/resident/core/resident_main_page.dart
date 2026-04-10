import 'package:flutter/material.dart';
import '../features/booking/booking_page.dart';
import '../features/parcel/parcel_page.dart';
import '../features/profile/profile_page.dart';
import '../features/home/home_page.dart';
import 'widgets/main_bottom_nav.dart';
import '../features/repair_request/repair_request_page.dart';

class ResidentMainPage extends StatefulWidget {
  const ResidentMainPage({super.key});

  @override
  State<ResidentMainPage> createState() => _ResidentMainPageState();
}

class _ResidentMainPageState extends State<ResidentMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    BookingPage(),
    ParcelPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _currentIndex == 0
          ? SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RepairRequestPage(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF0F172A),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 3),
                ),
                elevation: 10,
                child: const Icon(
                  Icons.handyman,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
