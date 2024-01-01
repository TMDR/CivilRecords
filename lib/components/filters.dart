//unused for now
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';

enum Filters { birthDate, deathDate }

abstract class Filter {
  final BuildContext context;
  late final List<TextEditingController> controllers;
  final void Function() callBack;
  final void Function(String) selectedCallBack;
  Filter(this.context, this.callBack, this.selectedCallBack);
  Widget filterContainer(List<Widget> data, String title) {
    data.addAll([
      const SizedBox(
        width: 8.0,
      ),
      IconButton(
        icon: const Icon(Icons.remove_circle_outlined),
        color: AppColors.grey,
        onPressed: () {
          selectedCallBack(title);
          callBack();
        },
      ),
    ]);
    return InputDecorator(
      decoration: InputDecoration(
        labelStyle:
            const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
        labelText: title,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(children: data),
      ),
    );
  }
}

//always visible, not in the enum
class NameFilter extends Filter {
  late final List<Widget> widget;
  late Widget lastname;
  NameFilter(BuildContext context, void Function() callBack,
      void Function(String) selectedCallBack)
      : super(context, callBack, selectedCallBack) {
    controllers = [TextEditingController(), TextEditingController()];
    widget = initWidget();
  }
  List<Widget> initWidget() {
    return [
      Flexible(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: AppColors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent)),
                labelStyle: TextStyle(color: AppColors.grey),
                fillColor: Colors.white10,
                labelText: "First Name",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              controller: controllers[0],
            ),
          )),
      Flexible(
        flex: 45,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: AppColors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent)),
              labelStyle: TextStyle(color: AppColors.grey),
              fillColor: Colors.white10,
              labelText: "Last Name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: controllers[1],
          ),
        ),
      )
    ];
  }
}

class BirthDateFilter extends Filter {
  late final Widget widget;
  BirthDateFilter(BuildContext context, void Function() callBack,
      void Function(String) selectedCallBack)
      : super(context, callBack, selectedCallBack) {
    controllers = [TextEditingController(), TextEditingController()];
    widget = filterContainer(initWidget(), "Date of Birth");
  }
  List<Widget> initWidget() {
    return [
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: controllers[0],
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'From',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () async {
            String? date = await selectDate();
            if (date != null) controllers[0].text = date;
            callBack;
          },
        ),
      ),
      const SizedBox(width: 8.0),
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: controllers[1],
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'To',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () async {
            String? date = await selectDate();
            if (date != null) controllers[1].text = date;
            callBack;
          },
        ),
      )
    ];
  }

  Future<String?> selectDate() async {
    DateTime? selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1, 1),
        lastDate: DateTime.now());
    if (selected != null) {
      return selected.toString().split(" ")[0];
    } else {
      return null;
    }
  }
}

class DeathDateFilter extends Filter {
  late final Widget widget;
  DeathDateFilter(BuildContext context, void Function() callBack,
      void Function(String) selectedCallBack)
      : super(context, callBack, selectedCallBack) {
    controllers = [TextEditingController(), TextEditingController()];
    widget = filterContainer(initWidget(), "Date of Death");
  }
  List<Widget> initWidget() {
    return [
      Expanded(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: controllers[0],
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'From',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () async {
            String? date = await selectDate();
            if (date != null) controllers[0].text = date;
          },
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: controllers[1],
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'To',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () async {
            String? date = await selectDate();
            if (date != null) controllers[1].text = date;
          },
        ),
      )
    ];
  }

  Future<String?> selectDate() async {
    DateTime? selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1, 1),
        lastDate: DateTime.now());
    if (selected != null) {
      return selected.toString().split(" ")[0];
    } else {
      return null;
    }
  }
}
