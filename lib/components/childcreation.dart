// main.dart
import 'package:civilrecord/components/app_text_form_field.dart';
import 'package:civilrecord/values/app_constants.dart';
import 'package:flutter/material.dart';

class ChildCreator extends StatefulWidget {
  const ChildCreator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChildCreatorState();
}

class _ChildCreatorState extends State<ChildCreator> {
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController placeOfBirthController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<bool> isSelected = [true, false];
  @override
  void initState() {
    super.initState();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    int gender = 0;
    if (!isSelected[0]) {
      gender = 1;
    }
    Navigator.pop(context, [
      firstNameController.text,
      emailController.text,
      passwordController.text,
      placeOfBirthController.text,
      gender
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Select Occupation and Position'),
      content: SizedBox(
          height: 400,
          width: 100,
          child: Column(
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
                controller: firstNameController,
              ),
              AppTextFormField(
                  textInputAction: TextInputAction.done,
                  labelText: "Place of Birth",
                  keyboardType: TextInputType.streetAddress,
                  controller: placeOfBirthController),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: ToggleButtons(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
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
          )),
      actions: [
        TextButton(onPressed: _submit, child: const Text('Submit')),
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
