import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/app_column.dart';
import 'package:flutter_application_1/widgets/app_icon.dart';
import 'package:flutter_application_1/widgets/big_text.dart';
import 'package:flutter_application_1/widgets/exandable_text_widgets.dart';
import 'package:flutter_application_1/widgets/icon_text_widget.dart';
import 'package:flutter_application_1/widgets/small_text.dart';

class PopularLocationDetail extends StatelessWidget {
  const PopularLocationDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: Dimensions.popularLocationImgSize,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/buengsifai1.jpg"))),
              )),
          Positioned(
            top: Dimensions.height45,
            left: Dimensions.width20,
            right: Dimensions.width20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcon(icon: Icons.arrow_back_ios),
                //AppIcon(icon: Icons.)
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: Dimensions.popularLocationImgSize - 20,
              child: Container(
                  padding: EdgeInsets.only(
                      left: Dimensions.width20,
                      right: Dimensions.width20,
                      top: Dimensions.height20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(Dimensions.radius20),
                          topLeft: Radius.circular(Dimensions.radius20)),
                      color: Colors.white
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppColumn(text: "บึงสีไฟ"),
                      SizedBox(
                        height: Dimensions.height20,),
                      BigText(text: "Introduce"),
                      SizedBox(height: Dimensions.height20,),
                      Expanded(child: SingleChildScrollView(child: ExpandableTextWidget
                      (text: "บึงสีไฟ เป็นแหล่งน้ำจืดขนาดใหญ่ของประเทศไทย ตั้งอยู่ในจังหวัดพิจิตรบึงสีไฟเป็นแหล่งเพาะพันธุ์สัตว์น้ำจืด แหล่งอาศัยของนกหลายชนิด และยังเป็นสถานที่พักผ่อนหย่อนใจที่สำคัญของจังหวัดพิจิตรด้วยบึงสีไฟมีจุดที่น่าสนใจหลายแห่งสวนสมเด็จพระศรีนครินทร์ พิจิตร สร้างขึ้นเพื่อเฉลิมพระเกียรติสมเด็จพระศรีนครินทราบรมราชชนนีรูปปั้นพญาชาลวัน ตามตำนานเรื่องไกรทอง สถานแสดงพันธุ์ปลาเฉลิมพระเกียรติ หรือที่นิยมเรียกกันว่า ศาลาเก้าเหลี่ยม ศาลากลางน้ำ คือศาลาที่ตั้งอยู่บนบึงสีไฟ มีทั้งหมด 4 ศาลา นักท่องเที่ยวนิยมมาให้อาหารสัตว์น้ำบนศาลา บ่อจระเข้  มีมุมพักผ่อน ที่นั่งเล่น ชมวิวริมบึง เป็นอีกหนึ่งจุดถ่ายรูปที่สวยงาม", onExpandedChanged: (isExpanded) {  },)))
                    ],
                  )
                )
              )
        ],
      ),
      bottomNavigationBar: Container(
        height: Dimensions.bottomHeightBar,
        padding: EdgeInsets.only(
            top: Dimensions.height30,
            bottom: Dimensions.height30,
            left: Dimensions.height20,
            right: Dimensions.height20),
        decoration: BoxDecoration(
            color: AppColors.buttonBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius20 * 2),
                topRight: Radius.circular(Dimensions.radius20 * 2))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Container(
          // padding: EdgeInsets.only(top: Dimensions.height20, bottom: Dimensions.height20, left: Dimensions.width20, right: Dimensions.width20),
          // decoration: BoxDecoration(
          //  borderRadius: BorderRadius.circular(Dimensions.radius20),
          // color: Colors.white
          // ),
          //), ปุ่มสีขาว
          Container(
            padding: EdgeInsets.only(
                top: Dimensions.height20,
                bottom: Dimensions.height20,
                left: Dimensions.width20,
                right: Dimensions.width20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              color: AppColors.mainColor,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on, // ใช้ไอคอนที่คุณต้องการ
                  color: Colors.white, // สีของไอคอน
                ),
                SizedBox(
                    width:
                        Dimensions.width10), // ช่องว่างระหว่างไอคอนและข้อความ
                BigText(
                  text: "Route",
                  color: Colors.white,
                ),
              ],
            ),
          ),
        
        ]),
      ),
    );
  }
}