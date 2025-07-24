import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:register_user/models/user_model.dart';

class Registerscreen extends StatefulWidget {

  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  static var _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

     String? validatePassword(String? value) {
      final password = value ?? '';
      final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');

      if (password.isEmpty) {
        return "Password is required";
      } else if (!regex.hasMatch(password)) {
        return "Password must be at least 8 characters, \ninclude upper & lower case letters, \n number, and a special character.";
      }
      return null;
     }


  void _submitForm() async {

      UserModel newUser = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        await FirebaseFirestore.instance.collection('users')

        .add(newUser.toMap());

        print("User Registered Successfully");
      } catch (err) {
        print("Failed to add new user to database");
      }

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text("Register Form", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              Container(
                child: Form(
                  key: _formKey,

          child: Column(
          children: [
            TextFormField(
              controller: _nameController,

              decoration: InputDecoration(
                hintText: "Enter name",
              ),

              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please fill this field";
                } 
                return null;
              },

            ),

              SizedBox(),

            TextFormField(
              controller: _emailController,

              decoration: InputDecoration(
                hintText: "Enter email",
              ),

               validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please fill this field";
                } else if(!val.contains('@')) {
                  return "Email field must contain @ sign";
                }
                return null;
              },

            ),

            TextFormField(
              obscureText: true,
              controller: _passwordController,

              decoration: InputDecoration(
                hintText: "Enter password",
                // border: InputBorder.none
              ),

               validator: validatePassword,

            ),
            FlutterPwValidator(
                controller: _passwordController,
                minLength: 8,
                uppercaseCharCount: 1,
                lowercaseCharCount: 1,
                numericCharCount: 1,
                specialCharCount: 1,
                width: 400,
                height: 200,
                onSuccess: () => print("Password is strong!"),
                onFail: () => print("Password is weak!"),
              ),


            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){

              if (_formKey.currentState?.validate() ?? true) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User registered successfully"),
                backgroundColor: const Color.fromARGB(255, 69, 200, 73),));

                  _submitForm();

              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all the required fields."),
                backgroundColor: const Color.fromARGB(255, 233, 33, 19),));
              }
            }, child: Text("Submit"))
          ],
        )
        ),
              )
            ],
          )
           
      )
      
      
    );
  }
}