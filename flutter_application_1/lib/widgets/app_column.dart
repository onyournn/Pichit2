import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/big_text.dart';
import 'package:flutter_application_1/widgets/icon_text_widget.dart';
import 'package:flutter_application_1/widgets/small_text.dart';
import '../pages/location/recommend_detail.dart'; // Import หน้า RecommendDetail หรือหน้าอื่นที่ต้องการนำทางไป

class AppColumn extends StatelessWidget {
  final String text;
  const AppColumn({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อแก้ปัญหา overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(
            text: text,
            size: Dimensions.font26,
          ),
          SizedBox(
            height: Dimensions.height10,
          ),
          Row(
            children: [
              Wrap(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: AppColors.mainColor,
                    size: 15,
                  );
                }),
              ),
              SizedBox(
                width: 10,
              ),
              SmallText(text: "4.6"),
              SizedBox(
                width: 10,
              ),
              SmallText(text: "50"),
              SizedBox(
                width: 10,
              ),
              SmallText(text: "comments")
            ],
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconTextWidget(
                icon: Icons.group,
                text: "Group",
                iconColor: AppColors.iconColor1,
              ),
              GestureDetector(
                onTap: () {
                  // คำสั่งนี้จะนำทางไปยังหน้า RecommendDetail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecommendDetail(locationId: '',)), // เปลี่ยนเป็นหน้าอื่นตามต้องการ
                  );
                },
                child: IconTextWidget(
                  icon: Icons.location_on,
                  text: "1.7 km",
                  iconColor: AppColors.iconColor2,
                ),
              ),
              IconTextWidget(
                icon: Icons.location_city,
                text: "Location",
                iconColor: AppColors.iconColor3,
              ),
            ],
          )
        ],
      ),
    );
  }
}