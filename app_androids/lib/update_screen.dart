import 'package:flutter/material.dart';
import 'package:app_androids/home_screen.dart';
import 'package:app_androids/login_screen.dart';
import 'package:app_androids/reusable_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateScreen extends StatefulWidget {
  Map<String, dynamic> itemInfo;
  Map<String, dynamic> userDetails;
  UpdateScreen(this.itemInfo,this.userDetails, {Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override

  late TextEditingController _foodnameTextController;
  late TextEditingController _priceTextController;
  late TextEditingController _ingredientsTextController;
  late TextEditingController _tagsTextController;

  final categoryList = ["Pizza", "Burger", "Gujarati", "Punjabi", "South", "Baked", "Dessert", "Drinks"];
  final vegNonvegList = ["veg", "nonveg"];
  final statusList = ["ON", "OFF"];
  String category = "";
  String type = "";
  String status = "";
  String defaultItemName = "";
  String defaultItemPrice = "";
  String defaultIngredients = "";
  String defaultItemTag = "";

  void initState() {
    // TODO: implement initState
    super.initState();
    _foodnameTextController = TextEditingController(text: widget.itemInfo["name"]);
    _priceTextController = TextEditingController(text: widget.itemInfo["price"]);
    _ingredientsTextController = TextEditingController(text: widget.itemInfo["ingredients"]);
    _tagsTextController = TextEditingController(text: widget.itemInfo["tags"]);
    category = widget.itemInfo["category"];
    type = widget.itemInfo["type"];
    status = widget.itemInfo["status"];
  }

  updateItem(){
    DocumentReference documentReference = FirebaseFirestore.instance.collection("items").doc(widget.itemInfo["doc_id"]);
    Map<String, String> updateList = {
      "category": category,
      "ingredients": _ingredientsTextController.text,
      "name": _foodnameTextController.text,
      "price": _priceTextController.text,
      "status": status,
      "tags": _tagsTextController.text,
      "type": type
    };

    documentReference.update(updateList);


  }


  setCategory(String category, String new_category){
    DocumentReference userReference = FirebaseFirestore.instance.collection('userInfo').doc(widget.userDetails["doc_id"]);
          if(category != new_category){
            print(widget.userDetails["doc_id"]);
            userReference.set({
              'restaurant_categories': {
                category: FieldValue.increment(-1),
              }
            }, SetOptions(merge: true));


            userReference.get().then(
                  (DocumentSnapshot udoc) {
                final udata = udoc.data() as Map<String, dynamic>;
                if(udata["restaurant_categories"].containsKey(category)){
                  userReference.set({
                    'restaurant_categories': {
                      new_category: FieldValue.increment(1),
                    }
                  }, SetOptions(merge: true));
                }
                else{
                  userReference.set({
                    'restaurant_categories': {
                      new_category: 1,
                    }
                  }, SetOptions(merge: true));
                }

                if(udata["restaurant_categories"][category] == 0){
                  userReference.set({
                    'restaurant_categories': {
                      category: FieldValue.delete(),
                    }
                  }, SetOptions(merge: true));
                }
              },
              onError: (e) => print("Error getting document: $e"),
            );
          }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemInfo["name"]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Text("Item Information", style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 25,
              ),
              reusableTextField("Enter Item Name", Icons.fastfood, false, _foodnameTextController, Colors.redAccent,(String value){
                defaultItemName = value;
              }),
              SizedBox(
                height: 15,
              ),
              reusableTextField("Enter Item Price", Icons.currency_rupee, false, _priceTextController, Colors.redAccent, (String value){
                defaultItemPrice = value;
              }),
              SizedBox(
                height: 15,
              ),
              DropdownButtonFormField(
                value: category,
                items: categoryList.map(
                        (e) => DropdownMenuItem(child: Text(e, style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                ).toList(),
                onChanged: (val) {
                  setCategory(category, val as String);
                  setState((){
                    category = val as String;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                decoration: InputDecoration(
                    labelText: "Select Category",
                    prefixIcon: Icon(Icons.category, color: Colors.redAccent,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                ),
              ),
              SizedBox(
                height: 15,
              ),
              DropdownButtonFormField(
                value: type,
                items: vegNonvegList.map(
                        (e) => DropdownMenuItem(child: Text(e, style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                ).toList(),
                onChanged: (val) {
                  setState((){
                    type = val as String;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                decoration: InputDecoration(
                    labelText: "Select Food-Type",
                    prefixIcon: Icon(Icons.flatware, color: Colors.redAccent,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                ),
              ),
              SizedBox(
                height: 15,
              ),
              reusableTextField("Enter Ingredients", Icons.emoji_objects, false, _ingredientsTextController, Colors.redAccent,(String value){
                defaultIngredients = value;
              }),
              SizedBox(
                height: 15,
              ),
              reusableTextField("Add Any Tag", Icons.label, false, _tagsTextController, Colors.redAccent, (String value){
                defaultItemTag = value;
              }),
              SizedBox(
                height: 15,
              ),
              DropdownButtonFormField(
                value: status,
                items: statusList.map(
                        (e) => DropdownMenuItem(child: Text(e, style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu', color: Colors.black)), value: e)
                ).toList(),
                onChanged: (val) {
                  setState((){
                    status = val as String;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.redAccent,),
                decoration: InputDecoration(
                    labelText: "Set Status",
                    prefixIcon: Icon(Icons.flag, color: Colors.redAccent,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
                ),
              ),
              SizedBox(
                height: 15,
              ),
              OtherButtons("Change Item Image", (){}, 105, Colors.redAccent, Colors.red),
              SizedBox(
                height: 15,
              ),
              OtherButtons("UPDATE", (){
                updateItem();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage('',widget.userDetails))
                );
              }, 0, Colors.black, Colors.black54)
            ],

          ),
        ),
      ),
    );
  }
}
