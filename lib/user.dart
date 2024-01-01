import 'package:civilrecord/utils/db.dart';
import 'package:postgres/postgres.dart';

import 'components/multiselect.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'components/filters.dart';
import 'components/models.dart';

class User extends StatefulWidget {
  final Pdb? dbconn;
  const User({super.key, required this.dbconn});
  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  var _selectedPerson = -1;
  Pdb? dbconn;
  final GlobalKey<ExpandableBottomSheetState> exkey = GlobalKey();
  var expansionStatus = ExpansionStatus.contracted;
  late final NameFilter _nameFilter;
  late final BirthDateFilter _birthDateFilter;
  late final DeathDateFilter _deathDateFilter;
  List<Person> people = [];

  final List<String> items = ['Date of Birth', 'Date of Death'];
  List<String> _selectedItems = [];
  void _selectedItemsCallBackRemove(String value) {
    _selectedItems.remove(value);
  }

  void setStateCallBack() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameFilter =
        NameFilter(context, setStateCallBack, _selectedItemsCallBackRemove);
    _birthDateFilter = BirthDateFilter(
        context, setStateCallBack, _selectedItemsCallBackRemove);
    _deathDateFilter = DeathDateFilter(
        context, setStateCallBack, _selectedItemsCallBackRemove);
    //not sure if ill need that one
    dbconn = widget.dbconn;
  }

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

  Widget twoPaneLayout(bool big, List<Person> people) {
    return Row(
      children: [
        firstView(context, big, people),
        const VerticalDivider(width: 1, thickness: .2),
        Expanded(
          child: details(big),
        ),
      ],
    );
  }

  Widget onePaneLayout(BuildContext context, bool big, List<Person> people) {
    return firstView(context, big, people);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var big = width > 700;

    var mainLayout = onePaneLayout(context, big, people);

    // if width is greater than 700, use two column layout
    if (big) {
      mainLayout = twoPaneLayout(big, people);
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

  Widget firstView(BuildContext context, bool big, List<Person> people) {
    return SizedBox(
      width: big ? 400 : null,
      child: ExpandableBottomSheet(
        key: exkey,
        persistentContentHeight: 0,
        //This is the widget which will be overlapped by the bottom sheet.
        background: personList(people),
        //This is the content of the bottom sheet which will be extendable by dragging
        expandableContent: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                ..add(
                  Center(
                    child: IconButton(
                      color: AppColors.grey,
                      icon: const Icon(Icons.add),
                      onPressed: _showMultiSelect,
                    ),
                  ),
                ),
            ),
          ),
        ),
        //This widget is sticking above the content and will never be contracted.
        persistentHeader: Container(
          decoration: BoxDecoration(
              color: AppColors.darkBlue,
              border: Border.all(color: AppColors.darkBlue),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Center(
            child: Column(
              children: [
                IconButton(
                    onPressed: () {
                      if (exkey.currentState!.expansionStatus ==
                          ExpansionStatus.expanded) {
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
                  children: List<Widget>.from(_nameFilter.widget)
                    ..add(Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () async {
                          await search();
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> search() async {
    var firstName = _nameFilter.controllers[0].text;
    var lastName = _nameFilter.controllers[1].text;
    var fromDateOfBirth = (_selectedItems.contains("Date of Birth"))
        ? _birthDateFilter.controllers[0].text
        : "";
    var toDateOfBirth = (_selectedItems.contains("Date of Birth"))
        ? _birthDateFilter.controllers[1].text
        : "";
    var fromDateOfDeath = (_selectedItems.contains("Date of Death"))
        ? _deathDateFilter.controllers[0].text
        : "";
    var toDateOfDeath = (_selectedItems.contains("Date of Death"))
        ? _deathDateFilter.controllers[1].text
        : "";
    String select =
        "SELECT id,first_name,last_name,place_of_birth,date_of_birth,gender FROM PERSON WHERE ";
    int length = select.length;
    select =
        firstName == "" ? select : ("${select}first_name='$firstName' AND ");
    select = lastName == "" ? select : ("${select}last_name='$lastName' AND ");
    select = fromDateOfBirth == ""
        ? select
        : ("${select}date_of_birth>='$fromDateOfBirth' AND ");
    select = toDateOfBirth == ""
        ? select
        : ("${select}date_of_birth<='$toDateOfBirth' AND ");
    select = fromDateOfDeath == ""
        ? select
        : ("${select}date_of_death>='$fromDateOfDeath' AND ");
    select = toDateOfDeath == ""
        ? select
        : ("${select}date_of_death<='$toDateOfBirth' AND ");
    if (select.length > length) {
      select = select.substring(0, select.length - 5);
    } else {
      select = "";
    }
    Result? resp = select == "" ? null : await dbconn?.execute(select);
    List<Person> foundpeople = [];
    var row = resp?.iterator;
    while (row?.moveNext() ?? false) {
      foundpeople.add(Person(
          id: row?.current[0] as int,
          firstName: row?.current[1] as String,
          lastName: row?.current[2] as String,
          placeOfBirth: row?.current[3] as String,
          dateOfBirth: (row?.current[4] as DateTime).toString().split(" ")[0],
          dateOfDeath: null,
          occupation: null,
          gender: !(row?.current[5] as bool)));
    }
    setState(() {
      people = foundpeople;
    });
  }

  Widget personList(List<Person> people) {
    return people.isNotEmpty
        ? Scaffold(
            backgroundColor: Colors.black12,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Expanded(
                    child: Column(children: [
                      for (Person person in people)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPerson = person.id;
                            });
                          },
                          child: personCard(person),
                        ),
                      const SizedBox(
                        height: 220,
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          )
        : const Center(child: Text("Search for People!"));
  }

  Widget filter(String filter) {
    if (filter == items[0]) {
      return _birthDateFilter.widget;
    } else if (filter == items[1]) {
      return _deathDateFilter.widget;
    } else {
      return const Text('ERROR');
    }
  }

  Widget personCard(Person person) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: (_selectedPerson == person.id)
          ? AppColors.lightBlue
          : AppColors.darkBlue,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 350,
          child: Row(
            children: [
              Icon(
                person.gender ? Icons.man_2_rounded : Icons.woman_2_rounded,
                color: AppColors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${person.firstName} ${person.lastName}",
                      style: const TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Date of Birth: ${person.dateOfBirth}",
                      style:
                          const TextStyle(color: AppColors.grey, fontSize: 10),
                    ),
                    Text(
                      "Place of Birth: ${person.placeOfBirth}",
                      style:
                          const TextStyle(color: AppColors.grey, fontSize: 10),
                    )
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }
}
