import 'package:alfred_4/feature_box.dart';
import 'package:alfred_4/openai_service.dart';
import 'package:alfred_4/pallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText= SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords= '';
  final OpenAIService openAIService= OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {
    });
  }
  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    setState(() {
    });
  }

  Future <void>  startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future <void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALFRED'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      // color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage(
                        'assets/images/man.png',
                      ))
                    )
                )
              ],
            ),
            Visibility(
              visible: generatedImageUrl==null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child:  Text(
                    generatedContent == null
                        ? 'Hello Master Wayne, how can I help you ?'
                        : generatedContent!,
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize:generatedContent == null? 25: 18,
                    ),
                  ),
                )
              ),
            ),
            if(generatedImageUrl!=null) Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(generatedImageUrl!),
            ),
            Visibility(
              visible: generatedContent==null && generatedImageUrl==null,
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                ),
                child: const Text('Here are a few features',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent==null && generatedImageUrl==null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText: 'A smart way to stay updated about things around you.',
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText: 'Bring your imagination into the world by generating its image.',
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Smart voice assistant',
                    descriptionText: 'Get everything with you personal voice assistant power with ChatGPT and Dall-E.'
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.secondSuggestionBoxColor,
        onPressed: () async {
          if(await speechToText.hasPermission && speechToText.isNotListening){
            await startListening();
          }else if(speechToText.isListening){
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if(speech.contains('https')){
              generatedImageUrl = speech;
              generatedContent= null;
              setState(() {

              });
            }else{
              generatedImageUrl = null;
              generatedContent= speech;
              await systemSpeak(speech);
              setState(() {

              });
            }

            await stopListening();
          }else {
            initSpeechToText();
          }
        },
        child: Icon(speechToText.isListening ? Icons.stop :  Icons.mic),
      ),
    );
  }
}
