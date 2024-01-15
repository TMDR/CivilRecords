// main.dart
import 'package:civilrecord/components/app_text_form_field.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';

class Trait {
  late final Widget widget;
  final TextEditingController controller = TextEditingController();
  Trait() {
    widget = AppTextFormField(
        textInputAction: TextInputAction.done,
        labelText: "Trait",
        keyboardType: TextInputType.name,
        controller: controller);
  }
}

class CreateWork extends StatefulWidget {
  const CreateWork({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateWorkState();
}

class _CreateWorkState extends State<CreateWork> {
  TextEditingController name = TextEditingController();
  List<Trait> traits = [];
  @override
  void initState() {
    super.initState();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    List<String> traitss = [];
    for (Trait trait in traits) {
      traitss.add(trait.controller.text);
    }
    Navigator.pop(context, List.from([name.text, ...traitss]));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Select Occupation and Position'),
      content: SizedBox(
        height: 400,
        width: 100,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppTextFormField(
                  textInputAction: TextInputAction.done,
                  labelText: "Name",
                  keyboardType: TextInputType.name,
                  controller: name),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List<Widget>.from(traits
                    .map(
                      (e) => e.widget,
                    )
                    .toList())
                  ..add(
                    Center(
                      child: IconButton(
                        color: AppColors.grey,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          traits.add(Trait());
                          setState(() {});
                        },
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
