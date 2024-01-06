// main.dart
import 'package:flutter/material.dart';
import 'models.dart';

class OccupationSelect extends StatefulWidget {
  final List<OccupationData> data;
  const OccupationSelect({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OccupationSelectState();
}

class _OccupationSelectState extends State<OccupationSelect> {
  @override
  void initState() {
    super.initState();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  _buildExpandableContent(OccupationData occupation) {
    List<Widget> columnContent = [];

    for (Trait trait in occupation.traits) {
      columnContent.add(
        ListTile(
          onTap: () {
            Navigator.pop(context,
                [occupation.id, trait.id, occupation.title, trait.value]);
          },
          title: Text(
            trait.value,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }

    return columnContent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Select Occupation and Position'),
      content: SizedBox(
        height: 400,
        width: 100,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.data.length,
          itemBuilder: (context, i) {
            return ExpansionTile(
              title: Text(
                widget.data[i].title,
                style: const TextStyle(fontSize: 20.0),
              ),
              children: _buildExpandableContent(widget.data[i]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
