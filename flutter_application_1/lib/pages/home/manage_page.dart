import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับใช้ Firestore
import 'package:flutter_application_1/pages/home/login_page.dart';
import 'package:flutter_application_1/pages/location/recommend_detail.dart';
import 'package:flutter_application_1/pages/search/search_page.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/big_text.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ลบปุ่มย้อนกลับออก
        backgroundColor: AppColors.mainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BigText(text: 'SpotPich', color: Colors.white),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.admin_panel_settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        elevation: 5, // เพิ่มเงา
        shape: RoundedRectangleBorder( // เพิ่มการโค้งมนให้ AppBar
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            // แสดงข้อมูลจาก Firestore
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('locations').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('ไม่มีข้อมูลสถานที่'));
                  }

                  final locations = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      var location = locations[index];
                      var data = location.data() as Map<String, dynamic>?;

                      if (data == null) {
                        return ListTile(
                          title: Text('ไม่มีข้อมูล'),
                        );
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 6, // เพิ่มระดับเงา
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell( // เพิ่ม InkWell เพื่อให้มีเอฟเฟกต์การกด
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecommendDetail(locationId: location.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: data.containsKey('image_url') && data['image_url'] != null
                                      ? Image.network(
                                          data['image_url'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.image, size: 100, color: Colors.grey),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'ไม่มีชื่อสถานที่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        data['location'] ?? 'ไม่มีข้อมูลที่ตั้ง',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: AppColors.mainColor),
                                          SizedBox(width: 5),
                                          Text('ระยะทาง: ${data['distance'] ?? 'N/A'} km'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: AppColors.mainColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_history),
            label: 'ใกล้ฉัน',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.mainColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10, // เพิ่มความสูงของเงา
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}