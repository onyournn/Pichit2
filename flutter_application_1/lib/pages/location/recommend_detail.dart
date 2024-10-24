import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/home/main_page.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/big_text.dart';
import 'package:flutter_application_1/widgets/exandable_text_widgets.dart';
import 'package:flutter_application_1/widgets/small_text.dart'; // นำเข้า SmallText
import 'package:url_launcher/url_launcher.dart'; // นำเข้า url_launcher สำหรับเปิด Google Maps
import 'package:geolocator/geolocator.dart'; // นำเข้า geolocator สำหรับดึงพิกัดผู้ใช้

class RecommendDetail extends StatefulWidget {
  final String locationId; // รับ locationId เป็นตัวแปรใน RecommendDetail

  const RecommendDetail({Key? key, required this.locationId}) : super(key: key);

  @override
  _RecommendDetailState createState() => _RecommendDetailState();
}

class _RecommendDetailState extends State<RecommendDetail> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  int _selectedIndex = 0; // เพิ่มตัวแปรสำหรับ BottomNavigationBar

  void _setRating(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  // ฟังก์ชันบันทึกรีวิวไปยัง Firestore
  void _submitReview() async {
    String comment = _commentController.text;

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกจำนวนดาว')),
      );
    } else if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกความคิดเห็น')),
      );
    } else {
      try {
        // บันทึกข้อมูลรีวิวไปยัง Firestore
        await FirebaseFirestore.instance.collection('reviews').add({
          'locationId': widget.locationId, // ผูกรีวิวกับ locationId ที่รับมา
          'rating': _selectedRating,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกรีวิวเรียบร้อย')),
        );

        _commentController.clear();
        _setRating(0); // รีเซ็ตจำนวนดาวหลังจากบันทึกรีวิว
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ฟังก์ชันจัดการเมื่อมีการเลือกปุ่มใน BottomNavigationBar
  void _onItemTapped(int index, Map<String, dynamic> locationData) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // นำทางไปหน้าหลัก (MainPage) โดยใช้ Navigator.pushReplacement เพื่อแทนที่หน้าเดิม
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else if (index == 1) {
      // นำทางไป Google Maps โดยใช้พิกัดจาก Firestore และพิกัดผู้ใช้
      if (locationData['latitude'] == null || locationData['longitude'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('พิกัดสถานที่ไม่ถูกต้อง')),
        );
        return;
      }

      String destLat = locationData['latitude'].toString();
      String destLng = locationData['longitude'].toString();
      _launchMapsWithUserLocation(destLat, destLng);
    }
  }

  // ฟังก์ชันเปิด Google Maps โดยใช้พิกัดผู้ใช้และพิกัดสถานที่
  void _launchMapsWithUserLocation(String destLat, String destLng) async {
    // ตรวจสอบการอนุญาต
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // แจ้งให้ผู้ใช้เปิดการอนุญาตใน settings
      throw 'Location permissions are permanently denied.';
    }

    // ดึงพิกัดปัจจุบันของผู้ใช้
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String userLat = position.latitude.toString();
    String userLng = position.longitude.toString();

    // เปิด Google Maps พร้อมพิกัดผู้ใช้และสถานที่
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$destLat,$destLng');
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not open the map.';
    }
  }

  @override
  void initState() {
    super.initState();
    // Debug: แสดง locationId ที่ได้รับมา
    print('Received Location ID: ${widget.locationId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.locationId)
            .get(), // ดึงข้อมูลสถานที่จาก Firestore
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}"); // พิมพ์ข้อผิดพลาดในคอนโซล
            return Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          }

          var locationData = snapshot.data!.data() as Map<String, dynamic>?;

          if (locationData == null) {
            print('ไม่มีข้อมูลจาก Firestore');
            return Center(child: Text('ไม่มีข้อมูลจาก Firestore'));
          }

          print("Location Data: $locationData"); // พิมพ์ข้อมูลที่ดึงได้จาก Firestore

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false, // ลบปุ่มย้อนกลับ
                toolbarHeight: 70,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(20),
                  child: Container(
                    child: Center(
                        child: BigText(
                            size: Dimensions.font26,
                            text: locationData['name'] ?? 'ไม่มีชื่อสถานที่')),
                    width: double.maxFinite,
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.radius20),
                            topRight: Radius.circular(Dimensions.radius20))),
                  ),
                ),
                pinned: true,
                backgroundColor: AppColors.iconColor3,
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: locationData['image_url'] != null
                      ? Image.network(
                          locationData['image_url'],
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(Icons.image,
                              size: 100, color: Colors.grey)),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Dimensions.radius20),
                      bottomRight: Radius.circular(Dimensions.radius20),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Dimensions.width10,
                      right: Dimensions.width10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: Dimensions.height10),
                        SmallText(
                            text:
                                locationData['description'] ?? 'ไม่มีรายละเอียด'),
                        SizedBox(height: Dimensions.height20),
                        
                        SizedBox(height: Dimensions.height20),

                        // ส่วนการเขียนรีวิวและให้คะแนน
                        BigText(
                            text: 'เขียนรีวิวและให้คะแนน',
                            size: Dimensions.font20),
                        SizedBox(height: Dimensions.height10),

                        // ปุ่มเลือกดาว
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < _selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () =>
                                  _setRating(index + 1), // ให้คะแนน
                            );
                          }),
                        ),

                        // ช่องกรอกคอมเมนต์
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'แสดงความคิดเห็น',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ปุ่มส่งรีวิว
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width30,
                                  vertical: Dimensions.height15),
                            ),
                            child: Text('ส่งรีวิว'),
                          ),
                        ),

                        SizedBox(height: Dimensions.height30),

                        // ดึงข้อมูลรีวิวจาก Firestore
                        BigText(
                            text: 'รีวิวจากผู้ใช้',
                            size: Dimensions.font20),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('locationId',
                                  isEqualTo: widget.locationId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text('ยังไม่มีรีวิวสำหรับสถานที่นี้'),
                              );
                            } else {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var review = snapshot.data!.docs[index];
                                  int rating = review['rating'];

                                  // เปลี่ยนจากแสดงตัวเลขเป็นดาว
                                  return ListTile(
                                    title: Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        );
                                      }),
                                    ),
                                    subtitle: Text(review['comment']),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // เพิ่ม BottomNavigationBar ไว้ภายนอก FutureBuilder
      bottomNavigationBar: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.locationId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var locationData = snapshot.data!.data() as Map<String, dynamic>?;

            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'หน้าหลัก',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.route),
                  label: 'เส้นทาง',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: AppColors.mainColor, // สีของไอคอนที่ถูกเลือก
              onTap: (index) => _onItemTapped(index, locationData!),
            );
          }
        },
      ),
    );
  }
}