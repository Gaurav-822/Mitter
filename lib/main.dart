import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:morse_code_translator/morse_code_translator.dart';
import 'package:morse_lighter/flash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MorseEmitter',
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Morse Emitter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final player = AudioPlayer();
  var freq = 50; // frequency of the light (uptime) (default)

  var letter = '';
  var code = '';
  bool sos = false;
  bool stop = false;

  void morseToOutput(String input) async {
    for (int i = 0; i < input.length; i++) {
      // check for pause
      if (stop) {
        break;
      }

      MorseCode meroMorseCode = MorseCode();
      var output = meroMorseCode.enCode(input[i]);
      setState(() {
        if (sos) {
          letter = "<< SOS >>";
          code = '';
        } else {
          letter = input[i];
          code = output;
        }
      });

      for (int j = 0; j < output.length; j++) {
        // check for stop
        if (stop) {
          break;
        }

        var morse = output[j];
        // for dot
        if (morse == '.') {
          await delay(freq ~/ 2);
          turnOnFlash();
          await music(0);
          await delay(freq ~/ 2);
          turnOffFlash();
        }
        // for dash
        else if (morse == '-') {
          await delay((freq * 3) ~/ 2);
          turnOnFlash();
          await music(1);
          await delay((freq * 3) ~/ 2);
          turnOffFlash();
        }
      }
      // after completion of a letter, i.e space
      await delay(freq * 7 ~/ 2);
      turnOffFlash();
      await delay(freq * 7 ~/ 2);
    }
  }

  Future<void> music(int w) async {
    // 0 for dot.mp3 and 1 for dash.mp3
    AudioSource audioSource;
    if (w == 0) {
      audioSource = AudioSource.asset('assets/dot.mp3');
    } else {
      audioSource = AudioSource.asset('assets/dash.mp3');
    }
    await player.setAudioSource(audioSource);
    await player.play();
  }

  Future<void> delay(int millisec) async {
    await Future.delayed(Duration(milliseconds: millisec));
  }

  bool torch = false;
  bool slider = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () {
                    (torch) ? turnOffFlash() : turnOnFlash();
                    setState(() {
                      torch = !torch;
                    });
                  },
                  child: Icon(
                    (torch) ? Icons.flashlight_off : Icons.flashlight_on,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      slider = !slider;
                    });
                  },
                  child: const Icon(
                    Icons.tune_outlined,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/morse_chart.png',
                width: 300,
                height: 300,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                      visible: slider,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Frequency",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Slider(
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.transparent,
                                  min: 5,
                                  max: 100,
                                  value: freq.toDouble(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      freq = newValue.toInt();
                                    });
                                  },
                                ),
                              ),
                              // Padding(
                              //   padding: EdgeInsets.all(8),
                              //   child: GestureDetector(
                              //     child: const Icon(
                              //       Icons.flashlight_on,
                              //       size: 24,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                slider = !slider;
                              });
                            },
                            child: const Icon(
                              Icons.arrow_drop_up,
                              size: 36,
                            ),
                          )
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8, 0, 8, 0),
                            child: TextFormField(
                              onChanged: (text) {
                                setState(() {});
                              },
                              controller: _controller,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Text...',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    stop = false;
                                    sos = false;
                                    torch = false;
                                    if (_controller.text.isNotEmpty) {
                                      morseToOutput(_controller.text);
                                      // _controller.clear();
                                    } else {
                                      sos = true;
                                      morseToOutput("eeeoeee");
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(
                                    (_controller.text.isNotEmpty)
                                        ? Icons.send_rounded
                                        : Icons.sos,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.clear();
                              stop = true;
                            });
                          },
                          child: const Icon(
                            Icons.pause_rounded,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (letter.isNotEmpty) ? '$letter\n$code' : "Start Transmit",
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: const AlignmentDirectional(-1, 0),
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Container(
                      width: 30,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(22),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: const Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          'C\nH\nA\nR\nT',
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
