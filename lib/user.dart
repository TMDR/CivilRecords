import 'components/multiselect.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  var _selectedPerson = -1;

  final GlobalKey<ExpandableBottomSheetState> exkey = GlobalKey();
  var expansionStatus = ExpansionStatus.contracted;
  TextEditingController fcontroller = TextEditingController();
  TextEditingController lcontroller = TextEditingController();
  TextEditingController fromBirthDate = TextEditingController();
  TextEditingController fromDeathDate = TextEditingController();
  TextEditingController toDeathDate = TextEditingController();
  TextEditingController toBirthDate = TextEditingController();

  final List<String> items = ['Date of Birth', 'Date of Death'];
  List<String> _selectedItems = [];

  void _showMultiSelect() async {
    //the order matters
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: items, selected: _selectedItems);
      },
    );

    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }

  Widget details(bool big) {
    if (_selectedPerson == -1) {
      return const Center(
        child: Text('No Person selected'),
      );
    }

    return Center(
      child: Text("You have to implement now, lazy. $_selectedPerson"),
    );
  }

  Widget twoPaneLayout(bool big) {
    return Row(
      children: [
        firstView(context, big),
        const VerticalDivider(width: 1, thickness: .2),
        Expanded(
          child: details(big),
        ),
      ],
    );
  }

  Widget onePaneLayout(BuildContext context, bool big) {
    return firstView(context, big);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    var big = width > 700;

    var mainLayout = onePaneLayout(context, big);

    // if width is greater than 700, use two column layout
    if (big) {
      mainLayout = twoPaneLayout(big);
    }

    if (!big && _selectedPerson != -1) {
      mainLayout = details(big);
    }

    return Scaffold(
      appBar: (!big && _selectedPerson != -1)
          ? AppBar(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              title: const Text('Details'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedPerson = -1;
                  });
                },
              ),
            )
          : AppBar(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              title: const Text('User'),
              centerTitle: true,
            ),
      body: mainLayout,
    );
  }

  Widget firstView(BuildContext context, bool big) {
    return SizedBox(
      width: big ? 350 : null,
      child: ExpandableBottomSheet(
        key: exkey,
        persistentContentHeight: 0,
        //This is the widget which will be overlapped by the bottom sheet.
        background: personList(big),
        //This is the content of the bottom sheet which will be extendable by dragging
        expandableContent: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: AppColors.darkBlue,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Wrap(
                runSpacing: 10.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: List<Widget>.from(_selectedItems
                    .map(
                      (e) => filter(e),
                    )
                    .toList())
                  ..add(Center(
                    child: IconButton(
                      color: AppColors.grey,
                      icon: const Icon(Icons.add),
                      onPressed: _showMultiSelect,
                    ),
                  ))),
          ),
        ),
        //This widget is sticking above the content and will never be contracted.
        persistentHeader: Container(
          decoration: BoxDecoration(
              color: AppColors.darkBlue,
              border: Border.all(color: AppColors.darkBlue),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Center(
            child: Column(
              children: [
                IconButton(
                    onPressed: () {
                      if (exkey.currentState!.expansionStatus == ExpansionStatus.expanded) {
                        exkey.currentState!.contract();
                      } else {
                        exkey.currentState!.expand();
                      }
                    },
                    icon: const Icon(
                      Icons.expand_less,
                      color: Colors.white,
                    )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                              enabledBorder:
                                  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)), borderSide: BorderSide(color: AppColors.grey)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                              labelStyle: TextStyle(color: AppColors.grey),
                              fillColor: Colors.white10,
                              labelText: "First Name",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: fcontroller,
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
                            enabledBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)), borderSide: BorderSide(color: AppColors.grey)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                            labelStyle: TextStyle(color: AppColors.grey),
                            fillColor: Colors.white10,
                            labelText: "Last Name",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: lcontroller,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          exkey.currentState!.expand();
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget personList(bool big) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Wrap(direction: Axis.horizontal, children: [
              //for test purposes, every card will have an id and will be generated soon
              for (int i = 0; i < 10; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPerson = i;
                    });
                  },
                  child: personCard(i),
                ),
              const SizedBox(
                height: 200,
              )
            ]),
          ),
        ),
      ),
    );
  }

  //extra filter container except place of birth
  Widget filterContainer(List<Widget> data, String title) {
    data.addAll([
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.remove_circle_outlined),
        color: AppColors.grey,
        onPressed: () {
          _selectedItems.remove(title);
          setState(() {});
        },
      ),
    ]);
    return InputDecorator(
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
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

  Widget filter(String filter) {
    if (filter == items[0]) {
      return dateOfBirth();
    } else if (filter == items[1]) {
      return dateOfDeath();
    } else {
      return const Text('ERROR');
    }
  }

  Widget dateOfBirth() {
    return filterContainer([
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: fromBirthDate,
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'From',
              filled: true,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () {
            selectDate(true, true);
          },
        ),
      ),
      const SizedBox(width: 8.0),
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: toBirthDate,
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'To',
              filled: true,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () {
            selectDate(false, true);
          },
        ),
      )
    ], 'Date of Birth');
  }

  Widget dateOfDeath() {
    return filterContainer([
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: fromDeathDate,
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'From',
              filled: true,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () {
            selectDate(true, false);
          },
        ),
      ),
      const SizedBox(width: 8.0),
      Flexible(
        child: TextField(
          style: const TextStyle(color: AppColors.grey),
          controller: toDeathDate,
          decoration: const InputDecoration(
              labelStyle: TextStyle(color: AppColors.grey),
              labelText: 'To',
              filled: true,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.grey,
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBlue))),
          readOnly: true,
          onTap: () {
            selectDate(false, false);
          },
        ),
      )
    ], 'Date of Death');
  }

  Widget personCard(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: (_selectedPerson == index) ? AppColors.lightBlue : AppColors.darkBlue,
      elevation: 1,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 350,
          child: Row(
            children: [
              Icon(
                Icons.man_2_rounded,
                color: AppColors.grey,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FirstName LastName",
                      style: TextStyle(color: AppColors.grey),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Date of Birth: 1/1/1970",
                      style: TextStyle(color: AppColors.grey, fontSize: 10),
                    ),
                    Text(
                      "Place of Birth: Beirut",
                      style: TextStyle(color: AppColors.grey, fontSize: 10),
                    )
                  ],
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(bool from, bool birth) async {
    DateTime? selected = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900, 1, 1), lastDate: DateTime.now());
    if (selected != null) {
      setState(() {
        if (birth) {
          if (from) {
            fromBirthDate.text = selected.toString().split(" ")[0];
          } else {
            toBirthDate.text = selected.toString().split(" ")[0];
          }
        } else {
          if (from) {
            fromDeathDate.text = selected.toString().split(" ")[0];
          } else {
            toDeathDate.text = selected.toString().split(" ")[0];
          }
        }
      });
    }
  }
}
