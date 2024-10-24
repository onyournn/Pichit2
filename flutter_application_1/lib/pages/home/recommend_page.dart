import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/app_column.dart';
import 'package:flutter_application_1/widgets/icon_text_widget.dart';
import 'package:flutter_application_1/widgets/big_text.dart';
import 'package:flutter_application_1/widgets/small_text.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key, required Null Function() onImageTap});

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Dimensions.pageViewContainer;

  // สร้างตัวแปรเก็บข้อมูลจาก Firestore
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;  // สถานะการโหลดข้อมูล
  String _errorMessage = '';  // เก็บข้อความแสดงข้อผิดพลาด

  @override
  void initState() {
    super.initState();

    // เรียกข้อมูลจาก Firestore
    FirebaseFirestore.instance.collection('places').get().then((querySnapshot) {
      setState(() {
        _places = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _isLoading = false;  // เสร็จสิ้นการโหลดข้อมูล
      });
    }).catchError((error) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการดึงข้อมูล: $error';  // แสดงข้อผิดพลาด
        _isLoading = false;
      });
    });

    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // แสดงการโหลด
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))  // แสดงข้อความข้อผิดพลาด
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Slider section
                      Container(
                        height: Dimensions.pageView,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: _places.length, // ใช้จำนวนข้อมูลจาก Firestore
                          itemBuilder: (context, position) {
                            return _buildPageItem(position);
                          },
                        ),
                      ),
                      // Dots Indicator
                      Center(
                        child: _places.isNotEmpty
                            ? DotsIndicator(
                                dotsCount: _places.length,  // ตรวจสอบจำนวนข้อมูลที่ไม่เป็นศูนย์
                                position: _currPageValue.toInt(),
                                decorator: DotsDecorator(
                                  activeColor: AppColors.mainColor,
                                  size: const Size.square(9.0),
                                  activeSize: const Size(18.0, 9.0),
                                  activeShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),  // ซ่อน DotsIndicator เมื่อไม่มีข้อมูล
                      ),
                      SizedBox(height: Dimensions.height15),
                      // ListView.builder ห่อด้วย Container ที่กำหนดขนาด
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          itemCount: _places.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return _buildListItem(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPageItem(int index) {
    var place = _places[index];
    Matrix4 matrix = new Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale = _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          Container(
            height: Dimensions.pageViewContainer,
            margin: EdgeInsets.only(left: Dimensions.width10, right: Dimensions.width10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius30),
              color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(place['image_url']), // ดึงรูปจาก Firestore
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Dimensions.pageViewTextContainer,
              margin: EdgeInsets.only(
                left: Dimensions.radius15,
                right: Dimensions.radius15,
                bottom: Dimensions.height30,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: 5.0,
                    offset: Offset(0, 5),
                  ),
                  BoxShadow(color: Colors.white, offset: Offset(-5, 0)),
                  BoxShadow(color: Colors.white, offset: Offset(5, 0)),
                ],
              ),
              child: Container(
                padding: EdgeInsets.only(
                  top: Dimensions.height15,
                  left: Dimensions.height10,
                  right: Dimensions.height10,
                ),
                child: AppColumn(text: place['name']), // ใช้ชื่อจาก Firestore
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    var place = _places[index];
    return Container(
      margin: EdgeInsets.only(
        left: Dimensions.height10,
        right: Dimensions.height10,
        bottom: Dimensions.height10,
      ),
      child: Row(
        children: [
          Container(
            width: Dimensions.ListViewImgSize,
            height: Dimensions.ListViewImgSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              color: Colors.white38,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(place['image_url']), // ดึงรูปจาก Firestore
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: Dimensions.ListViewTextContSize,
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
                    BigText(text: place['name']),
                    SizedBox(height: Dimensions.height10),
                    SmallText(text: "Type: ${place['type']}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextWidget(
                          icon: Icons.group,
                          text: place['group'],
                          iconColor: AppColors.iconColor1,
                        ),
                        IconTextWidget(
                          icon: Icons.location_on,
                          text: "${place['distance']} km",
                          iconColor: AppColors.iconColor2,
                        ),
                        IconTextWidget(
                          icon: Icons.location_city,
                          text: place['location'],
                          iconColor: AppColors.iconColor3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}