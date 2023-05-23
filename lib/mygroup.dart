import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:screen_share/all_documents.dart';
import 'package:screen_share/api/api.dart';
import 'package:screen_share/pdfview.dart';
import 'package:screen_share/utils/custom_input_field.dart';
import 'package:screen_share/utils/snackbar.dart';

class MyGroupScreen extends StatefulWidget {
  final String id, name, code, description, created_at;

  MyGroupScreen(
    this.id,
    this.name,
    this.code,
    this.description,
    this.created_at,
  );

  @override
  State<MyGroupScreen> createState() => _MyGroupScreenState();
}

class _MyGroupScreenState extends State<MyGroupScreen> {
  var userData;
  var rootid;
  var result;
  var status;

  var fileName;

  File? file;

  selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) {
      return;
    } else {
      file = File(result.files.single.path!);

      // List<File> files = result.paths.map((path) => File(path!)).toList();

      // print(result.files.single.path);
      print(file);

      setState(() {
        // file = File(path);
        // uploadFilePhaseZero();
      });

      print("file============$file");
      print("path============${file!.path}");
      // print("file============"+file!);

      // uploadFilePhaseOneDio();

      Navigator.of(this.context).push(
          MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)));
    }

    // ignore: unnecessary_null_comparison
    if (file!.path == null) {}
  }

  uploadFile() async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file!.path,

        filename: basename(file!.path),
        // contentType:  MediaType("image", "jpg"), //add this
      ),
      'group_id': widget.id,
    });

    var res =
        await CallApi().authenticatedUploadRequest(formData, 'upload_file');
    if (res == null) {
      // setState(() {
      //   _isLoading = false;
      //   // _not_found = true;
      // });
      // showSnack(context, 'No Network!');
    } else {
      var body = json.decode(res!.body);
      print(body);

      if (res.statusCode == 200) {
        showSnack(context, 'File Uploaded Successfully');

        setState(() {});
      } else if (res.statusCode == 400) {
        print('hhh');
        // setState(() {
        //   _isLoading = false;
        //   _not_found = true;
        // });
      } else {}
    }

  }

  selectFileToUpload() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) {
      return;
    } else {
      file = File(result.files.single.path!);

      // List<File> files = result.paths.map((path) => File(path!)).toList();

      // print(result.files.single.path);
      print(file);

      setState(() {
        // file = File(path);
        uploadFile();
      });

      print("file============" + file.toString());
      print("path============" + file!.path.toString());
      // print("file============"+file!);

      // uploadFilePhaseOneDio();
    }

    if (file!.path == null) {}
  }

  _add_Group_Dialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Add Group'),
            content: Column(
              children: [
                const CustomInputField(
                  // controller: clientNameController,
                  hintText: 'Group Name',
                  textInputAction: TextInputAction.next,
                ),
                // _contentServices(context),

                const SizedBox(
                  height: 30,
                ),

                // RadioButtonGroup(
                //   labels: [
                //     "Personal",
                //     "Business",
                //   ],
                //   labelStyle:
                //       TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                //   // disabled: ["Option 1"],
                //   onChange: (String label, int index) => setState(() {
                //     value = index;
                //     print("label: $label index: $index");
                //   }),

                //   onSelected: (String label) => print(label),
                // ),

                // const SizedBox(
                //   height: 16,
                // ),

                MaterialButton(
                  elevation: 0,
                  color: const Color(0xFF44B6AF),
                  height: 50,
                  minWidth: 500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    // _add_client_API();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          );
        });
  }

  _join_Group_Dialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Join Group'),
            content: Column(
              children: [
                const CustomInputField(
                  // controller: clientNameController,
                  hintText: 'Group Code',
                  textInputAction: TextInputAction.next,
                ),
                // _contentServices(context),

                const SizedBox(
                  height: 30,
                ),

                // RadioButtonGroup(
                //   labels: [
                //     "Personal",
                //     "Business",
                //   ],
                //   labelStyle:
                //       TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                //   // disabled: ["Option 1"],
                //   onChange: (String label, int index) => setState(() {
                //     value = index;
                //     print("label: $label index: $index");
                //   }),

                //   onSelected: (String label) => print(label),
                // ),

                // const SizedBox(
                //   height: 16,
                // ),

                MaterialButton(
                  elevation: 0,
                  color: const Color(0xFF44B6AF),
                  height: 50,
                  minWidth: 500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    // _add_client_API();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // automaticallyImplyLeading: true,
          foregroundColor: Theme.of(context).hintColor,
          backgroundColor: Colors.transparent,
          // backgroundColor: Colors.white,
          // foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'My Group',
            style: TextStyle(),
          ),
          // leading: Container(
          //     height: 50,
          //     width: 50,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15),
          //         color: Colors.white,
          //         image: const DecorationImage(
          //             image: AssetImage("assets/logow.png"),
          //             fit: BoxFit.cover)),
          // ),
          actions: <Widget>[
            PopupMenuButton<int>(
                onSelected: (item) => onSelected(context, item),
                icon: const Icon(
                  Icons.more_vert,
                  // color: Colors.black,
                ),
                itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 0,
                        child: Text(
                          'Upload File',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text(
                          'View All Document',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      // PopupMenuItem(
                      //   value: 2,
                      //   child: Text(
                      //     'Settings',
                      //     style: TextStyle(fontSize: 14),
                      //   ),
                      // ),

                      PopupMenuItem(
                        value: 1,
                        child: Text(
                          'Logout',
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ])
          ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          selectFile();
          // _add_Group_Dialog(context);
        },
        label: const Text('Select File'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        selectFileToUpload();
        // _join_Group_Dialog(context);
        // createAlertDialog_ChoosePDF(context);
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => SocialDashboardScreen()));
        break;

      case 1:

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => All_DocumentsScreen(
              widget.id, 
              widget.name, 
              widget.code, 
              widget.description, 
              widget.created_at,
            )));
        break;

      case 2:

        // createAlertDialog_ChoosePDF(context);
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => SocialDashboardScreen()));
        break;

      case 3:
        // _logoutDialog(context);
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => ClassRoom_Page()));
        break;

      default:
    }
  }
}
