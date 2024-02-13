import 'dart:ui';

import 'package:city_riders/firebase_options.dart';
import 'package:city_riders/user_info_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instanceFor(app: Firebase.app());
  final db = FirebaseFirestore.instance;

  try {
    String email = "toto@gmail.com";
    String password = "toto@mossi";
    final credential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    print(
        '======================================================================================================');
    print(
        '======================================================================================================');
    print('credential = ${credential}');
    print(
        '======================================================================================================');
    print(
        '======================================================================================================');
  } catch (e) {
    print(e);
  }
  /*
  */

  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: "/login",
  routes: [
    GoRoute(
      name: "login",
      path: "/login",
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      name: "register",
      path: "/register",
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      name: "home",
      path: "/",
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      name: "error",
      path: "/error",
      builder: (context, state) => const Text("Error Page"),
    ),
    GoRoute(
      name: "register-driver-info",
      path: "/register-driver-info",
      builder: (context, state) => RegistrationDriver(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: MaterialApp.router(
        routerConfig: _router,
        title: "City Rider",
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      ),
    );
    /*
    return MaterialApp(
        title: 'Hierarchy Topmost level',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        // home: Text('Hello world'),
        home: LoginScreen());
    */
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(11.5, -3.9),
          initialZoom: 6.00,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.city_riders',
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserCubit? _userCubit;
  BuildContext? _context;

  void login() async {
    var username = usernameController.text;
    var password = passwordController.text;
    var message = "NOPE";
    var success = false;
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: username, password: password);

      success = true;
      message = "Login successful";
    } on FirebaseAuthException catch (e) {
      message = e.code;
    } catch (e) {
      message = "An Unexpected Error Occured";
    }

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );

    if (success && credential != null) {
      _userCubit!.setUserAuth(credential.user!);
      _context!.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<UserCubit>().reset();
    _context = context;
    _userCubit = context.watch<UserCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Hello World")),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    // hintText: "Username",
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  child: const Text("Login"),
                  onPressed: login,
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  child: const Text('Need an Account ? Register Now'),
                  onTap: () {
                    context.push('/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  BuildContext? _context;
  UserCubit? userCubit;

  void logVariableError() {
    if (_context == null) {
      print("[ERROR] '_context' = null !");
    }

    if (userCubit == null) {
      print(
          "[ERROR] 'userCubit' = null ! As a consequence, Registration Page won't be able to communication with other App Pages");
    }
  }

  void testMockField() {
    _confirmPasswordController.text = 'melody123';
    _passwordController.text = 'melody123';
    _fullNameController.text = 'melody';
    _emailController.text = 'melody@mail.com';
  }

  void submitUserCredential() async {
    var user = userCubit!;

    // user.setDriverDetails(selectedCarModel, selectedCarLuxuryType);
    var message = "NOPE";
    bool success = false;
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.state.email, password: user.state.password);
      message = "Registration Completed !";
      success = true;
    } on FirebaseAuthException catch (e) {
      message = e.code;
    } catch (e) {
      message = "An Unexpected Error happen";
    }

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message),
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );

    if (success && credential != null) {
      var userInfo = <String, dynamic>{
        'uid': credential.user!.uid,
        'username': user.state.username,
        'is_driver': user.state.isDriver,
      };

      await FirebaseFirestore.instance.collection('users').add(userInfo);
      _context!.go("/login");
    }
  }

  void registerUserDetails() {
    logVariableError();

    var user = userCubit!;
    var input = UserState();

    input.username = _fullNameController.text;
    input.password = _passwordController.text;
    input.email = _emailController.text;
    input.isDriver = user.state.isDriver;

    if (input.username.isEmpty ||
        input.password.isEmpty ||
        input.email.isEmpty) {
      const snackbar = SnackBar(
        content: Center(
          child: Text("Some Fields are empty !"),
        ),
        backgroundColor: Colors.redAccent,
      );

      ScaffoldMessenger.of(_context!).showSnackBar(snackbar);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      const snackbar = SnackBar(
        content: Center(
          child: Text("Password Don't Match"),
        ),
        backgroundColor: Colors.redAccent,
      );

      ScaffoldMessenger.of(_context!).showSnackBar(snackbar);
      return;
    }

    user.setUserRegistrationDetails(input);

    if (user.state.isDriver) {
      _context!.push('/register-driver-info');
      print('[WARNING] Unexpected return from context.push()');
      return;
    }

    submitUserCredential();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    userCubit = context.watch<UserCubit>();

    if (userCubit != null) {
      _fullNameController.text = userCubit!.state.username;
      _emailController.text = userCubit!.state.email;
      _passwordController.text = userCubit!.state.password;
      _confirmPasswordController.text = userCubit!.state.password;
    }

    testMockField();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _fullNameController,
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Email',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 30,
                      child: Text('Register as a Driver ?'),
                    ),
                    MyCheckBox(),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: registerUserDetails,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCheckBox extends StatefulWidget {
  MyCheckBox({super.key});

  @override
  State<MyCheckBox> createState() => MyCheckBoxState();
}

class MyCheckBoxState extends State<MyCheckBox> {
  bool _isUserDriver = false;

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserCubit>();
    _isUserDriver = user.state.isDriver;

    return Checkbox(
      value: _isUserDriver,
      onChanged: (value) {
        setState(() {
          _isUserDriver = value!;
        });
        user.setDriverStatus(_isUserDriver);
        print("checkbox: $_isUserDriver");
      },
    );
  }
}

class RegistrationDriver extends StatefulWidget {
  RegistrationDriver({super.key});

  @override
  RegistrationDriverState createState() => RegistrationDriverState();
}

class RegistrationDriverState extends State<RegistrationDriver> {
  List<String> carModels = <String>[
    'Toyota',
    'Mitsubishi',
    'Ford',
    'Peugeot',
    'Mercedes',
    'Kia',
  ];
  List<String> carLuxuryType = <String>['Average', 'RAV4', 'High Class'];

  String selectedCarModel = "";
  String selectedCarLuxuryType = "";
  BuildContext? _context;
  UserCubit? _userCubit;

  @override
  void initState() {
    super.initState();

    selectedCarModel = carModels.first;
    selectedCarLuxuryType = carLuxuryType.first;
  }

  void submitDriverCredential() async {
    var user = _userCubit!;

    user.setDriverDetails(selectedCarModel, selectedCarLuxuryType);
    var message = "NOPE";
    bool success = false;
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.state.email, password: user.state.password);
      message = "Registration Completed !";
      success = true;
    } on FirebaseAuthException catch (e) {
      message = e.code;
    } catch (e) {
      message = "An Unexpected Error happen";
    }

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message),
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );

    if (success && credential != null) {
      var userInfo = <String, dynamic>{
        'uid': credential.user!.uid,
        'username': user.state.username,
        'is_driver': user.state.isDriver,
        'car_model': user.state.carModel,
        'car_luxury': user.state.carStanding,
      };

      await FirebaseFirestore.instance.collection('users').add(userInfo);
      _context!.go("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _userCubit = context.watch<UserCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text('Car Model'),
                  ),
                  DropdownMenu(
                    initialSelection: selectedCarModel,
                    onSelected: (String? selected) {
                      setState(() {
                        selectedCarModel = selected!;
                      });
                    },
                    dropdownMenuEntries: carModels
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry(value: value, label: value);
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text('Car Standing'),
                  ),
                  DropdownMenu(
                    initialSelection: selectedCarLuxuryType,
                    onSelected: (String? selected) {
                      setState(() {
                        selectedCarLuxuryType = selected!;
                      });
                    },
                    dropdownMenuEntries: carLuxuryType
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry(value: value, label: value);
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: submitDriverCredential,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
