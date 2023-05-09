import 'package:arti_eyes/services/chat_model.dart';
import 'package:arti_eyes/services/chatgpt_api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchEngineTab extends StatefulWidget {
  const SearchEngineTab({Key? key}) : super(key: key);

  @override
  State<SearchEngineTab> createState() => _SearchEngineTabState();
}

class _SearchEngineTabState extends State<SearchEngineTab> {

  TextEditingController userInputTextEditingController = TextEditingController();
  final SpeechToText _speechToTextInstance = SpeechToText();
  var recordedAudioString = "Hold The Screen to record";
  bool isListening = false;
  final List<ChatMessage> chatMessages = [];
  var scrollController = ScrollController();
  FlutterTts _flutterTts = FlutterTts();

  scrollMethod(){
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: (){

        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
              "images/sound (2).png"
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTapDown: (details) async{
                if(!isListening){
                  var available = await _speechToTextInstance.initialize();
                  if(available){
                    setState(() {
                      isListening = true;
                      _speechToTextInstance.listen(
                          onResult: (result){
                            setState(() {
                              recordedAudioString = result.recognizedWords;
                              print(recordedAudioString);
                            });
                          }
                      );
                    });
                  }
                }
              },

              onTapUp: (details) async{
                if(isListening)
                {
                  setState(() {
                    isListening = false;
                  });
                  await _speechToTextInstance.stop();

                  if(recordedAudioString.isNotEmpty && recordedAudioString != "Hold The Screen to record")
                  {
                    chatMessages.add(
                      ChatMessage(
                          text: recordedAudioString,
                          type: ChatMessageType.user
                      ),
                    );

                    var chatGptResponse = await ApiServices.sendMessage(recordedAudioString);
                    setState(() {
                      chatMessages.add(
                        ChatMessage(
                            text: chatGptResponse,
                            type: ChatMessageType.bot
                        ),
                      );
                    });

                    Future.delayed(
                        const Duration(milliseconds:500),(){
                          _flutterTts.speak(chatGptResponse);
                        }
                    );
                  }else{
                    String failed = "Failed to process, Please Try again!";
                    Fluttertoast.showToast(
                        msg: failed
                    );
                    _flutterTts.speak(failed);
                  }
                }
              },

              child: Center(
                child: isListening == false
                    ? Image.asset(
                  "images/speech commands.png",
                  height: 100,
                  width: 100,
                )
                    : Center(
                    child: LoadingAnimationWidget.beat(
                        size: 300,
                        color: isListening
                            ? const Color.fromARGB(255, 3, 152, 158)
                            : isListening
                            ? const Color.fromARGB(255, 90, 150, 150)
                            : const Color.fromARGB(255, 3, 152, 188)
                    )
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: chatMessages.length,
                    itemBuilder: (BuildContext context, int index){
                      var chat = chatMessages[index];
                      return chatBubble(
                        chatText: chat.text,
                        chatMessageType: chat.type
                      );
                    }
                ),
              ),
            ),



            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: SingleChildScrollView(
                  child: Text(
                    recordedAudioString,
                    style:const TextStyle(
                        backgroundColor: Colors.transparent,
                        fontSize: 10.0,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget chatBubble({required chatText, required ChatMessageType? chatMessageType}){
  return Container(
    child: chatMessageType == ChatMessageType.user
        ?Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.person,
            color: Colors.white,
          )
        ),
        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              "$chatText",
              style: const TextStyle(
                  color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),
      ],
    )
    :Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              "$chatText",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        CircleAvatar(
          backgroundColor: Colors.green,
          child: Image.asset(
              "images/bot.png"
          ),
        ),
      ],
    ),
  );
}

//chatgptapi key =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;
