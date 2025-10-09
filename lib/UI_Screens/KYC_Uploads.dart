import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  File? jathakamFile;
  File? communityFile;
  File? aadharFile;

  int? userId;

  bool uploadingJathakam = false;
  bool uploadingCommunity = false;
  bool uploadingAadhar = false;

  bool updatingKyc = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id != null && mounted) {
      setState(() {
        userId = int.parse(id);
      });
    }
  }

  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        if (!file.path.toLowerCase().endsWith('.pdf')) {
          _showMessage("Please select a PDF file only");
          return null;
        }
        return file;
      }
    } catch (e) {
      _showMessage("File picking failed: $e");
    }
    return null;
  }

  Future<String?> uploadFile(
    File file,
    String rawUrl,
    String fieldName,
    Function(bool) setUploading,
  ) async {
    setUploading(true);
    try {
      final url = Uri.parse(rawUrl);
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return file.path.split('/').last;
      } else {
        _showMessage("Upload failed: ${response.statusCode} → $responseBody");
      }
    } catch (e) {
      _showMessage("Upload error: $e");
    }
    setUploading(false);
    return null;
  }

  Future<void> updateKyc() async {
    if (userId == null) {
      _showMessage("User ID not found");
      return;
    }

    if (jathakamFile == null && communityFile == null && aadharFile == null) {
      _showMessage("Please upload at least one document");
      return;
    }

    setState(() => updatingKyc = true);

    String? jathakamName;
    String? communityName;
    String? aadharName;

    if (jathakamFile != null) {
      jathakamName = await uploadFile(
        jathakamFile!,
        "https://pheonixconstructions.com/Matrimony%20API/upload_jathakam.php",
        "jathakam_file",
        (val) => setState(() => uploadingJathakam = val),
      );
    }

    if (communityFile != null) {
      communityName = await uploadFile(
        communityFile!,
        "https://pheonixconstructions.com/Matrimony%20API/upload_community_certificate.php",
        "community_file",
        (val) => setState(() => uploadingCommunity = val),
      );
    }

    if (aadharFile != null) {
      aadharName = await uploadFile(
        aadharFile!,
        "https://pheonixconstructions.com/Matrimony%20API/upload_aadhar.php",
        "aadhar_file",
        (val) => setState(() => uploadingAadhar = val),
      );
    }

    final body = <String, String>{
      "user_id": userId.toString(),
      if (aadharName != null) "aadhar_img": aadharName,
      if (communityName != null) "community_certificate": communityName,
      if (jathakamName != null) "jathakam": jathakamName,
    };

    if (body.length > 1) {
      try {
        final updateUrl = Uri.parse(
          "https://pheonixconstructions.com/Matrimony API/update_user_kyc.php",
        );
        var response = await http.post(updateUrl, body: body);

        if (response.statusCode == 200) {
          _showSuccessDialog();
        } else {
          _showMessage("Update failed: ${response.statusCode}");
        }
      } catch (e) {
        _showMessage("Update error: $e");
      }
    }

    setState(() => updatingKyc = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("KYC Updated Successfully ✅"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget buildFileCard(
    String title,
    File? file,
    bool uploading,
    VoidCallback onPick,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          file != null ? file.path.split('/').last : "No file chosen",
        ),
        trailing:
            uploading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.pink,
                    strokeWidth: 2,
                  ),
                )
                : ElevatedButton(
                  onPressed: onPick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 5),
                      Text("Choose", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "KYC Uploads",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildFileCard(
              "Upload Jathakam",
              jathakamFile,
              uploadingJathakam,
              () async {
                final file = await pickFile();
                if (file != null) setState(() => jathakamFile = file);
              },
            ),
            buildFileCard(
              "Upload Community Certificate",
              communityFile,
              uploadingCommunity,
              () async {
                final file = await pickFile();
                if (file != null) setState(() => communityFile = file);
              },
            ),
            buildFileCard(
              "Upload Aadhaar Card",
              aadharFile,
              uploadingAadhar,
              () async {
                final file = await pickFile();
                if (file != null) setState(() => aadharFile = file);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: updatingKyc ? null : updateKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: pink,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  updatingKyc
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Updating KYC...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                      : const Text(
                        "Update KYC",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
