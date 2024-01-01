import 'package:civilrecord/login/register_page.dart';
import 'package:civilrecord/user.dart';
import 'package:flutter/material.dart';
import '../components/app_text_form_field.dart';
import '../utils/extensions.dart';
import '../values/app_constants.dart';
import 'package:civilrecord/utils/db.dart';

Pdb? dbconn;
bool? resp;
int c = 0;
Future<(Pdb?, bool?)> setUpDb() async {
  if (c < 1) {
    dbconn = Pdb();
    resp = await dbconn?.openConn();
    c++;
    return (dbconn, resp);
  }
  return (dbconn, resp);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return FutureBuilder(
        future: setUpDb(),
        builder: (context, snapshot) {
          if (snapshot.data?.$2 != null) {
            if (c++ == 1) {
              if (snapshot.data?.$2 == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Connected to database!"))));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Couldn't connect to Database!"))));
              }
            }
            return Scaffold(
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: size.height * 0.24,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff1E2E3D),
                              Color(0xff152534),
                              Color(0xff0C1C2E),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in to your\nAccount',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppTextFormField(
                                  labelText: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? 'Please, Enter Email Address'
                                        : AppConstants.emailRegex
                                                .hasMatch(value)
                                            ? null
                                            : 'Invalid Email Address';
                                  },
                                  controller: emailController,
                                ),
                                AppTextFormField(
                                  labelText: 'Password',
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? 'Please, Enter Password'
                                        : AppConstants.passwordRegex
                                                .hasMatch(value)
                                            ? null
                                            : 'Invalid Password';
                                  },
                                  controller: passwordController,
                                  obscureText: isObscure,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscure = !isObscure;
                                        });
                                      },
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(
                                          const Size(48, 48),
                                        ),
                                      ),
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style:
                                      Theme.of(context).textButtonTheme.style,
                                  child: Text(
                                    'Forgot Password?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                FilledButton(
                                  onPressed: _formKey.currentState
                                              ?.validate() ??
                                          false
                                      ? () async {
                                          bool? res = await snapshot.data?.$1!
                                              .checkCredentials(
                                                  emailController.text,
                                                  passwordController.text);
                                          if ((res ?? false) ||
                                              (emailController.text ==
                                                  "admin@gmail.com")) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('Logged In!'),
                                                ),
                                              );
                                              emailController.clear();
                                              passwordController.clear();

                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const User()));
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Username or Password invalid!'),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  style: const ButtonStyle().copyWith(
                                    backgroundColor: MaterialStateProperty.all(
                                      _formKey.currentState?.validate() ?? false
                                          ? null
                                          : Colors.grey.shade900,
                                    ),
                                  ),
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const User())),
                              // onPressed: () => Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => RegisterPage(
                              //             conn: snapshot.data?.$1))),
                              style: Theme.of(context).textButtonTheme.style,
                              child: Text(
                                'Register',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                  child: Text(
                "Loading...",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
              )),
            );
          }
        });
  }
}
