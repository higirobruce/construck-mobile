// ignore_for_file: prefer_const_constructors

import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/screens/mainScreen.dart';
import 'package:mobile2/screens/success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var snackBar = const SnackBar(
      backgroundColor: Colors.amber,
      content: Text(
        "Ntibikunze, telephone n'ijambo ry'ibanga ntibuhura.",
        style: TextStyle(color: Colors.black),
      ));
  // Create storage
  final storage = const FlutterSecureStorage();
  String _id = '';
  String userId = '';
  String userName = '';
  String userType = '';
  String initials = '';
  String assignedProject = '';
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _saveCreds();
    // Read value
  }

  Future<void> _saveCreds() async {
    String? _savedId = await storage.read(key: '_id');
    String? _savedUserId = await storage.read(key: 'userId');
    String? _savedUsername = await storage.read(key: 'userName');
    String? _savedUserType = await storage.read(key: 'userType');
    String? _savedInitials = await storage.read(key: 'initials');
    String? _savedAssignedProject = await storage.read(key: 'assignedProject');

    if (_savedId != null &&
        _savedUsername != null &&
        _savedUserId != null &&
        _savedId.isNotEmpty &&
        _savedUserType != null &&
        _savedUsername.isNotEmpty &&
        _savedInitials != null &&
        _savedInitials.isNotEmpty &&
        _savedAssignedProject != null &&
        _savedAssignedProject.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
                _savedId,
                _savedUsername,
                _savedUserId,
                _savedUserType,
                _savedInitials,
                _savedAssignedProject),
          ),
          (Route<dynamic> route) => route is Success);
    }
  }

  login(context, username, password) {
    setState(() {
      submitting = true;
    });
    UserApi.login(password, username).then(
      (value) async => {
        if (value['allowed'] == true)
          {
            _id = value['employee']['_id'],
            userId = value['employee']['userId'],
            userName = value['employee']['firstName'] +
                ' ' +
                value['employee']['lastName'],
            userType = value['userType'],
            initials = value['employee']['firstName'][0] +
                value['employee']['lastName'][0],
            assignedProject = value['employee']['assignedProject'],
            await storage.write(key: '_id', value: _id),
            await storage.write(key: 'userName', value: userName),
            await storage.write(key: 'userId', value: userId),
            await storage.write(key: 'userType', value: userType),
            await storage.write(key: 'initials', value: initials),
            await storage.write(key: 'assignedProject', value: assignedProject),
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(_id, userName, userId,
                      userType, initials, assignedProject),
                ),
                (Route<dynamic> route) => route is Success)
          }
        else
          {ScaffoldMessenger.of(context).showSnackBar(snackBar)},
        setState(() {
          submitting = false;
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Shabika App',
                  style: TextStyle(fontSize: 32.0),
                ),
                buildLoginForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextLabel(lable: 'Telephone'),
              CustomInputField(valueController: usernameController),
              addVerticalSpace(),
              CustomTextLabel(lable: 'Ijambo ry\'ibanga'),
              CustomPasswordField(passwordController: passwordController),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: !submitting
                      ? ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login(context, usernameController.text,
                                  passwordController.text);
                            }
                          },
                          child: const Text('OHEREZA'),
                        )
                      : const Text('Ihangane....'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextLabel extends StatelessWidget {
  const CustomTextLabel({
    Key? key,
    required this.lable,
  }) : super(key: key);

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Text(
        lable,
        style: TextStyle(color: Colors.blueGrey, fontSize: 16.0),
      ),
    );
  }
}

SizedBox addVerticalSpace() {
  return const SizedBox(
    height: 20,
  );
}

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    Key? key,
    required this.valueController,
  }) : super(key: key);

  final TextEditingController valueController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: Icon(
              Icons.phone,
              size: 18,
              color: Theme.of(context).accentColor,
            ),
          ),
          controller: valueController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Andika izina cyangwa telephone';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class CustomPasswordField extends StatelessWidget {
  const CustomPasswordField({
    Key? key,
    required this.passwordController,
  }) : super(key: key);

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: Icon(Icons.password),
          ),
          controller: passwordController,
          obscureText: true,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Andika ijambo ry'ibanga";
            }
            return null;
          },
        ),
      ),
    );
  }
}
