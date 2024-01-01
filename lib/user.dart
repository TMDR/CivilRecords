import 'components/multiselect.dart';
import 'package:civilrecord/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'components/filters.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  var _selectedPerson = -1;

  final GlobalKey<ExpandableBottomSheetState> exkey = GlobalKey();
  var expansionStatus = ExpansionStatus.contracted;

  late final NameFilter _nameFilter;
  late final BirthDateFilter _birthDateFilter;
  late final DeathDateFilter _deathDateFilter;

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
      width: big ? 400 : null,
      child: ExpandableBottomSheet(
        key: exkey,
        persistentContentHeight: 0,
        //This is the widget which will be overlapped by the bottom sheet.
        background: personList(big),
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
                        onPressed: () {
                          exkey.currentState!.expand();
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
                height: 220,
              )
            ]),
          ),
        ),
      ),
    );
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

  Widget personCard(int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color:
          (_selectedPerson == index) ? AppColors.lightBlue : AppColors.darkBlue,
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
}
