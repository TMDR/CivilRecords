import 'package:civilrecord/utils/db.dart';
import 'components/multiselect.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'components/filters.dart';
import 'components/models.dart';

class User extends StatefulWidget {
  final Pdb? dbconn;
  final int? id;
  const User({super.key, required this.dbconn, required this.id});
  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  UserPage? _userPage;
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

  Widget detailsCard(String title, String? data, IconData icon, int i) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Card(
        elevation: 5,
        color: AppColors.lightBlue,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                data != null
                    ? Container(
                        constraints:
                            const BoxConstraints(maxWidth: 200, maxHeight: 30),
                        child: TextFormField(
                          decoration: !(_userPage?.editMode ?? false)
                              ? const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none)
                              : const InputDecoration(
                                  border: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide:
                                          BorderSide(color: AppColors.grey))),
                          controller: _userPage?.controllers[i],
                          readOnly: !(_userPage?.editMode ?? false),
                        ),
                      )
                    : const Text("None",
                        style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            ...(_userPage?.data.id != (widget.id ?? 0) &&
                    ((widget.id ?? 0) != 0))
                ? []
                : [
                    const Spacer(),
                    IconButton(
                      icon: Icon(!(_userPage?.editMode ?? false)
                          ? Icons.edit
                          : Icons.check),
                      onPressed: () async {
                        if (!(_userPage?.editMode ?? false)) {
                          _userPage?.editMode = true;
                        } else {
                          _userPage?.editMode = false;
                          //TODO: occupation stuff
                          bool? resp = await dbconn?.updateUser(
                              _userPage?.data.id ?? 0,
                              _userPage?.controllers[0].text ?? "",
                              _userPage?.controllers[1].text ?? "",
                              _userPage?.controllers[2].text ?? "",
                              _userPage?.controllers[3].text ?? "",
                              _userPage?.controllers[4].text ?? "",
                              _userPage?.controllers[5].text ?? "");
                          if (context.mounted) {
                            if (resp ?? false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Updated!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something Went Wrong!'),
                                ),
                              );
                            }
                          }
                        }
                        setState(() {});
                      },
                    )
                  ]
          ]),
        ),
      ),
    );
  }

  Widget details(bool big) {
    if (_userPage == null) {
      return const Center(
        child: Text('No Person selected'),
      );
    }

    return Container(
      alignment: Alignment.topLeft,
      height: double.infinity,
      width: double.infinity,
      color: Colors.black12,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 15, top: 15),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                        color: AppColors.grey,
                        size: 150,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          detailsCard("First Name",
                              _userPage?.controllers[0].text, Icons.person, 0),
                          const SizedBox(height: 4.0),
                          detailsCard("Last Name",
                              _userPage?.controllers[1].text, Icons.person, 1),
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          detailsCard(
                              "Gender",
                              _userPage?.controllers[2].text,
                              _userPage?.data.gender ?? true
                                  ? Icons.male
                                  : Icons.female,
                              2),
                          const SizedBox(height: 4.0),
                          detailsCard("Place of Birth",
                              _userPage?.controllers[3].text, Icons.person, 3),
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          detailsCard("Date of Birth",
                              _userPage?.controllers[4].text, Icons.cake, 4),
                          const SizedBox(height: 4.0),
                          detailsCard(
                              "Date of Death",
                              _userPage?.controllers[5].text,
                              Icons.spa_outlined,
                              5),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      detailsCard("Occupation", _userPage?.controllers[6].text,
                          Icons.work_outline, 6),
                      const SizedBox(height: 4.0),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                    color: AppColors.blue,
                    constraints:
                        const BoxConstraints(minWidth: 400, maxWidth: 401),
                    child: FutureBuilder(
                      future: dbconn?.getRelated(_userPage?.data.id ?? 0),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return SingleChildScrollView(
                            child: ExpansionTile(
                              title: const Text("Related People"),
                              children: [
                                for (Person person in snapshot.data?.keys ?? [])
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _userPage = UserPage(data: person);
                                      });
                                    },
                                    child: personCard(person,
                                        relation: snapshot.data?[person]),
                                  ),
                                const SizedBox(
                                  height: 220,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const ExpansionTile(
                            title: Text("Related People"),
                            children: [Text("Loading...")],
                          );
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
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
    var big = width > 752;

    var mainLayout = onePaneLayout(context, big, people);

    // if width is greater than 700, use two column layout
    if (big) {
      mainLayout = twoPaneLayout(big, people);
    }

    if (!big && _userPage != null) {
      mainLayout = details(big);
    }

    return Scaffold(
      appBar: (!big && _userPage != null)
          ? AppBar(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              title: const Text('Details'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _userPage = null;
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
        background: personList(),
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
    var foundpeople = await dbconn?.fetchPeople(firstName, lastName,
            fromDateOfBirth, toDateOfBirth, fromDateOfDeath, toDateOfDeath) ??
        [];
    setState(() {
      people = foundpeople;
    });
  }

  Widget personList() {
    return people.isNotEmpty
        ? Scaffold(
            backgroundColor: Colors.black12,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(children: peopleWidgets(null)),
                ),
              ),
            ))
        : const Center(child: Text("Search for People!"));
  }

  List<Widget> peopleWidgets(List<Person>? data) {
    data ??= people;
    return [
      for (Person person in data)
        GestureDetector(
          onTap: () {
            setState(() {
              _userPage = UserPage(data: person);
            });
          },
          child: personCard(person),
        ),
      const SizedBox(
        height: 220,
      ),
    ];
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

  Widget personCard(Person person, {String? relation}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: (_userPage?.data == person)
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
                    ),
                    relation != null
                        ? Text(
                            "Relation: $relation",
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 10),
                          )
                        : Container()
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
