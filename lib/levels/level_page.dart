import 'dart:async';
import 'dart:convert';

import 'package:faisal_game/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';

class LevelPage extends StatefulWidget {
  final int level;
  const LevelPage({Key? key, required this.level}) : super(key: key);

  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  bool isLoading = true;

  late List questions;
// دى الحروف الانجليزية
  List listOfEnChars = "azertyuiopqsdfghjklmwxcvbn".split("");
// دى العربية
  List listOfArChars = "دجحخهعغفقثصضطكمنتالبيسشظزوةىرؤءئ".split("");
// الحقل النصى  ده  لستة بنشيل  فيها الانبوت
  List userInput = [];

  List answers = [];

  List answersTime = [];

  final _player = AudioPlayer();

  int currentQuestion = 1;

  late Timer _timer;

  late int _start, _qTime;

  loadJson() async {
    String data =
        await rootBundle.loadString("assets/levels/level${widget.level}.json");

    Map<String, dynamic> q = json.decode(data);

    questions = q["words"];

    _start = q["remaining_time"];
    _qTime = q["remaining_time"];

    questions.shuffle();

    setState(() {
      isLoading = false;
      _player.setAsset(GetStorage().read("lang") == "ar"
          ? questions[currentQuestion - 1]['sound_path_ar']
          : questions[currentQuestion - 1]['sound_path_en']);

      _player.play();
    });
  }

  void startTimer() {
    _player.play();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });

          checkIfCorrect(null, null);
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  checkIfCorrect(String? userInputText, String? answer) async {
    setState(
      () {
        _timer.cancel();
      },
    );

    if (currentQuestion < questions.length) {
      setState(() {
        answers.add(userInputText != null && answer != null
            ? userInputText == answer
            : false);

        answersTime.add(userInputText == null ? 0 : _start);

        listOfEnChars.shuffle();
        listOfArChars.shuffle();
        userInput = [];

        currentQuestion++;
        _player.setAsset(GetStorage().read("lang") == "ar"
            ? questions[currentQuestion - 1]['sound_path_ar']
            : questions[currentQuestion - 1]['sound_path_en']);

        _start = _qTime;
      });

      startTimer();
    } else {
      setState(() {
        answers.add(userInputText != null && answer != null
            ? userInputText == answer
            : false);

        answersTime.add(userInputText == null ? 0 : _start);
      });

      Get.to(() => ResultPage(
            question: questions,
            answers: answers,
            answersTime: answersTime,
            levelTime: _qTime,
            level: widget.level,
            player: _player,
          ));
    }
  }

  @override
  void initState() {
    listOfEnChars.shuffle();
    listOfArChars.shuffle();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await loadJson();
    });

    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back(result: true);
            Get.back(result: true);
            _player.dispose();
          },
          icon: const Icon(
            Ionicons.arrow_forward,
            color: Colors.red,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _timer.cancel();
                setState(() {
                  _start = _qTime;
                  userInput = [];
                });
                GetStorage().read("lang") == "ar"
                    ? setState(() {
                        GetStorage().write("lang", "en");
                        listOfEnChars.shuffle();
                        listOfArChars.shuffle();
                      })
                    : setState(() {
                        GetStorage().write("lang", "ar");
                        listOfEnChars.shuffle();
                        listOfArChars.shuffle();
                      });

                startTimer();
                _player.setAsset(GetStorage().read("lang") == "ar"
                    ? questions[currentQuestion - 1]['sound_path_ar']
                    : questions[currentQuestion - 1]['sound_path_en']);
                _player.play();
              },
              icon: const Icon(Ionicons.globe))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(child: Icon(Ionicons.checkmark)),
                          const Expanded(child: Icon(Ionicons.close)),
                          const Expanded(
                              child: Icon(Ionicons.stopwatch_outline)),
                          Expanded(child: Container()),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(
                            "${answers.where((element) => element == true).toList().length}",
                            textAlign: TextAlign.center,
                          )),
                          Expanded(
                              child: Text(
                            "${answers.where((element) => element == false).toList().length}",
                            textAlign: TextAlign.center,
                          )),
                          Expanded(
                              child: Text(
                            "$_start",
                            textAlign: TextAlign.center,
                          )),
                          Expanded(
                              child: Text(
                            "$currentQuestion/${questions.length}",
                            textAlign: TextAlign.center,
                          )),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.orange.shade100, width: 10),
                  ),
                  child: Stack(children: [
                    Center(
                      child: Image.asset(
                        questions[currentQuestion - 1]['image_path'],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () async {
                          await _player.setAsset(GetStorage().read("lang") ==
                                  "ar"
                              ? questions[currentQuestion - 1]['sound_path_ar']
                              : questions[currentQuestion - 1]
                                  ['sound_path_en']);

                          _player.play();
                        },
                        child: Card(
                          color: Colors.orange.shade100,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Ionicons.volume_high),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          tileColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            GetStorage().read("lang") == "ar"
                                ? questions[currentQuestion - 1]['english']
                                : questions[currentQuestion - 1]['arabic'],
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        tileColor: Colors.white,
                        title: Text(
                          "${userInput.join()}",
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ))
                    ],
                  ),
                ),
                GridView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  children: [
                    ...List.generate(
                      GetStorage().read("lang") == "ar"
                          ? listOfArChars.length
                          : listOfEnChars.length,
                      (i) {
                        var item = GetStorage().read("lang") == "ar"
                            ? listOfArChars[i]
                            : listOfEnChars[i];
                        return GestureDetector(
                          onTap: () {
                            String ans = GetStorage().read("lang") == "ar"
                                ? questions[currentQuestion - 1]['arabic']
                                    .toString()
                                    .toLowerCase()
                                : questions[currentQuestion - 1]['english']
                                    .toString()
                                    .toLowerCase();

                            userInput.length == ans.split("").length
                                ? null
                                : userInput.add(item);
                            // _player.setAsset('assets/sounds/keyboardsnd.mp3');
                            print(userInput);

                            setState(() {
                              // listOfEnChars.shuffle();
                              // listOfArChars.shuffle();
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.grey[400]!,
                                    spreadRadius: 1,
                                    offset: Offset(2, 2)),
                                const BoxShadow(
                                    color: Colors.white,
                                    spreadRadius: 1,
                                    offset: Offset(-2, -2)),
                              ],
                            ),
                            child: Card(
                              child: FittedBox(
                                child: Text(
                                  item,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        checkIfCorrect(
                          userInput.join(),
                          GetStorage().read("lang") == "ar"
                              ? questions[currentQuestion - 1]['arabic']
                                  .toString()
                                  .toLowerCase()
                              : questions[currentQuestion - 1]['english']
                                  .toString()
                                  .toLowerCase(),
                        );
                      },
                      child: const Card(
                        color: Colors.green,
                        child: Center(
                          child: Icon(
                            Ionicons.return_up_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (userInput.isNotEmpty) {
                            userInput.removeLast();
                            _player.setAsset('assets/sounds/keyboardsnd.mp3');
                          }
                        });
                      },
                      child: const Card(
                        color: Colors.red,
                        child: Center(
                          child: Icon(
                            Ionicons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
    );
  }
}
