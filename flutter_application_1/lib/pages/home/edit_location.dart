import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';  // สำหรับเลือกภาพ
import 'dart:io';  // สำหรับจัดการไฟล์
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/dimensions.dart';
import 'package:flutter_application_1/widgets/big_text.dart';

class EditLocation extends StatefulWidget {
  final String documentId;  // รับค่า ID ของสถานที่
  final Map<String, dynamic> locationData;  // ข้อมูลสถานที่ที่จะมาแสดงในฟอร์ม

  const EditLocation({required this.documentId, required this.locationData});

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // ฟังก์ชันเลือกภาพจากแกลเลอรี
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันอัพโหลดรูปภาพไปที่ Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('location_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ: $e");
      return null;
    }
  }

  // ฟังก์ชันบันทึกข้อมูลที่แก้ไข
  void _saveEditedLocation() async {
    String name = _nameController.text;
    String location = _locationController.text;
    String description = _descriptionController.text;

    if (name.isNotEmpty && location.isNotEmpty && description.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = widget.locationData['image_url'];  // ใช้ URL รูปเดิม
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);  // อัพโหลดรูปใหม่ถ้ามีการเลือก
      }

      if (imageUrl != null) {
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.documentId)
            .update({
          'name': name,
          'type': location,
          'description': description,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        }).then((value) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('แก้ไขข้อมูลสำเร็จ')),
          );
          Navigator.pop(context);  // กลับไปยังหน้าก่อน
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถแก้ไขข้อมูลได้: $error')),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.locationData['name']);
    _locationController = TextEditingController(text: widget.locationData['type']);
    _descriptionController = TextEditingController(text: widget.locationData['description']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BigText(text: 'แก้ไขสถานที่', size: Dimensions.font26),
        backgroundColor: AppColors.mainColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อสถานที่',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radius15),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'ที่ตั้ง',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radius15),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'รายละเอียด',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radius15),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: Dimensions.height20),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _selectedImage == null
                              ? Image.network(widget.locationData['image_url'], fit: BoxFit.cover)
                              : Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEditedLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width30,
                              vertical: Dimensions.height15),
                        ),
                        child: Text(
                          'บันทึกการแก้ไข',
                          style: TextStyle(fontSize: Dimensions.font20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}