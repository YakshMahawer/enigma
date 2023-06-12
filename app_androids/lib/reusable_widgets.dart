import 'dart:ffi';

import 'package:flutter/material.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller, Color iconColor, Function(String) onChange){
  return(
    TextField(
      controller: controller,
      obscureText: isPasswordType,
      obscuringCharacter: '*',
      onChanged: onChange,
      style: TextStyle(fontFamily: 'Ubuntu'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor,),
        labelText: text,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))
      ),

    )
  );

}

Container SignInSignUpButton(BuildContext context, bool isLogin, Function onTap){
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
    child: ElevatedButton(
      onPressed: (){
        onTap();
    },
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        isLogin ? 'LOG IN ' : ' SIGN UP ',
        style: const TextStyle(fontFamily: 'Ubuntu', color: Colors.white,fontWeight: FontWeight.w400, fontSize: 18),
      ),
    ),
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states)  {
      if (states.contains(MaterialState.pressed)) {
        return Colors.black54;
      }
        return Colors.black;
    }
    ),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
    ),
  );

}

Container OtherButtons(String buttonText, Function onTap, double shift, Color color, Color aftColor){
  return Container(
    margin: EdgeInsets.fromLTRB(0, 0, shift, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
    child: ElevatedButton(
      onPressed: (){
      onTap();
    },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states)  {
              if (states.contains(MaterialState.pressed)) {
                return aftColor;
              }
              return color;
            }
            ),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
    child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text( buttonText,
            style: const TextStyle(fontFamily: 'Ubuntu', color: Colors.white,fontWeight: FontWeight.w400, fontSize: 18),
          ),
        ),
  ),
  );
}




