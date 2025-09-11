import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MatrimonyGalleryUpload extends StatefulWidget {
  @override
  _MatrimonyGalleryUploadState createState() => _MatrimonyGalleryUploadState();
}

class _MatrimonyGalleryUploadState extends State<MatrimonyGalleryUpload> {
  final picker = ImagePicker();
  List<File> _galleryImages = [];
  bool _isUploading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _galleryImages.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      appBar: AppBar(title: Text("My Gallery"), backgroundColor: pinkColor),
      body: Column(
        children: [
          Expanded(
            child:
                _galleryImages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_album_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No photos uploaded",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _galleryImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _galleryImages.removeAt(index);
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.add_a_photo),
                label: Text("Add Photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



//Upload image


