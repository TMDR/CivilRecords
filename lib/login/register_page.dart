import 'package:civilrecord/utils/db.dart';
import 'package:flutter/material.dart';
import '../components/app_text_form_field.dart';
import '../utils/extensions.dart';
import '../values/app_colors.dart';
import '../values/app_constants.dart';

class RegisterPage extends StatefulWidget {
  final Pdb? conn;
  const RegisterPage({super.key, required this.conn});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  List<bool> isSelected = [true, false];
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController placeOfBirthController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  bool isObscure = true;
  bool isConfirmPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              height: size.height * 0.24,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightBlue,
                    AppColors.blue,
                    AppColors.darkBlue,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Register',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Create your account',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    labelText: 'First Name',
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Your First Name '
                          : value.length < 4
                              ? 'Invalid Name'
                              : null;
                    },
                    controller: firstnameController,
                  ),
                  AppTextFormField(
                    labelText: 'Last Name',
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Your Last Name '
                          : value.length < 4
                              ? 'Invalid Name'
                              : null;
                    },
                    controller: lastnameController,
                  ),
                  AppTextFormField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Email Address'
                          : AppConstants.emailRegex.hasMatch(value)
                              ? null
                              : 'Invalid Email Address';
                    },
                    controller: emailController,
                  ),
                  AppTextFormField(
                    labelText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Password'
                          : AppConstants.passwordRegex.hasMatch(value)
                              ? null
                              : 'Invalid Password';
                    },
                    controller: passwordController,
                    obscureText: isObscure,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Focus(
                        descendantsAreFocusable: false,
                        child: IconButton(
                          onPressed: () => setState(() {
                            isObscure = !isObscure;
                          }),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                              const Size(48, 48),
                            ),
                          ),
                          icon: Icon(
                            isObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppTextFormField(
                    labelText: 'Confirm Password',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    // focusNode: confirmFocusNode,
                    onChanged: (value) {
                      _formKey.currentState?.validate();
                    },
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Re-Enter Password'
                          : AppConstants.passwordRegex.hasMatch(value)
                              ? passwordController.text ==
                                      confirmPasswordController.text
                                  ? null
                                  : 'Password not matched!'
                              : 'Invalid Password!';
                    },
                    controller: confirmPasswordController,
                    obscureText: isConfirmPasswordObscure,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Focus(
                        /// If false,
                        ///
                        /// disable focus for all of this node's descendants.
                        descendantsAreFocusable: false,

                        /// If false,
                        ///
                        /// make this widget's descendants un-traversable.
                        // descendantsAreTraversable: false,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordObscure =
                                  !isConfirmPasswordObscure;
                            });
                          },
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                              const Size(48, 48),
                            ),
                          ),
                          icon: Icon(
                            isConfirmPasswordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppTextFormField(
                      textInputAction: TextInputAction.done,
                      labelText: "Place of Birth",
                      keyboardType: TextInputType.streetAddress,
                      controller: placeOfBirthController),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: SizedBox(
                                width: 160,
                                child: TextField(
                                  controller: dateController,
                                  decoration: const InputDecoration(
                                      labelText: 'DATE',
                                      prefixIcon: Icon(Icons.calendar_today),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.lightBlue))),
                                  readOnly: true,
                                  onTap: () {
                                    selectDate();
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10.0),
                              child: ToggleButtons(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                onPressed: (int index) {
                                  setState(() {
                                    for (int i = 0;
                                        i < isSelected.length;
                                        i++) {
                                      isSelected[i] = i == index;
                                    }
                                  });
                                },
                                isSelected: isSelected,
                                children: const <Widget>[
                                  // first toggle button
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      ' Male',
                                    ),
                                  ),
                                  // second toggle button
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Female',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _formKey.currentState?.validate() ?? false
                        ? () async {
                            int gender = 0;
                            if (!isSelected[0]) {
                              gender = 1;
                            }
                            int? res = await widget.conn?.signupuser(
                                firstnameController.text,
                                lastnameController.text,
                                emailController.text,
                                passwordController.text,
                                placeOfBirthController.text,
                                gender,
                                dateController.text);
                            if (context.mounted) {
                              if (res == 1 || res == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something went Wrong!'),
                                  ),
                                );
                              } else if (res == -1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email already in use!'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Registration Complete, Please login!'),
                                  ),
                                );
                              }
                            }
                            firstnameController.clear();
                            lastnameController.clear();
                            emailController.clear();
                            passwordController.clear();
                            confirmPasswordController.clear();
                          }
                        : null,
                    style: const ButtonStyle().copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        _formKey.currentState?.validate() ?? false
                            ? null
                            : Colors.grey.shade900,
                      ),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I have an account?',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: Theme.of(context).textButtonTheme.style,
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.lightBlue,
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
    );
  }

  Future<void> selectDate() async {
    DateTime? selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1, 1),
        lastDate: DateTime.now());
    if (selected != null) {
      setState(() {
        dateController.text = selected.toString().split(" ")[0];
      });
    }
  }
}
