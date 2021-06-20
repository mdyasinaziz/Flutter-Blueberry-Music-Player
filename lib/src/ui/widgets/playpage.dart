import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'dart:async';
//import 'package:audioplayer/audioplayer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'SongListWidget.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);


class PlayPage extends StatefulWidget {
 //@override
    SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<PlayPageState> key;
  final FlutterAudioQuery audioQuery=FlutterAudioQuery();
  PlayPage({this.songInfo,this.changeTrack,this.key}):super(key: key);
  PlayPageState createState() => PlayPageState(); 

}

class PlayPageState extends State<PlayPage> {
  String _counter = "old";
  double minimumValue=0.0, maximumValue=0.0, currentValue=0.0;
  String currentTime='', endTime='';
  bool isPlaying=false;
  final AudioPlayer player=AudioPlayer();
  final FlutterAudioQuery audioQuery=FlutterAudioQuery();
  PlaybackState _state;
  StreamSubscription _playbackStateSubscription;

  void initState() {
  printDetail();
  super.initState();
  setSong(widget.songInfo);
  connect();
  }

  void printDetail() async{  
    //final prefs2 = await SharedPreferences.getInstance();
    
    //prefs2.setString('counter2', widget.songInfo.artist); 
    
    // print (widget.songInfo.title);
    // print (widget.songInfo.artist);
  }

  void dispose()  { 
    disconnect();
    super.dispose();
    player?.dispose(); 
  }   


  void connect() async {
    await AudioService.connect();
    if (_playbackStateSubscription == null) {
      _playbackStateSubscription = AudioService.playbackStateStream
          .listen((PlaybackState playbackState) {
        setState(() {
          _state = playbackState;
        });
      });
    }
audioPlayerButton(); 
  }

  void disconnect() {
    if (_playbackStateSubscription != null) {
      _playbackStateSubscription.cancel();
      _playbackStateSubscription = null;
    }
    AudioService.disconnect();
  }

  void setSong(SongInfo songInfo) async {
    // final prefs = await SharedPreferences.getInstance();
    // _counter = (prefs.getString('counter') ?? 0);  
    // print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111");
    // // final prefs = await SharedPreferences.getInstance();
    // // final counter = prefs.getString('counter') ?? "nothing";
    // // print (counter); 

    // // prefs.setString('counter', widget.songInfo.title);

    // // //final prefsRead = await SharedPreferences.getInstance();
    // // //final songWas = prefsRead.getString('counter') ?? 0;
    // // //final artistWas = prefsRead.getString('counter2') ?? 0;
    
    // // //print (songWas);
    // // //print (artistWas); 
    // print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!2222");

    widget.songInfo=songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue=minimumValue;
    maximumValue=player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime=getDuration(currentValue);
      endTime=getDuration(maximumValue);
    });
    isPlaying=false; 
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue=duration.inMilliseconds.toDouble();
      setState(() {
        currentTime=getDuration(currentValue);
      });
    });
  }


void changeStatus() async{
  //final prefs = await SharedPreferences.getInstance();
  //prefs.setString('counter', widget.songInfo.title);

    setState(() {
      isPlaying=!isPlaying; 
    });
    if(isPlaying) {
      player.play();
      audioPlayerButton();
    } else  {
      player.pause();
      audioPlayerButton();
    }
  }

  String getDuration(double value)  {
    Duration duration=Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds].map((element)=>element.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
    margin: EdgeInsets.fromLTRB(5, 57, 5, 0),
    padding: EdgeInsets.only(top: 120.0),
    child: Column(children:<Widget>[
          (widget.songInfo.albumArtwork == null) ?         FutureBuilder<Uint8List>(
                  future: audioQuery.getArtwork(
                      type: ResourceType.SONG,
                      id: widget.songInfo.id,
                      size: Size(200, 200)),
                  builder: (_, snapshot) {
                    if (snapshot.data == null)
                      return CircleAvatar(
                        child: CircularProgressIndicator(),
                      );

                    if (snapshot.data.isEmpty)
                      return CircleAvatar(
                        backgroundImage: AssetImage("assets/no_cover.png"),radius: 100,
                      );

                    return CircleAvatar(
                      backgroundColor: Colors.transparent, 
                      backgroundImage: MemoryImage(
                        snapshot.data,
                      ), radius: 100,
                    );
                  }):null ,

  
Container( margin: EdgeInsets.fromLTRB(0, 20, 0, 0),child: Text(widget.songInfo.title, style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w600),
),),
Container( margin: EdgeInsets.fromLTRB(0, 0, 0, 33),child: Text(widget.songInfo.artist, style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w500),
),),
Slider(inactiveColor: Colors.black,activeColor: Colors.black,min: minimumValue,max: maximumValue,value: currentValue,onChanged: (value) {
  currentValue=value;
  player.seek(Duration(milliseconds: currentValue.round()));
},),
Container(transform: Matrix4.translationValues(0, -15, 0),margin: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
  Text(currentTime, style: TextStyle(color: Colors.black, fontSize: 12.5, fontWeight: FontWeight.w500)),
  Text(endTime, style: TextStyle(color: Colors.black, fontSize: 12.5, fontWeight: FontWeight.w500))
],),),
Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
 GestureDetector(child: Icon(Icons.skip_previous, color: Colors.black, size: 55), behavior: HitTestBehavior.translucent,onTap: () {
  widget.changeTrack(false);
 },),
  GestureDetector(child: Icon(isPlaying?Icons.pause_circle_filled_rounded:Icons.play_circle_fill_rounded, color: Colors.black, size: 85), behavior: HitTestBehavior.translucent,onTap: () {
    audioPlayerButton();
    changeStatus();
    if (isPlaying) {
      playButton();
      AudioService.play;
    }
    else {
      pauseButton(); 
      AudioService.pause;
    }
 },),
  GestureDetector(child: Icon(Icons.skip_next, color: Colors.black, size: 55), behavior: HitTestBehavior.translucent,onTap: () {
    widget.changeTrack(true);
 },),
],),),
        ]),
      ),

          );
  }


  audioPlayerButton(){
          AudioService.start(
            backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
            androidNotificationChannelName: 'Abirs Service Demo',
            // Enable this if you want the Android service to exit the foreground state on pause.
            //androidStopForegroundOnPause: true,
            androidNotificationColor: 0xFF2196f3,
            //androidNotificationIcon: 'mipmap/ic_launcher',
            androidEnableQueue: true,
          );
        }

  startButton(String label, VoidCallback onPressed) =>
      ElevatedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );      

}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => CustomAudioPlayer());
}


class CustomAudioPlayer extends BackgroundAudioTask {
  SongInfo songInfo;
  Function changeTrack;

  final FlutterAudioQuery audioQuery=FlutterAudioQuery();
  CustomAudioPlayer({this.songInfo,this.changeTrack});
  double minimumValue=0.0, maximumValue=0.0, currentValue=0.0;
  String currentTime='', endTime='';
  bool isPlaying=false;
  final AudioPlayer player=AudioPlayer();
  FlutterAudioQuery audioQuery1=FlutterAudioQuery();
  PlaybackState _state;
  StreamSubscription _playbackStateSubscription;

  List<SongInfo> songList; 

  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();

  void setSong(SongInfo songInfo) async {
    songInfo=songInfo;
    await player.setUrl(songInfo.uri);
    currentValue=minimumValue;
    maximumValue=player.duration.inMilliseconds.toDouble();
    
    // changetrackhere(() {
    //   currentTime=getDuration(currentValue);
    //   endTime=getDuration(maximumValue);
    // });
    isPlaying=false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue=duration.inMilliseconds.toDouble();
      // changetrackhere(() {
      //   currentTime=getDuration(currentValue);
      // });
    });
  }

  void changeStatus() {
    if(isPlaying) {
      player.play();
      AudioService.play;
    } else  {
      player.pause();
      AudioService.pause; 
    }
  }

  String getDuration(double value)  {
    Duration duration=Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds].map((element)=>element.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async { 
  final mediaItem = MediaItem(
    id: this.songInfo.uri,
    album: "Foo",
    title: "Bar",
  );
  // Tell the UI and media notification what we're playing.
  AudioServiceBackground.setMediaItem(mediaItem);
  // Listen to state changes on the player...
  player.playerStateStream.listen((playerState) {
    // ... and forward them to all audio_service clients.
    AudioServiceBackground.setState(
      playing: playerState.playing,
      // Every state from the audio player gets mapped onto an audio_service state.
      processingState: {
        ProcessingState.none: AudioProcessingState.none,
        ProcessingState.loading: AudioProcessingState.connecting,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[playerState.processingState],
      // Tell clients what buttons/controls should be enabled in the
      // current state.
      controls: [
        playerState.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
      ],
    );
  });
  // Play when ready.
  player.play();
  onPlay();
  // Start loading something (will play when ready).
  await player.setUrl(mediaItem.id);
}

  void play() {
    _audioPlayer.play(); 
  }

  void pause() {
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

    @override
  Future<void> onPlay() => _audioPlayer.play();

  @override
  Future<void> onPause() => _audioPlayer.pause();

  @override
  Future<void> onSeekTo(Duration position) => _audioPlayer.seek(position);

    @override
  Future<void> onStop() async {
    await _audioPlayer.dispose();
    // Shut down this task
    await super.onStop();
  }


}





