import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';

import 'my_functions.dart';

class FinalResult extends StatefulWidget {
  const FinalResult({Key? key}) : super(key: key);

  @override
  _FinalResultState createState() => _FinalResultState();
}

class _FinalResultState extends State<FinalResult> {
  double totalPercent = 0;
  double percent1 = GetStorage().read("level_1_percent") ?? 0;
  double percent2 = GetStorage().read("level_2_percent") ?? 0;
  double percent3 = GetStorage().read("level_3_percent") ?? 0;
  calcTotalPercent() {
    setState(() {
      totalPercent = (percent1 + percent2 + percent3) / 3;
    });
  }

  int point1 = GetStorage().read("level_1_point") ?? 0;
  int point2 = GetStorage().read("level_2_point") ?? 0;
  int point3 = GetStorage().read("level_3_point") ?? 0;

  late String totalPoint = "${point1 + point2 + point3}";
  @override
  void initState() {
    calcTotalPercent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              border: TableBorder.all(
                width: 4,
                color: Colors.green,
                style: BorderStyle.solid,
                borderRadius: BorderRadius.circular(20),
              ),
              children: [
                buildRow(
                  [
                    'المستوى الاول',
                    'المستوى الثانى',
                    'المستوى الثالث',
                  ],
                ),
                buildRow(
                  [
                    ' النقاط : ${MyFunctions.convertNumber(point1.toString(), GetStorage().read('lang'))}',
                    ' النقاط : ${MyFunctions.convertNumber(point2.toString(), GetStorage().read('lang'))}',
                    ' النقاط : ${MyFunctions.convertNumber(point3.toString(), GetStorage().read('lang'))}',
                  ],
                ),
                buildRow(
                  [
                    '   ${MyFunctions.convertNumber(percent1.toString(), GetStorage().read('lang'))} %',
                    ' ${MyFunctions.convertNumber(percent2.toString(), GetStorage().read('lang'))} %',
                    '  ${MyFunctions.convertNumber(percent2.toString(), GetStorage().read('lang'))} %'
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 150,
          ),
          const Divider(
            height: 25,
            color: Colors.pinkAccent,
          ),
          Card(
            color: Colors.amber,
            child: ListTile(
              title: const Text(
                "مجموع النقاط",
                style: TextStyle(fontSize: 20),
              ),
              // trailing: Text("$totalPoint"),
              trailing: Text(
                  "${MyFunctions.convertNumber(totalPoint, GetStorage().read('lang'))} %"),
            ),
          ),
          Card(
            color: Colors.deepOrange.shade300,
            child: ListTile(
              title: const Text(
                "مجموع النسب",
                style: TextStyle(fontSize: 20),
              ),
              // trailing: Text("${totalPercent.toStringAsFixed(2)}"),
              trailing: Text(
                  "${MyFunctions.convertNumber(totalPercent.toStringAsFixed(2), GetStorage().read('lang'))} %"),
            ),
          )
        ],
      ),
    );
  }

  TableRow buildRow(List<String> res) => TableRow(
        decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20)),
        children: res
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}
