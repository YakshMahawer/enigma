import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:app_androids/login_screen.dart';
import 'package:app_androids/reusable_widgets.dart';
import 'package:app_androids/update_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class MyHomePage extends StatefulWidget {
   MyHomePage(this.title, this.userDetails, {Key? key}) : super(key: key);
   Map<String, dynamic> userDetails;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  _MyHomePageState(){
    defaultValue = categoryList[0];
    defaultValueVeg = vegNonvegList[0];
    defaultValueStat = statusList[0];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFilter.addListener(() => change);
  }
  @override
  TextEditingController _foodnameTextController = TextEditingController();
  TextEditingController _priceTextController = TextEditingController();
  TextEditingController _ingredientsTextController = TextEditingController();
  TextEditingController _tagsTextController = TextEditingController();
  final searchFilter = TextEditingController();

  late final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..addListener(() {
    setState(() {

    });
  });
  late final animation = Tween(begin: 800.0, end: 100.0).animate(CurvedAnimation(parent: controller, curve: Curves.ease));

  List<String>  array = [];
  final categoryList = ["Pizza", "Burger", "Gujarati", "Punjabi", "South", "Baked", "Dessert", "Drinks"];
  final vegNonvegList = ["veg", "nonveg"];
  final statusList = ["ON", "OFF"];
  String defaultItemName = "";
  String defaultItemPrice = "";
  String defaultValue = "";
  String defaultValueVeg = "";
  String defaultIngredients = "";
  String defaultItemTag = "";
  String defaultValueStat = "";
  String defaultURL = "";
  String selectedCat = "All Items";
  bool success = false;
  String message = "";

  change(String val){
    searchFilter.text = val;
    setState(() {

    });

  }


  createItem() async{
    if(defaultURL.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Image")));
    }
    DocumentReference documentReference = FirebaseFirestore.instance.collection("items").doc();
    Map<String, String> itemList = {
      "category": defaultValue,
      "ingredients": defaultIngredients,
      "name": defaultItemName,
      "price": defaultItemPrice,
      "status": defaultValueStat,
      "tags": defaultItemTag,
      "type": defaultValueVeg,
      "url": defaultURL
    };
    documentReference.set(itemList);
    print(widget.userDetails["doc_id"]);
    DocumentReference userReference = FirebaseFirestore.instance.collection('userInfo').doc(widget.userDetails["doc_id"]);
    userReference.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        if(data["restaurant_categories"].containsKey(defaultValue)){
          userReference.set({
            'restaurant_categories': {
              defaultValue: FieldValue.increment(1),
            }
          }, SetOptions(merge: true));
        }
        else{
          userReference.set({
            'restaurant_categories': {
              defaultValue: 1,
            }
          }, SetOptions(merge: true));
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
    
  }

  deleteItem(itemid, String category){
    DocumentReference documentReference = FirebaseFirestore.instance.collection("items").doc(itemid);
    DocumentReference userReference = FirebaseFirestore.instance.collection('userInfo').doc(widget.userDetails["doc_id"]);
          userReference.get().then(
                (DocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>;
              if((data["restaurant_categories"][category] - 1) == 0){
                userReference.set({
                  'restaurant_categories': {
                    category: FieldValue.delete(),
                  }
                }, SetOptions(merge: true));
              }
              else{
                userReference.set({
                  'restaurant_categories': {
                    category: FieldValue.increment(-1),
                  }
                }, SetOptions(merge: true));
              }
            },
            onError: (e) => print("Error getting document: $e"),
          );
    documentReference.delete();
  }


  changeItemState(item){
    DocumentReference documentReference = FirebaseFirestore.instance.collection("items").doc(item["doc_id"]);

    Map<String, String> changeStateList;
    if(item["status"] == "ON"){
      changeStateList = {
        "status": "OFF"
      };
    }
    else{
      changeStateList = {
        "status": "ON"
      };
    }

    documentReference.update(changeStateList);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(widget.userDetails["restaurant_name"]),
        actions: [
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut().then((value){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              });
            }, icon: Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if(success)
                successPage(message),
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  height: 0,
                  child: TextFormField(
                    controller: searchFilter,
                    onChanged: (dynamic val){
                      print("Changed");
                      setState(() {

                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              filters(),
              SizedBox(
                height: 10,
              ),
              Text(selectedCat, style: TextStyle(fontSize: 20, fontFamily: 'Ubuntu', fontWeight: FontWeight.w700, letterSpacing: 2),),
              SizedBox(
                height: 10,
              ),
              items()
            ],
          ),
          addContainer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          controller.forward();
          setState(() {
            defaultItemName = "";
            defaultItemPrice = "";
            defaultIngredients = "";
            defaultItemTag = "";
            defaultValue = categoryList[0];
            defaultValueVeg = vegNonvegList[0];
            defaultValueStat = statusList[0];
          });
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
  SizedBox filters(){
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('userInfo').doc(widget.userDetails["doc_id"]).snapshots(),
          builder: (context,snapshot) {
            if(!snapshot.hasData){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
                  var result = snapshot.data!['restaurant_categories'];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            TextButton(onPressed: (){
                              change("All");
                              setState(() {
                                selectedCat = "All Items";
                              });
                            },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white60),

                      ),
                      child: CircleAvatar(
                              radius: 31.2,
                              backgroundColor: Colors.pink,
                              child: CircleAvatar(
                                  radius: 30.2,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                  backgroundImage: AssetImage("assets/images/all.jpg"),
                                  radius: 25,
                                ),
                            ),
                            ),
                            ),
                            Container(
                                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                child: const Text("All", style: TextStyle(fontSize: 12, fontFamily: 'Ubuntu'),)),
                          ],
                        ),
                        Column(
                          children: [
                          TextButton(onPressed: (){
                          print("Pressed");
                          setState(() {
                            selectedCat = "Recommended Items";
                          });
                          },
                          style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white60),

                          ),
                          child: CircleAvatar(
                            radius: 31.2,
                            backgroundColor: Colors.pink,
                            child: CircleAvatar(
                              radius: 30.2,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                backgroundImage: AssetImage("assets/images/rec.jpg"),
                                radius: 25,
                              ),
                            ),
                          ),
                          ),
                            Container(
                                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                child: const Text("Recommended", style: TextStyle(fontSize: 12, fontFamily: 'Ubuntu'),)),
                          ],
                        ),

                        for (var res in result.entries)
                        Column(
                          children: [
                          TextButton(onPressed: (){
                            setState(() {
                              selectedCat = res.key;
                            });
                            change(res.key);
                              },
                              style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white60),

                              ),
                              child:CircleAvatar(
                                radius: 31.2,
                                backgroundColor: Colors.pink,
                                child: CircleAvatar(
                                  radius: 30.2,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    backgroundImage: (res.key == 'Gujarati')? AssetImage("assets/images/Gujarati.png") : (res.key == 'Burger')? AssetImage("assets/images/Burger.jpg"): (res.key == 'Drinks')? AssetImage("assets/images/drinks.jpg"): (res.key == 'Punjabi')? AssetImage("assets/images/punjabi.jpg"): (res.key == 'South')? AssetImage("assets/images/dosa.jpg"): (res.key == 'Baked')? AssetImage("assets/images/baked.jpg"): (res.key == 'Dessert')? AssetImage("assets/images/ice.png"): AssetImage("assets/images/Pizza.png"),
                                    radius: 25,
                                  ),
                                ),
                              ),
                          ),
                            Container(
                                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                child: Text(res.key, style: const TextStyle(fontSize: 12, fontFamily: 'Ubuntu'),)),
                          ],
                        ),
                        const SizedBox(
                          width: 12,
                        )
                      ],
                    ),
                  );
          }
        )
        ),
      );
  }

  Container items(){
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("items").snapshots(),
        builder: (context, snapshots){
          if(snapshots.hasError){
            return const Text("Error");
          }
          else if(snapshots.hasData || snapshots.data != null) {
            return Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    QueryDocumentSnapshot<Object?>? documentSnapshot = snapshots
                        .data?.docs[index];
                    final cat = documentSnapshot!["category"];
                    if(searchFilter.text.isEmpty || searchFilter.text.toString() == "All"){
                      return Card(
                        elevation: 10,
                        shadowColor: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            children: [
                              SizedBox(
                                  height: 150,
                                  width: 100,
                                  child: Image.network(documentSnapshot["url"])),
                              const SizedBox(
                                height: 7.5, // <-- SEE HERE
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((documentSnapshot != null) ? (documentSnapshot!["name"]): "", style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.bold),),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Row(
                                    children: [
                                      Text('\u{20B9} ${(documentSnapshot != null) ? (documentSnapshot!["price"]): ""}',
                                          style: const TextStyle(
                                              fontSize: 12, fontFamily: 'Ubuntu')),
                                      const SizedBox(
                                        width: 7.5, // <-- SEE HERE
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            border: Border.all(
                                              color: Colors.redAccent,
                                            ),
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(20))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text((documentSnapshot != null) ? (documentSnapshot!["tags"]): "",
                                              style: const TextStyle(fontSize: 10,
                                                  fontFamily: 'Ubuntu',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  const Text("Ingredients : ", style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Ubuntu',
                                      color: Colors.black54)),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Container(
                                      width: 160,
                                      child: Text((documentSnapshot != null) ? (documentSnapshot!["ingredients"]): "",
                                          style: const TextStyle(fontSize: 12,
                                              fontFamily: 'Ubuntu',
                                              color: Colors.black))),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Row(
                                      children: [
                                        const Text("Current State : ", style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Ubuntu',
                                            color: Colors.black)),
                                        Text((documentSnapshot != null) ? (documentSnapshot!["status"]): "",
                                            style: TextStyle(fontSize: 12,
                                                fontFamily: 'Ubuntu',
                                                color: (documentSnapshot!["status"] == "ON")? Colors.green: Colors.red))
                                      ]
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 7.5, // <-- SEE HERE
                              ),
                              Wrap(

                                children: [
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        Map<String, dynamic> itemData = documentSnapshot?.data() as Map<String, dynamic>;
                                        itemData["doc_id"] = documentSnapshot?.id;
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => UpdateScreen(itemData, widget.userDetails))
                                        );
                                      },
                                      icon: const Icon( // <-- Icon
                                        Icons.create,
                                        size: 24.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        Map<String, dynamic> itemData = documentSnapshot?.data() as Map<String, dynamic>;
                                        itemData["doc_id"] = documentSnapshot?.id;
                                        changeItemState(itemData);
                                        setState(() {
                                          success = true;
                                          if(itemData["status"] == "ON"){
                                            message = "Changed State To OFF";
                                          }
                                          else{
                                            message = "Changed State To ON";
                                          }
                                        });
                                        Timer timer = Timer(const Duration(seconds: 3), () {
                                          setState(() {
                                            success = false;
                                          });
                                        });
                                      },
                                      icon: const Icon( // <-- Icon
                                        Icons.autorenew_rounded,
                                        size: 24.0,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(context: context, builder: (BuildContext builder){
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            content: Container(
                                              height: 100,
                                              width: 600,
                                              child: Column(
                                                children: [
                                                  const Text("Are you sure to delete ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Ubuntu'),),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      ElevatedButton(style: ButtonStyle(
                                                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)
                                                      ),onPressed: (){
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                      }, child: const Text("Cancel", style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.white),)),

                                                      ElevatedButton(style: ButtonStyle(
                                                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.lightGreen)
                                                      ),onPressed: (){
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                        setState(() {
                                                          deleteItem(documentSnapshot.id, documentSnapshot!["category"]);
                                                          success = true;
                                                          message = "Item Deleted Succesfully";
                                                        });
                                                        Timer timer = Timer(const Duration(seconds: 3), () {
                                                          setState(() {
                                                            success = false;
                                                          });
                                                        });

                                                      }, child: const Text("Yes", style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.white),)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });

                                      },
                                      icon: Icon( // <-- Icon
                                        Icons.delete,
                                        size: 24.0,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    else if(cat.toLowerCase().contains(searchFilter.text.toLowerCase().toLowerCase())){
                      return Card(
                        elevation: 10,
                        shadowColor: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            children: [
                              SizedBox(
                                  height: 150,
                                  width: 100,
                                  child: Image.network(documentSnapshot["url"])),
                              const SizedBox(
                                height: 7.5, // <-- SEE HERE
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((documentSnapshot != null) ? (documentSnapshot!["name"]): "", style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.bold),),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Row(
                                    children: [
                                      Text('\u{20B9} ${(documentSnapshot != null) ? (documentSnapshot!["price"]): ""}',
                                          style: const TextStyle(
                                              fontSize: 12, fontFamily: 'Ubuntu')),
                                      const SizedBox(
                                        width: 7.5, // <-- SEE HERE
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: (documentSnapshot!["tags"] != '')? Colors.redAccent: Colors.white,
                                            border: Border.all(
                                              color: (documentSnapshot!["tags"] != '')? Colors.redAccent: Colors.white,
                                            ),
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(20))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text((documentSnapshot != null) ? (documentSnapshot!["tags"]): "",
                                              style: const TextStyle(fontSize: 10,
                                                  fontFamily: 'Ubuntu',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  const Text("Ingredients : ", style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Ubuntu',
                                      color: Colors.black54)),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Container(
                                      width: 160,
                                      child: Text((documentSnapshot != null) ? (documentSnapshot!["ingredients"]): "",
                                          style: const TextStyle(fontSize: 12,
                                              fontFamily: 'Ubuntu',
                                              color: Colors.black))),
                                  const SizedBox(
                                    height: 7.5, // <-- SEE HERE
                                  ),
                                  Row(
                                      children: [
                                        const Text("Current State : ", style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Ubuntu',
                                            color: Colors.black)),
                                        Text((documentSnapshot != null) ? (documentSnapshot!["status"]): "",
                                            style: TextStyle(fontSize: 12,
                                                fontFamily: 'Ubuntu',
                                                color: (documentSnapshot!["status"] == "ON")? Colors.green: Colors.red))
                                      ]
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 7.5, // <-- SEE HERE
                              ),
                              Wrap(

                                children: [
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        Map<String, dynamic> itemData = documentSnapshot?.data() as Map<String, dynamic>;
                                        itemData["doc_id"] = documentSnapshot?.id;
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => UpdateScreen(itemData, widget.userDetails))
                                        );
                                      },
                                      icon: const Icon( // <-- Icon
                                        Icons.create,
                                        size: 24.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        Map<String, dynamic> itemData = documentSnapshot?.data() as Map<String, dynamic>;
                                        itemData["doc_id"] = documentSnapshot?.id;
                                        changeItemState(itemData);
                                        setState(() {
                                          success = true;
                                          if(itemData["status"] == "ON"){
                                            message = "Changed State To OFF";
                                          }
                                          else{
                                            message = "Changed State To ON";
                                          }
                                        });
                                        Timer timer = Timer(const Duration(seconds: 3), () {
                                          setState(() {
                                            success = false;
                                          });
                                        });
                                      },
                                      icon: const Icon( // <-- Icon
                                        Icons.autorenew_rounded,
                                        size: 24.0,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(context: context, builder: (BuildContext builder){
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            content: Container(
                                              height: 100,
                                              width: 600,
                                              child: Column(
                                                children: [
                                                  const Text("Are you sure to delete ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Ubuntu'),),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      ElevatedButton(style: ButtonStyle(
                                                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)
                                                      ),onPressed: (){}, child: const Text("Cancel", style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.white),)),

                                                      ElevatedButton(style: ButtonStyle(
                                                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.lightGreen)
                                                      ),onPressed: (){
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                        setState(() {
                                                          deleteItem(documentSnapshot.id, documentSnapshot!["category"]);
                                                          success = true;
                                                          message = "Item Deleted Succesfully";
                                                        });
                                                        Timer timer = Timer(const Duration(seconds: 3), () {
                                                          setState(() {
                                                            success = false;
                                                          });
                                                        });
                                                      }, child: const Text("Yes", style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.white),)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });

                                      },
                                      icon: Icon( // <-- Icon
                                        Icons.delete,
                                        size: 24.0,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    else{
                      return Container(
                      );
                    }
                  }
              ),
            );
          }
          return const Text("");
        },
      ),
    );
  }

  Positioned addContainer(){
    return Positioned(
      top: animation.value,
      right: 0,
      left: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0), topRight: Radius.circular(75.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 25.0),
          child: Column(
            children: [
                  ClipOval(
                    child: Material(
                      color: Colors.pink,
                      child: InkWell(
                        splashColor: Colors.black,
                        onTap: () {
                          controller.reverse();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.close_rounded, color: Colors.white,), // <-- Icon
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text("Add new item", style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          reusableTextField("Enter Item Name", Icons.fastfood, false, _foodnameTextController, Colors.redAccent,(String value){
                            defaultItemName = value;
                          }),
                          const SizedBox(
                            height: 15,
                          ),
                          reusableTextField("Enter Item Price", Icons.currency_rupee, false, _priceTextController, Colors.redAccent, (String value){
                            defaultItemPrice = value;
                          }),
                          const SizedBox(
                            height: 15,
                          ),
                          DropdownButtonFormField(
                            value: defaultValue,
                            items: categoryList.map(
                                    (e) => DropdownMenuItem(child: Text(e, style: const TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                            ).toList(),
                            onChanged: (val) {
                              setState((){
                                defaultValue = val as String;
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                            decoration: InputDecoration(
                                labelText: "Select Category",
                                prefixIcon: const Icon(Icons.category, color: Colors.redAccent,),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DropdownButtonFormField(
                            value: defaultValueVeg,
                            items: vegNonvegList.map(
                                    (e) => DropdownMenuItem(child: Text(e, style: const TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                            ).toList(),
                            onChanged: (val) {
                              setState((){
                                defaultValueVeg = val as String;
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                            decoration: InputDecoration(
                                labelText: "Select Food-Type",
                                prefixIcon: const Icon(Icons.flatware, color: Colors.redAccent,),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          reusableTextField("Enter Ingredients", Icons.emoji_objects, false, _ingredientsTextController, Colors.redAccent,(String value){
                            defaultIngredients = value;
                          }),
                          const SizedBox(
                            height: 15,
                          ),
                          reusableTextField("Add Any Tag", Icons.label, false, _tagsTextController, Colors.redAccent, (String value){
                            defaultItemTag = value;
                          }),
                          const SizedBox(
                            height: 15,
                          ),
                          DropdownButtonFormField(
                            value: defaultValueStat,
                            items: statusList.map(
                                    (e) => DropdownMenuItem(child: Text(e, style: const TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                            ).toList(),
                            onChanged: (val) {
                              setState((){
                                defaultValueStat = val as String;
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                            decoration: InputDecoration(
                                labelText: "Set Status",
                                prefixIcon: const Icon(Icons.flag, color: Colors.redAccent,),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            [
                              OtherButtons("Upload Item Image", () async{
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                                Reference referenceRoot = FirebaseStorage.instance.ref();
                                Reference referenceDirImage = referenceRoot.child('images');

                                Reference referenceImageToUpload = referenceDirImage.child('${file?.name}');
                                await referenceImageToUpload.putFile(File(file!.path));
                                String url = await referenceImageToUpload.getDownloadURL();
                                setState(() {
                                  defaultURL = url;
                                });
                            }, 105, Colors.redAccent, Colors.red),
                              if(defaultURL != "")
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    child: Text(""),
                                  ),
                                )
                            ]
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          OtherButtons("ADD", (){

                            controller.reverse();
                            createItem();
                            setState(() {
                              success = true;
                              message = "Item Added Succesfully";
                            });
                            Timer timer = Timer(const Duration(seconds: 3), () {
                              setState(() {
                                success = false;
                              });
                            });
                          }, 0, Colors.black, Colors.black54)
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Container successPage(String mes){
    return Container(
        color: Colors.white,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 8.0, 8.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset("assets/images/tick.gif",),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: Text("$mes", style: TextStyle(fontFamily: 'Ubuntu', fontSize: 16, color: Colors.indigo[900]),))
            ],
          ),
        )
    );
  }
}

