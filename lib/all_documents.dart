import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:screen_share/api/api.dart';
import 'package:screen_share/auth.dart';
import 'package:screen_share/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class All_DocumentsScreen extends StatefulWidget {
  final String id, name, code, description, created_at;

  All_DocumentsScreen(
    this.id,
    this.name,
    this.code,
    this.description,
    this.created_at,
  );

  @override
  State<All_DocumentsScreen> createState() => _All_DocumentsScreenState();
}

class _All_DocumentsScreenState extends State<All_DocumentsScreen> {
  var userData, next;
  List<GroupDocument_Item>? group_document_data;
  // List<JoinGroup_Item>? join_group_data;

  @override
  void initState() {
    checkLoginStatus();
    _getUserInfo();

    super.initState();
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson!);
    setState(() {
      userData = user;
    });
    print(userData);
    fetchDocumentData();
  }

  fetchDocumentData() async {
    // var customer = userData['id'].toString();
    String url = 'group_files/' + widget.id;
    // if (next != null) {
    //   url = url_format(next);
    // }
    var res = await CallApi().authenticatedGetRequest(url, context: context);

    print(res);
    if (res != null) {
      var body = json.decode(res.body);
      print(body);
      var group_documentItensJson = body;
      List<GroupDocument_Item> _group_document_items = [];
      if (next != null) {
        _group_document_items = group_document_data!;
      }

      for (var f in group_documentItensJson) {
        GroupDocument_Item group_document_items = GroupDocument_Item(
          f['id'].toString(),
          f['book'].toString(),
          f['file'].toString(),
        );
        _group_document_items.add(group_document_items);
      }
      print(_group_document_items.length);
      // setState(() {
      //   loading = false;
      // });

      setState(() {
        group_document_data = _group_document_items;
      });
    } else {
      showSnack(context, 'No network');
      return [];
    }
  }

  void _view_document_API() async {
    var data = {
      // 'username': userEmailController.text,
      // 'password': userPasswordController.text,
    };

    print(data);

    var res = await CallApi().authenticatedPostRequest(data, 'auth/login');
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
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else if (res.statusCode == 400) {
        print('hhh');
      } else {}
    }
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
            'Documents',
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
                // onSelected: (item) => onSelected(context, item),
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
      body: SafeArea(
          child: Column(
        children: [
          Expanded(child: my_document_Component()),
        ],
      )),
    );
  }

  my_document_Component() {
    if (group_document_data == null) {
      return Center(
        child: Text('No Network or Connection...'),
      );
    } else if (group_document_data != null &&
        group_document_data?.length == 0) {
      // No Data
      return Center(
        child: Text('No Data or No Group yet...'),
      );
    } else {
      return GridView.builder(
          itemCount: group_document_data!.length,
          // itemBuilder: (context, i)
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, i) {
            return GridTile(
                child: InkWell(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/file.png',
                      width: 100,
                      height: 100, //Folder Secured
                    ),
                    Text(
                      group_document_data![i].name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              onTap: () async {
                print(i);
                print(await CallApi.media_url + group_document_data![i].name);
              },
            ));
          });
    }
  }
}

class GroupDocument_Item {
  final String id, name, file;

  GroupDocument_Item(
    this.id,
    this.name,
    this.file,
  );
}
