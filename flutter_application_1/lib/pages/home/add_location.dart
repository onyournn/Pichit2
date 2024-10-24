import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';  // สำหรับเลือกภาพ
import 'dart:io';  // สำหรับจัดการไฟล์

class AddLocation extends StatefulWidget {
  const AddLocation({super.key});

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController(); // สำหรับละติจูด
  final TextEditingController _longitudeController = TextEditingController(); // สำหรับลองติจูด
  final TextEditingController _mapUrlController = TextEditingController(); // สำหรับ URL แผนที่

  final CollectionReference locations = FirebaseFirestore.instance.collection('locations');

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
      return null;
    }
  }

  // ฟังก์ชันบันทึกข้อมูลใหม่
  void _saveNewLocation() async {
    String name = _nameController.text;
    String location = _locationController.text;
    String description = _descriptionController.text;
    String latitude = _latitudeController.text;
    String longitude = _longitudeController.text;
    String mapUrl = _mapUrlController.text;

    if (name.isNotEmpty && location.isNotEmpty && description.isNotEmpty && latitude.isNotEmpty && longitude.isNotEmpty && mapUrl.isNotEmpty && _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = await _uploadImage(_selectedImage!);

      if (imageUrl != null) {
        await locations.add({
          'name': name,
          'location': location,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'map_url': mapUrl,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        }).then((value) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
          );
          _nameController.clear();
          _locationController.clear();
          _descriptionController.clear();
          _latitudeController.clear();
          _longitudeController.clear();
          _mapUrlController.clear();
          setState(() {
            _selectedImage = null;
          });
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้: $error')),
          );
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('การอัพโหลดรูปภาพล้มเหลว')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วนและเลือกภาพ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มสถานที่ใหม่'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ช่องกรอกชื่อสถานที่
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อสถานที่',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // ช่องกรอกที่ตั้ง
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'ที่ตั้ง',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // ช่องกรอกรายละเอียด
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'รายละเอียด',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.0),

                    // ช่องกรอกละติจูด
                    TextField(
                      controller: _latitudeController,
                      decoration: InputDecoration(
                        labelText: 'ละติจูด',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // ช่องกรอกลองติจูด
                    TextField(
                      controller: _longitudeController,
                      decoration: InputDecoration(
                        labelText: 'ลองติจูด',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // ช่องกรอก URL แผนที่
                    TextField(
                      controller: _mapUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL แผนที่ Google Maps',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // แสดงรูปภาพที่เลือก หรือปุ่มเลือกภาพ
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
                              ? Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                              : Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),

                    // ปุ่มบันทึกข้อมูลสถานที่ใหม่
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveNewLocation,
                        child: Text('บันทึกสถานที่'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}