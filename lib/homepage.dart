import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sql_database_insertion/helpers/database_helpers.dart';

import 'models/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Student>> getAllStudents;

  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? name;
  int? age;
  String? city;
  Uint8List? image;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllStudents = DBHelper.dbHelper.fetchAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("SQLite App"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (val) async {
                    setState(() {
                      getAllStudents =
                          DBHelper.dbHelper.fetchSearchedRecords(data: val);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search name here...",
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 14,
              child: FutureBuilder(
                future: getAllStudents,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    // List<Map<String, dynamic>> data =
                    //     snapshot.data as List<Map<String, dynamic>>;
                    List<Student?> data = snapshot.data as List<Student?>;

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        return Card(
                          elevation: 3,
                          child: ListTile(
                            isThreeLine: true,
                            // leading: Text("${data[i].id}"),
                            leading: CircleAvatar(
                              backgroundImage: MemoryImage(data[i]!.image),
                            ),
                            title: Text("${data[i]!.name}"),
                            subtitle:
                                Text("${data[i]!.city}\n Age:${data[i]!.age}"),
                            trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    int resId =
                                        await DBHelper.dbHelper.updateRecord(
                                      name: 'Het',
                                      age: 18,
                                      city: 'Mumbai',
                                      id: data[i]!.id!,
                                    );

                                    if (resId == 1) {
                                      print("============================");
                                      print("Record updated successfully");
                                      print("============================");

                                      setState(() {
                                        getAllStudents =
                                            DBHelper.dbHelper.fetchAllRecords();
                                      });
                                    } else {
                                      print("============================");
                                      print("Record updation failed");
                                      print("============================");
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Center(
                                          child: Text("Delete Record"),
                                        ),
                                        content: const Text(
                                            "Are you sure to delte this record?"),
                                        actions: [
                                          ElevatedButton(
                                            child: const Text("Delete"),
                                            onPressed: () async {
                                              int resId = await DBHelper
                                                  .dbHelper
                                                  .deleteRecord(
                                                      id: data[i]!.id!);

                                              if (resId == 1) {
                                                print(
                                                    "==================================");
                                                print(
                                                    "Record deleted successfully");
                                                print(
                                                    "==================================");

                                                setState(() {
                                                  getAllStudents = DBHelper
                                                      .dbHelper
                                                      .fetchAllRecords();
                                                });
                                              } else {
                                                print(
                                                    "============================");
                                                print("Record deletion failed");
                                                print(
                                                    "============================");
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                    //Navigator.of(context).pop();
                                  },
                                ),
                                // Text("${data[i]['age']}"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            // int id = await DBHelper.dbHelper.insertRecord();
            // if (id > 0) {
            //   print("----------------------");
            //   print("Record inserted successfully with id of $id");
            //   print("----------------------");
            // } else {
            //   print("----------------------");
            //   print("Record insertion failed");
            //   print("----------------------");
            // }
            validateInsert();
          },
        ));
  }

  validateInsert() {
    showDialog(
        context: (context),
        builder: (context) => AlertDialog(
              title: const Center(
                child: Text("Add Record"),
              ),
              content: Form(
                key: insertFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        XFile? xfile =
                            await picker.pickImage(source: ImageSource.camera);

                        image = await xfile?.readAsBytes();

                        var result =
                            await FlutterImageCompress.compressWithList(
                          image!,
                          minHeight: 250,
                          minWidth: 250,
                          quality: 50,
                          rotate: 135,
                        );
                        image = result;
                      },
                      child: const Text("Pick Image"),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      controller: nameController,
                      validator: (val) {
                        return (val!.isEmpty) ? "Enter name first" : null;
                      },
                      onSaved: (val) {
                        setState(() {
                          name = val;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Age'),
                      controller: ageController,
                      validator: (val) {
                        return (val!.isEmpty) ? "Enter age first" : null;
                      },
                      onSaved: (val) {
                        setState(() {
                          age = int.parse(val!);
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'City'),
                      controller: cityController,
                      validator: (val) {
                        return (val!.isEmpty) ? "Enter city first" : null;
                      },
                      onSaved: (val) {
                        setState(() {
                          city = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      if (insertFormKey.currentState!.validate()) {
                        insertFormKey.currentState!.save();

                        int id = await DBHelper.dbHelper.insertRecord(
                          name: name!,
                          age: age!,
                          city: city!,
                          image: image!,
                        );
                        if (id > 0) {
                          print("----------------------");
                          print("Record inserted successfully with id of $id");
                          print("----------------------");

                          setState(() {
                            getAllStudents =
                                DBHelper.dbHelper.fetchAllRecords();
                          });
                        } else {
                          print("----------------------");
                          print("Record insertion failed");
                          print("----------------------");
                        }
                      }
                      nameController.clear();
                      ageController.clear();
                      cityController.clear();
                      setState(
                        () {
                          name = null;
                          city = null;
                          age = null;
                          image = null;
                        },
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text("Insert")),
                ElevatedButton(
                    onPressed: () {
                      nameController.clear();
                      ageController.clear();
                      cityController.clear();
                      setState(() {
                        name = null;
                        city = null;
                        age = null;
                        image = null;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
              ],
            ));
  }
}
