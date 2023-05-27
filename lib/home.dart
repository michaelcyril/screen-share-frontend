import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:screen_share/api/api.dart';
import 'package:screen_share/auth.dart';
import 'package:screen_share/mygroup.dart';
import 'package:screen_share/utils/custom_input_field.dart';
import 'package:screen_share/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userData, next;

  List<MyGroup_Item>? my_group_data;
  List<JoinGroup_Item>? join_group_data;

  @override
  void initState() {
    checkLoginStatus();
    _getUserInfo();

    //listenNotifications();
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
    fetchMyGroupData();
    fetchJoinGroupData();
  }

  _logoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Logout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "Are you sure you want to logout",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                          onTap: () async {
                            // _deleteSingleProductTocart(index);
                            // logOUT_User();
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.clear();
                            Navigator.of(context).pop();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: Text('Yes')),

                      SizedBox(
                        width: 30,
                      ),

                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No')),
                      // onPressed: () {
                      //   Navigator.of(context).pop();
                      // }
                    ])
              ],
            ),
          );
        });
  }

  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _add_Group_Dialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Add Group'),
            content: Column(
              children: [
                CustomInputField(
                  controller: groupNameController,
                  hintText: 'Group Name',
                  textInputAction: TextInputAction.next,
                ),
                // _contentServices(context),

                const SizedBox(
                  height: 30,
                ),

                CustomInputField(
                  controller: descriptionController,
                  hintText: 'Description',
                  textInputAction: TextInputAction.next,
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

                const SizedBox(
                  height: 30,
                ),

                MaterialButton(
                  elevation: 0,
                  color: const Color(0xFF44B6AF),
                  height: 50,
                  minWidth: 500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    _create_Group_API();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          );
        });
  }

  _create_Group_API() async {
    var data = {
      'name': groupNameController.text,
      'description': descriptionController.text,
      'created_by': userData['user']['id'],
      'type': 'driver',
    };

    var res = await CallApi().authenticatedPostRequest(data, 'create_group');
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
        showSnack(context, 'Group Created Successfully');
        groupNameController.clear;
        descriptionController.clear;

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

  TextEditingController codeController = TextEditingController();

  _join_Group_Dialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Join Group'),
            content: Column(
              children: [
                CustomInputField(
                  controller: codeController,
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
                    _joinGroup_API();
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

  _joinGroup_API() async {
    var data = {
      'user_id': userData['user']['id'],
      'code': codeController.text,
      // 'created_by': userData['user']['id'],
      // 'type': 'driver',
    };

    print(data);

    var res = await CallApi().authenticatedPostRequest(data, 'join_group');
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
        showSnack(context, 'Group Joined Successfully');
        codeController.clear;
        // descriptionController.clear;

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

  fetchMyGroupData() async {
    // var customer = userData['id'].toString();
    String url = 'created_group/' + userData['user']['id'].toString();
    // if (next != null) {
    //   url = url_format(next);
    // }
    var res = await CallApi().authenticatedGetRequest(url, context: context);

    print(res);
    if (res != null) {
      var body = json.decode(res.body);
      print(body);
      var my_groupItensJson = body;
      List<MyGroup_Item> _my_group_items = [];
      if (next != null) {
        _my_group_items = my_group_data!;
      }

      for (var f in my_groupItensJson) {
        MyGroup_Item my_group_items = MyGroup_Item(
          f['id'].toString(),
          f['name'].toString(),
          f['code'].toString(),
          f['description'].toString(),
          f['created_at'].toString(),
        );
        _my_group_items.add(my_group_items);
      }
      print(_my_group_items.length);
      // setState(() {
      //   loading = false;
      // });

      setState(() {
        my_group_data = _my_group_items;
      });
    } else {
      showSnack(context, 'No network');
      return [];
    }
  }

  fetchJoinGroupData() async {
    // var customer = userData['id'].toString();
    String url = 'joined_group/' + userData['user']['id'].toString();
    // if (next != null) {
    //   url = url_format(next);
    // }
    var res = await CallApi().authenticatedGetRequest(url, context: context);

    print(res);
    if (res != null) {
      var body = json.decode(res.body);
      print(body);
      var join_groupItensJson = body;
      List<JoinGroup_Item> _join_group_items = [];
      if (next != null) {
        _join_group_items = join_group_data!;
      }

      for (var f in join_groupItensJson) {
        JoinGroup_Item join_group_items = JoinGroup_Item(
          f['id'].toString(),
          f['name'].toString(),
          f['code'].toString(),
          f['description'].toString(),
          f['created_at'].toString(),
        );
        _join_group_items.add(join_group_items);
      }
      print(_join_group_items.length);
      // setState(() {
      //   loading = false;
      // });

      setState(() {
        join_group_data = _join_group_items;
      });
    } else {
      showSnack(context, 'No network');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          foregroundColor: Theme.of(context).hintColor,
          backgroundColor: Colors.transparent,
          // backgroundColor: Colors.white,
          // foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'Kimbwetani',
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
                          'Join Group',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      // PopupMenuItem(
                      //   value: 1,
                      //   child: Text(
                      //     'Report',
                      //     style: TextStyle(fontSize: 14),
                      //   ),
                      // ),
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
          Text(
            "Created Groups",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: my_group_Component()),
          Text(
            "Joined Groups",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: join_group_Component()),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          _add_Group_Dialog(context);
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _join_Group_Dialog(context);
        // createAlertDialog_ChoosePDF(context);
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => SocialDashboardScreen()));
        break;

      case 1:
        _logoutDialog(context);
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

  my_group_Component() {
    if (my_group_data == null) {
      // print(my_group_data);
      // print("---------------------");
      return Center(
        child: Text('No Network or Connection...'),
      );
    } else if (my_group_data != null && my_group_data?.length == 0) {
      // No Data
      return Text('No Data or No Group yet...');
    } else {
      return ListView.builder(
          // physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: my_group_data!.length,
          //itemCount: ProductModel.items.length,
          itemBuilder: (BuildContext context, int index) {
            // print("iMAGE");
            // print(job_data![index].product_image);

            return Container(
                margin: EdgeInsets.symmetric(vertical: 25),
                height: 160,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyGroupScreen(
                                my_group_data![index].id,
                                my_group_data![index].name,
                                my_group_data![index].code,
                                my_group_data![index].description,
                                my_group_data![index].created_at,
                              )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      child:
                                          Image.asset('assets/group_logo.png'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      my_group_data![index].name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // widget.job.isMark = !widget.job.isMark;
                                      // if(selected = true)
                                      //   selected=false;
                                    });
                                  },
                                  child: Container(
                                      child:
                                          Icon(Icons.bookmark_outline_sharp)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'The code to join the group is ${my_group_data![index].code}',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            // SizedBox(height: 15),
                          ],
                        ),
                      ),
                    )));
          });
    }
  }

  join_group_Component() {
    print("----------------");
    print(join_group_data!.length);
    if (join_group_data == null) {
      return Center(
        child: Text('No Network or Connection...'),
      );
    } else if (join_group_data != null && join_group_data?.length == 0) {
      // No Data
      return Text('No Data or No Group yet...');
    } else {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: join_group_data!.length,
          //itemCount: ProductModel.items.length,
          itemBuilder: (BuildContext context, int index) {
            // print("iMAGE");
            // print(job_data![index].product_image);

            return Container(
                margin: EdgeInsets.symmetric(vertical: 25),
                height: 160,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyGroupScreen(
                                my_group_data![index].id,
                                my_group_data![index].name,
                                my_group_data![index].code,
                                my_group_data![index].description,
                                my_group_data![index].created_at,
                              )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      child:
                                          Image.asset('assets/group_logo.png'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      join_group_data![index].name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // widget.job.isMark = !widget.job.isMark;
                                      // if(selected = true)
                                      //   selected=false;
                                    });
                                  },
                                  child: Container(
                                      child:
                                          Icon(Icons.bookmark_outline_sharp)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'The code to join the group is ${my_group_data![index].code}',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            // SizedBox(height: 15),
                          ],
                        ),
                      ),
                    )));
          });
    }
  }
}

class MyGroup_Item {
  final String id, name, code, description, created_at;

  MyGroup_Item(
    this.id,
    this.name,
    this.code,
    this.description,
    this.created_at,
  );
}

class JoinGroup_Item {
  final String id, name, code, description, created_at;

  JoinGroup_Item(
    this.id,
    this.name,
    this.code,
    this.description,
    this.created_at,
  );
}
