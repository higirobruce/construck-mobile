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
  var snackBar = SnackBar(
      backgroundColor: Colors.amber,
      content: Text(
        "Ntibikunze, telephone n'ijambo ry'ibanga ntibuhura.",
        style: TextStyle(color: Colors.black),
      ));
  // Create storage
  final storage = new FlutterSecureStorage();
  String _id = '';
  String userId = '';
  String userName = '';
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

    if (_savedId != null &&
        _savedUsername != null &&
        _savedUserId != null &&
        _savedId.isNotEmpty &&
        _savedUsername.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainScreen(_savedId, _savedUsername, _savedUserId),
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
            await storage.write(key: '_id', value: _id),
            await storage.write(key: 'userName', value: userName),
            await storage.write(key: 'userId', value: userId),
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(_id, userName, userId),
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
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Telephone',
                            style: TextStyle(
                                color: Colors.blueGrey, fontSize: 16.0),
                          ),
                          TextFormField(
                            controller: usernameController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Andika izina cyangwa telephone';
                              }
                              return null;
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              "ijambo ry'ibanga",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 16.0),
                            ),
                          ),
                          TextFormField(
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
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: !submitting
                                ? ElevatedButton(
                                    onPressed: () {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      if (_formKey.currentState!.validate()) {
                                        // If the form is valid, display a snackbar. In the real world,
                                        // you'd often call a server or save the information in a database.
                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(
                                        //       content: Text('Processing Data')),
                                        // );

                                        login(context, usernameController.text,
                                            passwordController.text);
                                      }
                                    },
                                    child: const Text('OHEREZA'),
                                  )
                                : Text('Ihangane....'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
