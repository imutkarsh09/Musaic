import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:musaic/Models/radio.dart';
import 'package:musaic/Utils/ai_util.dart';
import "package:velocity_x/velocity_x.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios = List.empty();
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  bool isPlaying = false;

  final AudioPlayer audioPlayer = new AudioPlayer();
  @override
  void initState() {
    super.initState();
    fetchRadios();

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        isPlaying = true;
      } else
        isPlaying = false;

      setState(() {});
    });
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("lib/Assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    setState(() {});
    print(radios);
    print("Length------>");
    print(radios.length);
  }

  _playMusic(String url) {
    audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const Drawer(),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AiColor.primaryColor2,
                    _selectedColor ?? AiColor.primaryColor1,
                  ],
                ))
                .make(),
            AppBar(
              title: "musAIc".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300,
                    secondaryColor: Vx.white,
                  ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100).p16(),
            radios.length != 0
                ? VxSwiper.builder(
                    aspectRatio: 1.0,
                    onPageChanged: (index) {
                      final colorHex = radios[index].color;
                      _selectedColor = Color();
                      setState(() {});
                    },
                    itemCount: radios.length,
                    enlargeCenterPage: true,
                    itemBuilder: (context, index) {
                      print(radios);
                      print("hello");
                      print(radios[0]);
                      final rad = radios[index];

                      return VxBox(
                              child: ZStack([
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                            child:
                                rad.category.text.uppercase.white.make().px16(),
                          )
                              .height(40)
                              .black
                              .alignCenter
                              .withRounded(value: 10.0)
                              .make(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl.white.bold.make(),
                              5.heightBox,
                              rad.tagline.text.sm.white.semiBold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: [
                            const Icon(
                              CupertinoIcons.play_circle,
                              color: Colors.white,
                            ),
                            10.heightBox,
                            "Double tap to play".text.gray300.make(),
                          ].vStack(),
                        )
                      ]))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken),
                          ))
                          .border(color: Colors.black, width: 5.0)
                          .withRounded(value: 60)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM"
                      .text
                      .white
                      .makeCentered(),
                const Icon(
                  true
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 50.0,
                ).onInkTap(() {
                  if (isPlaying) {
                    audioPlayer.stop();
                  } else {
                    _playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
          clipBehavior: Clip.antiAlias,
        ));
  }
}
