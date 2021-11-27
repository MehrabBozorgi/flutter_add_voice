import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VoiceScreen extends StatefulWidget {
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  FilePickerResult? result;
  File? _file;
  var _value;
  var _fileName;
  var _fileSize;
  Uint8List? bytes;
  AudioPlayer player = AudioPlayer();

  Future getVoice_FilePicker() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp2', 'ogg', 'wav'],
      allowCompression: true,
    );

    _file = File(result!.files.single.path.toString());
    //Voice Size
    bytes = _file!.readAsBytesSync();
    final mb = bytes!.lengthInBytes / 1024 / 1024;

    setState(() {
      _value = _file;
      _fileName = result!.names;
      _fileSize = mb.toString().substring(0, 4);
    });

    print('============');
    print('${_value}');
    print('${_fileName}');
    print('${_fileSize}');

    print('============');
  }

  StreamSubscription<void>? _playerSub;

  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _playerSub = player.onPlayerCompletion.listen((event) {
      _clearPlayer();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _playerSub!.cancel();
    player.dispose();
  }

  void _clearPlayer() {
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  Future play() async {
    int result = await player.play(_file!.path, isLocal: true);
    if (result == 1) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future pause() async {
    int result = await player.pause();
    if (result == 1) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future resume() async {
    int result = await player.resume();
    if (result == 1) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'انتخاب صوت',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          actions: [
            _value != null || _fileName != null
                ? IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () {
                      setState(() {
                        _value = null;
                        _fileName = null;
                        _fileSize = null;
                      });
                    },
                  )
                : Text(''),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        getVoice_FilePicker();
                      },
                      child: _file == null || _fileName == null
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Icon(Icons.keyboard_voice_sharp,size: 150,)
                                ),
                                Text(
                                  'انتخاب',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            )
                          : Column(
                              children: [

                           Icon(Icons.keyboard_voice_sharp,size: 150,),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FloatingActionButton(
                                    elevation: 10,
                                    mini: true,

                                    child: (_isPlaying)
                                        ? Icon(Icons.pause,
                                           )
                                        : Icon(Icons.play_arrow,
                                            ),
                                    onPressed: () => _isPlaying
                                        ? pause()
                                        : _isPaused
                                            ? resume()
                                            : play(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              _fileName != null
                  ? _fileSize != null
                      ? Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _fileName
                                    .toString()
                                    .replaceAll('[', '')
                                    .replaceAll(']', ''),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Text(
                              '${_fileSize}MB',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        )
                      : Container()
                  : Container(),


            ],
          ),
        ),
      ),
    );
  }
}
