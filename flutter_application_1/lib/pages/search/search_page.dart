import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home/main_page.dart';
import 'package:flutter_application_1/utils/colors.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0; // เก็บค่าดัชนีของแถบที่ถูกเลือก

  // ลิสต์ข้อมูลสถานที่ที่มีชื่อและรูปแบบ Asset
  List<Map<String, dynamic>> _places = [
    {
      'name': 'บึงสีไฟ',
      'image': 'assets/images/buengsifai2.jpg',
      'categories': ['กลุ่ม', 'เด็ก', 'ฤดูร้อน', 'สถานที่ท่องเที่ยว']
    },
    {
      'name': 'ลานเวฬา',
      'image': 'assets/images/lanvela1.jpg',
      'categories': ['คนเดียว', 'ผู้ใหญ่', 'ฤดูหนาว', 'สถานที่ท่องเที่ยว']
    },
    {
      'name': 'ตลาดเก่าวังกรด',
      'image': 'assets/images/wangkrot1.jpg',
      'categories': ['กลุ่ม', 'ผู้ใหญ่', 'ฤดูร้อน', 'สถานที่ท่องเที่ยว']
    },
    {
      'name': 'วัดโพธิ์ประทับช้าง',
      'image': 'assets/images/watpo1.jpg',
      'categories': ['ผู้สูงอายุ', 'ฤดูฝน', 'สถานที่ท่องเที่ยว']
    },
    {
      'name': 'บะหมี่ลิ้นชัก',
      'image': 'assets/images/bamilinchak1.jpg',
      'categories': ['กลุ่ม', 'ผู้ใหญ่', 'ร้านอาหาร']
    },
    {
      'name': 'สะพานศิลป์',
      'image': 'assets/images/sapansin.jpg',
      'categories': ['กลุ่ม', 'เด็ก', 'ฤดูร้อน', 'สถานที่ท่องเที่ยว']
    },
    {
      'name': 'วัดเขารูปช้าง',
      'image': 'assets/images/watkhao1.jpg',
      'categories': ['ผู้สูงอายุ', 'ฤดูหนาว', 'สถานที่ท่องเที่ยว']
    },
  ];

  List<Map<String, dynamic>> _filteredPlaces = [];

  String _selectedCategory = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    _filteredPlaces = _places;
  }

  // ฟังก์ชันลบวรรณยุกต์และสระพิเศษออกจากข้อความ
  String removeThaiTone(String input) {
    return input.replaceAll(RegExp(r'[่-๋]'), ''); // ลบวรรณยุกต์ในภาษาไทย
  }

  void _filterPlaces(String query) {
    List<Map<String, dynamic>> _results = [];
    String searchQuery = removeThaiTone(query.toLowerCase());

    _results = _places.where((place) {
      String placeName = removeThaiTone(place['name']!.toLowerCase());

      // ตรวจสอบว่า categories ไม่เป็น null และ contains category ที่เลือก
      bool matchesCategory = _selectedCategory == 'ทั้งหมด' ||
          (place['categories'] != null && place['categories']!.contains(_selectedCategory));

      return placeName.contains(searchQuery) && matchesCategory;
    }).toList();

    setState(() {
      _filteredPlaces = _results;
    });
  }

  // ฟังก์ชันสำหรับการเลือกประเภทตัวกรอง
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterPlaces(_searchController.text);
    });
  }

  // ฟังก์ชันสำหรับเปลี่ยนหน้าเมื่อเลือกแถบด้านล่าง
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // นำทางไปยังหน้า main_page.dart เมื่อกดปุ่ม "Home" (index = 0)
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาสถานที่ท่องเที่ยว'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาสถานที่...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (value) {
                  _filterPlaces(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildCategoryButton('ทั้งหมด'),
                    buildCategoryButton('คนเดียว'),
                    buildCategoryButton('กลุ่ม'),
                    buildCategoryButton('ผู้สูงอายุ'),
                    buildCategoryButton('ผู้ใหญ่'),
                    buildCategoryButton('เด็ก'),
                    buildCategoryButton('ฤดูฝน'),
                    buildCategoryButton('ฤดูหนาว'),
                    buildCategoryButton('ฤดูร้อน'),
                    buildCategoryButton('ร้านอาหาร'),
                    buildCategoryButton('ของฝาก'),
                    buildCategoryButton('ที่พัก'),
                    buildCategoryButton('สถานที่ท่องเที่ยว'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredPlaces.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 2.5, // ปรับสัดส่วนความสูง
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // เพิ่มความโค้งมนให้กรอบรูป
                    ),
                    child: Column(
                      children: [
                        // รูปภาพที่โค้งมนขึ้น
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20), // เพิ่มความโค้งมนให้รูปภาพ
                          child: Image.asset(
                            _filteredPlaces[index]['image']!,
                            fit: BoxFit.cover,
                            height: 150, // กำหนดความสูงของรูปภาพ
                            width: double.infinity,
                          ),
                        ),
                        SizedBox(height: 8), // ระยะห่างระหว่างรูปภาพและตัวอักษร
                        // ชื่อสถานที่อยู่ใต้รูปภาพ
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _filteredPlaces[index]['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildCategoryButton(String label) {
    return GestureDetector(
      onTap: () => _filterByCategory(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
          label: Text(label),
          backgroundColor: _selectedCategory == label
              ? const Color.fromARGB(255, 238, 216, 76)
              : Colors.grey[300],
        ),
      ),
    );
  }
}