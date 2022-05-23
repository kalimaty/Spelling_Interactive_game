import 'package:faisal_game/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';

class ResultPage extends StatefulWidget {
  final List question;
  final List answers;
  final List answersTime;
  final int levelTime;
  final int level;

  const ResultPage(
      {Key? key,
      required this.answers,
      required this.answersTime,
      required this.question,
      required this.levelTime,
      required this.level,
      required AudioPlayer player})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String finalResult = "";
  String percentOfResult = "";
  double percentOfPoint = 0;
  int totalPoint = 0;

  final player = AudioPlayer();
  //levelTime هذا وقت المستوى
  //  totalTime = مجموع اوقات الاسئلة
  //  totalUserTime = مجموع الوقت المستغرق في الاجابات
  //   answersTime = هذه تأتي من الصفحة السابقة
  calcFinalResult() async {
    // totalTime = الوقت المحدد في المستوى * عدد الاسئلة
    int totalTime = widget.levelTime * widget.question.length;

    int totalUserTime = 0;

    widget.answersTime.forEach((element) {
      //(widget.levelTime - element) = نقوم بانقاص الوقت المتبقى من السؤال من الوقت الكلي لنحصل على الوقت المستغرق
      // بعدها نجمع الاوقات المستغرقة totalUserTime + ...
      totalUserTime = totalUserTime + (widget.levelTime - element).toInt();
      print(element);
    });

    setState(() {
      percentOfResult =
          "${((totalUserTime * 100) / totalTime).toStringAsFixed(2)}";

      percentOfPoint = (((widget.answers
                  .where((element) => element == true)
                  .toList()
                  .length) *
              100) /
          widget.answers.length);
      finalResult = "$totalUserTime";

      totalPoint =
          (widget.answers.where((element) => element == true).toList().length) *
              5;
    });

    if (percentOfPoint < 33) {
      await player.setAsset("assets/sounds/lose_sound.wav");
      player.play();
    } else if (percentOfPoint > 33 && percentOfPoint < 66) {
      await player.setAsset("assets/sounds/good_applause.wav");
      player.play();
    } else {
      await player.setAsset("assets/sounds/excellent_applause.wav");
      player.play();
    }

    if (percentOfPoint >= 50) {
      GetStorage().read("level") == 3
          ? GetStorage().write("level", 1)
          : GetStorage().write("level", widget.level + 1);
      // GetStorage().erase();
    }

    GetStorage().write("level_${widget.level}_point", totalPoint);
    GetStorage().write("level_${widget.level}_percent", percentOfPoint);
  }

  @override
  void initState() {
    calcFinalResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);
        Get.back(result: true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back(result: true);
              Get.back(result: true);
            },
            icon: Icon(Ionicons.arrow_forward),
          ),
        ),
        body: ListView(
          children: [
            ...List.generate(
                widget.question.length,
                (index) => ListTile(
                      //title: Text("${index + 1}"),
                      title: Text(
                          "${MyFunctions.convertNumber((index + 1).toString(), GetStorage().read('lang'))}"),
                      //subtitle:Text("عدد النقاط: ${widget.answers[index] ? 5 : 0}"),
                      subtitle: Text(
                          "عدد النقاط: ${MyFunctions.convertNumber((widget.answers[index] ? 5 : 0).toString(), GetStorage().read('lang'))}"),
                      // trailing: Text("${widget.levelTime - widget.answersTime[index]} ثانية"),
                      trailing: Text(
                          "${MyFunctions.convertNumber((widget.levelTime - widget.answersTime[index]).toString(), GetStorage().read('lang'))} ثانية"),

                      leading: CircleAvatar(
                        backgroundColor:
                            widget.answers[index] ? Colors.green : Colors.red,
                        child: widget.answers[index]
                            ? const Icon(Ionicons.checkmark)
                            : const Icon(Ionicons.close),
                      ),
                    )),
            const Divider(),
            ListTile(
              title: Text("الوقت الاجمالى"),
              // trailing:Text("${widget.question.length * widget.levelTime} ثانية"),
              trailing: Text(
                  "${MyFunctions.convertNumber((widget.question.length * widget.levelTime).toString(), GetStorage().read('lang'))} ثانية"),
            ),
            ListTile(
              title: Text("الوقت المستغرق"),
              //trailing: Text("$finalResult ثانية"),
              trailing: Text(
                  "${MyFunctions.convertNumber(finalResult, GetStorage().read('lang'))} ثانية"),
            ),
            ListTile(
              title: Text("النسبة المئوية"),
              //subtitle: Text("$percentOfResult"),
              trailing: Text(
                  "${MyFunctions.convertNumber(percentOfResult, GetStorage().read('lang'))} %"),
            ),
            ListTile(
              title: Text("النسبة المئوية للنقاط"),
              //subtitle: Text("${percentOfPoint.toStringAsFixed(2)}"),
              trailing: Text(
                  "${MyFunctions.convertNumber(percentOfPoint.toStringAsFixed(2), GetStorage().read('lang'))} %"),
            ),
            ListTile(
              title: Text("عدد النقاط"),
              //subtitle: Text("${totalPoint.toString()}"),
              trailing: Text(
                  "${MyFunctions.convertNumber(totalPoint.toString(), GetStorage().read('lang'))}"),
            ),
          ],
        ),
      ),
    );
  }
}
