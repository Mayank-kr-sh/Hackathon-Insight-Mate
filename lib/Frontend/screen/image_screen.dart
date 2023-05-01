import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../Backend/constants/constants.dart';
import '../../Backend/del_e.dart/image_widget.dart';
import '../../Backend/providers/chats_provider.dart';
import '../../Backend/services/services.dart';
import '../../Backend/widgets/text_widget.dart';
import '../../Backend/providers/models_provider.dart';
import '../../Backend/providers/images_provider.dart';
import '../../assets_manager.dart';

class ImageScreen extends StatefulWidget {
  static const routeName = '/image-screen';
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    // final modelsProvider = Provider.of<ModelsProvider>(context);
    // final chatProvider = Provider.of<ChatProvider>(context);
    final imagesProvider = Provider.of<ImagesProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xff20262E),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text(
          'Image Generator',
          style: TextStyle(
              fontFamily: 'Gotham',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 19),
        ),
        toolbarHeight: 70,
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded(child: Container(color: Colors.grey)),
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount:
                      imagesProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ImageWidget(
                      msg: imagesProvider
                          .getChatList[index].url, // chatList[index].msg,
                      chatIndex: imagesProvider.getChatList[index]
                          .imgIndex, //chatList[index].chatIndex,
                      shouldAnimate:
                          imagesProvider.getChatList.length - 1 == index,
                    );
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white),
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            await sendPrompt(
                              imagesProvider: imagesProvider,
                            );
                          },
                          decoration: const InputDecoration.collapsed(
                              hintText: "Write something to Generate Image..",
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await sendPrompt(
                              imagesProvider: imagesProvider,
                            );
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendPrompt({required ImagesProvider imagesProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      print(msg);
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        imagesProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });

      await imagesProvider.sendPromptAndGetImage(msg: msg);
      // chatList.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // chatList.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
