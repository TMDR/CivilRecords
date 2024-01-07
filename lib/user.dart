import 'package:civilrecord/components/occupationselect.dart';
import 'package:civilrecord/login/login_page.dart';
import 'package:civilrecord/utils/db.dart';
import 'components/multiselect.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'components/filters.dart';
import 'components/models.dart';
import 'components/childcreation.dart';

class User extends StatefulWidget {
  final Person? loggedInUser;
  final Pdb? dbconn;
  final int? id;
  const User(
      {super.key,
      required this.dbconn,
      required this.id,
      required this.loggedInUser});
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
  bool isChanged = true;
  Map<Person, String>? cache;
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
    //not sure if i'll need that one
    dbconn = widget.dbconn;
  }

  Future<List<Object>?> _showChildCreation() async {
    final List<Object>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ChildCreator();
      },
    );
    return results;
  }

  void _showOccupationSelect(List<OccupationData> data) async {
    final List<Object>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return OccupationSelect(data: data);
      },
    );
    if (results != null) {
      bool? resp = await dbconn?.setOccupation(
          (_userPage?.data.occupation != null),
          results[0] as int,
          results[1] as int,
          _userPage?.data.id as int);
      if (resp == false || resp == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erro!'),
          ));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Occupation Set!'),
          ));
        }
      }
      _userPage?.controllers[6].text = '${results[2]} as ${results[3]}';
    }
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

  Widget detailsCard(
      String title, String? data, IconData icon, int i, bool isOccupation) {
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
                        if (!isOccupation) {
                          if (!(_userPage?.editMode ?? false)) {
                            _userPage?.editMode = true;
                          } else {
                            _userPage?.editMode = false;
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
                        } else {
                          final List<OccupationData> data =
                              await dbconn?.listAllOccupations() ?? [];

                          _showOccupationSelect(data);
                        }
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
                Column(
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
                        detailsCard(
                            "First Name",
                            _userPage?.controllers[0].text,
                            Icons.person,
                            0,
                            false),
                        const SizedBox(height: 4.0),
                        detailsCard("Last Name", _userPage?.controllers[1].text,
                            Icons.person, 1, false),
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
                            2,
                            false),
                        const SizedBox(height: 4.0),
                        detailsCard(
                            "Place of Birth",
                            _userPage?.controllers[3].text,
                            Icons.person,
                            3,
                            false),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        detailsCard(
                            "Date of Birth",
                            _userPage?.controllers[4].text,
                            Icons.cake,
                            4,
                            false),
                        const SizedBox(height: 4.0),
                        detailsCard(
                            "Date of Death",
                            _userPage?.controllers[5].text,
                            Icons.spa_outlined,
                            5,
                            false),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    detailsCard("Occupation", _userPage?.controllers[6].text,
                        Icons.work_outline, 6, true),
                    const SizedBox(height: 4.0),
                  ],
                ),
                const SizedBox(height: 4.0),
                Container(
                    color: AppColors.blue,
                    constraints:
                        const BoxConstraints(minWidth: 400, maxWidth: 401),
                    child: FutureBuilder(
                      future: getRelatedFunc(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null || !isChanged) {
                          return SingleChildScrollView(
                            child: ExpansionTile(
                              title: const Text("Related People"),
                              children: [
                                for (Person person in snapshot.data?.keys ?? [])
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isChanged = true;
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

  Future<Map<Person, String>?> getRelatedFunc() async {
    if (isChanged) {
      isChanged = !isChanged;
      cache = await dbconn?.getRelated(
          _userPage?.data.id ?? 0, _userPage?.data.spouse ?? 0);
    }
    return cache;
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
    Widget menu() {
      return PopupMenuButton(itemBuilder: (context) {
        return [
          PopupMenuItem<int>(
            value: 0,
            enabled: _userPage != null &&
                (widget.loggedInUser?.gender != _userPage?.data.gender &&
                    widget.loggedInUser != null),
            child: const Text("Marry"),
          ),
          PopupMenuItem<int>(
            enabled: (widget.loggedInUser != null),
            value: 1,
            child: const Text("Add Child"),
          ),
          const PopupMenuItem<int>(
            value: 2,
            child: Text("Log Out"),
          )
        ];
      }, onSelected: (value) async {
        if (value == 0) {
          List<int> ids = [
            widget.loggedInUser?.id ?? 0,
            _userPage?.data.id ?? 0
          ];
          bool? resp = await dbconn?.addMarriage(
              widget.loggedInUser?.gender ?? true
                  ? ids
                  : ids.reversed.toList());
          if (resp ?? false) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Marriage Added!'),
              ));
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Error!'),
              ));
            }
          }
        } else if (value == 1) {
          //first check if married
          int? resp =
              await dbconn?.checkIfMarried(widget.loggedInUser?.id ?? 0);
          if (resp != null) {
            List<Object>? results = await _showChildCreation();
            String lastname;
            int idParent;
            //now add a child
            if (resp == widget.id) {
              //is a man
              lastname = widget.loggedInUser?.lastName ?? "None";
              idParent = widget.loggedInUser?.id ?? 0;
            } else {
              List<Object>? resp =
                  await dbconn?.getFatherDetailsForChild(widget.id ?? 0);
              if (resp != null) {
                lastname = resp[1] as String;
                idParent = resp[0] as int;
              } else {
                return;
              }
            }
            if (results != null) {
              int? res = await dbconn?.signupuser(
                  results[0] as String,
                  lastname,
                  results[1] as String,
                  results[2] as String,
                  results[3] as String,
                  results[4] as int,
                  "None");
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
                      content: Text('Child Registered!'),
                    ),
                  );
                  await dbconn?.addChildRelation(idParent, res);
                  setState(() {});
                }
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not married!'),
                ),
              );
            }
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const LoginPage(),
            ),
          );
        }
      });
    }

    return Scaffold(
      appBar: (!big && _userPage != null)
          ? AppBar(
              actions: [menu()],
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
              actions: [menu()],
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
          onTap: () async {
            setState(() {
              isChanged = true;
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
