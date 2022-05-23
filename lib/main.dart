import 'package:faisal_game/final_result.dart';
import 'package:faisal_game/levels/level_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    await GetStorage.init();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Faisal Game',
      locale: const Locale("ar"),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AudioPlayer player = AudioPlayer();
  // init state
  @override
  void initState() {
    GetStorage().writeIfNull("level", 1);
    GetStorage().writeIfNull("lang", "ar");
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              GetStorage().erase();
              GetStorage().write("level", 1);
              GetStorage().write("lang", "ar");

              setState(() {});
            },
            icon: const Icon(Ionicons.refresh)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                Center(
                  child: Text("لعبة جديدة",
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.black)),
                ),
                const SizedBox(
                  height: 32,
                ),
                ListTile(
                  onTap: () async {
                    var result = await Get.to(() => const LevelPage(
                          level: 1,
                        ));

                    if (result != null) {
                      setState(() {});
                    }
                  },
                  shape: const StadiumBorder(
                    side: BorderSide(
                      color: Colors.amber,
                      width: 12,
                    ),
                  ),
                  tileColor: Colors.orange.shade100,
                  title: Text(
                    "المستوى 1",
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListTile(
                  onTap: GetStorage().read("level") < 2
                      ? null
                      : () async {
                          var result = await Get.to(
                            () => const LevelPage(
                              level: 2,
                            ),
                          );

                          if (result != null) {
                            setState(
                              () {},
                            );
                          }
                        },
                  shape: const StadiumBorder(
                    side: BorderSide(
                      color: Colors.black12,
                      style: BorderStyle.solid,
                      width: 15,
                    ),
                  ),
                  tileColor: GetStorage().read("level") < 2
                      ? Colors.grey
                      : Colors.deepOrange,
                  title: Text(
                    "المستوى 2",
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListTile(
                  onTap: GetStorage().read("level") < 3
                      ? null
                      : () async {
                          var result = await Get.to(() => const LevelPage(
                                level: 3,
                              ));
                          if (result != null) {
                            setState(() {});
                          }
                        },
                  shape: const StadiumBorder(
                    side: BorderSide(
                      color: Colors.black12,
                      width: 15,
                    ),
                  ),
                  tileColor: GetStorage().read("level") < 3
                      ? Colors.grey
                      : Colors.redAccent,
                  title: Text(
                    "المستوى 3",
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              "النتائج النهائية",
              textAlign: TextAlign.center,
            ),
            tileColor: Colors.green,
            onTap: () => Get.to(() => const FinalResult()),
          )
        ],
      ),
    );
  }
}
