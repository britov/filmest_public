

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_create/generated/i18n.dart';
import 'package:flutter_create/model/model.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SelectDateRange extends StatefulWidget {
  const SelectDateRange({Key key, this.fromYear, this.toYear}) : super(key: key);

  final int fromYear;
  final int toYear;

  @override
  _SelectDateRangeState createState() => _SelectDateRangeState();
}

class _SelectDateRangeState extends State<SelectDateRange> {
  final int minYear = 1890;
  final int maxYear = DateTime.now().year;

  int fromIndex;
  int toIndex;

  int get fromYear => fromIndex != null && fromIndex != 0 ? fromIndex + minYear - 1 : null;

  int get toYear => toIndex != null && toIndex != 0 ? toIndex + minYear - 1 : null;

  @override
  void initState() {
    super.initState();
    if (widget.fromYear != null) {
      fromIndex = widget.fromYear - minYear + 1;
    }
    if (widget.toYear != null) {
      toIndex = widget.toYear - minYear + 1;
    }
  }

  @override
  Widget build(BuildContext context) => BottomSheet(
    onClosing: () {},
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                'Release date',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            constraints: BoxConstraints.tight(const Size(double.infinity, 210)),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    constraints: BoxConstraints.tight(const Size(double.infinity, 70)),
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(initialItem: fromIndex ?? 0),
                          diameterRatio: 4,
                          physics: const FixedExtentScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          itemExtent: 70,
                          onSelectedItemChanged: (index) => fromIndex = index,
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: <Widget>[
                              _buildItem(const Text('from (any)')),
                              for (var year = minYear; year <= maxYear; year++) _buildItem(Text('$year'))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(initialItem: toIndex ?? 0),
                          physics: const FixedExtentScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          diameterRatio: 4,
                          itemExtent: 70,
                          onSelectedItemChanged: (index) => toIndex = index,
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: <Widget>[
                              _buildItem(const Text('to (any)')),
                              for (var year = minYear; year <= maxYear; year++) _buildItem(Text('$year'))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ButtonBar(
          buttonTextTheme: ButtonTextTheme.accent,
          alignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              child: const Text('CLEAR'),
              onPressed: () => Navigator.pop(context, const Tuple2<int, int>(null, null)),
            ),
            FlatButton(
              child: const Text('APPLY'),
              onPressed: () => Navigator.pop(context, Tuple2<int, int>(fromYear, toYear)),
            )
          ],
        )
      ],
    ),
  );

  Expanded buildDividers() => Expanded(
    child: Column(
      children: const <Widget>[
        Divider(
          height: 1,
          color: Colors.white,
        ),
        Spacer(),
        Divider(
          color: Colors.white,
        ),
      ],
    ),
  );

  Widget _buildItem(Widget child, {double height = 70}) => SizedBox(
    width: double.infinity,
    height: height,
    child: Center(
      child: child,
    ),
  );
}

class GenresDrawer extends StatefulWidget {
  @override
  _GenresDrawerState createState() => _GenresDrawerState();
}

class _GenresDrawerState extends State<GenresDrawer> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<FilmsModel>();
    return Drawer(
      child: ListView.builder(
          itemCount: (model.genres?.length ?? 0) + 1,
          itemBuilder: (BuildContext context, int index) => index == 0
              ? _buildRadio(context, model.currentGenre, null, Text(S.of(context).all))
              : _buildRadio(context, model.currentGenre, model.genres[index - 1]['id'],
              Text(model.genres[index - 1]['name'] ?? ''))),
    );
  }

  Widget _buildRadio(BuildContext context, int currentGenre, int value, Widget title) => RadioListTile<int>(
      value: value,
      groupValue: currentGenre,
      title: title,
      onChanged: (s) {
        context.read<FilmsModel>().currentGenre = s;
        Navigator.pop(context);
      });
}