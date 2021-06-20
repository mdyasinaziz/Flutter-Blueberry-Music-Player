import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import "playpage.dart";
import '../../Utility.dart';
import './ListItemWidget.dart';
import './NoDataWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'playpage.dart'; 

class SongListWidget extends StatelessWidget {
  List<SongInfo> songList; 
  FlutterAudioQuery audioQuery=FlutterAudioQuery();
  final bool addToPlaylistAction;
  SongListWidget({@required this.songList, this.addToPlaylistAction = true});

    int currentIndex=0;
  final GlobalKey<PlayPageState> key=GlobalKey<PlayPageState>();
  var tabbarController;
  var selectIndex = 0;
  final AudioPlayer player=AudioPlayer();

  void initState()  {
    initState();
    //tabbarController = TabController(vsync: this, initialIndex: 0, length: 2);
    initState();
    getTracks();
  }

  void getTracks() async  {
    songList=await audioQuery.getSongs();
    //setState( () {
      songList=songList;
    //});
  }


  void changeTrack(bool isNext) {
    if(isNext)  {
      if(currentIndex!=songList.length-1)  {
        currentIndex++;
      }
    } else  {
      if(currentIndex!=0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songList[currentIndex]);
  }


  @override
  Widget build(BuildContext context) {
  return ListView.builder(
    itemCount: songList.length,
    itemBuilder: (context, songIndex) {
      SongInfo song = songList[songIndex];
      return ListItemWidget(
          title: Text("${song.title}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("Artist: ${song.artist}"),
              Text(
                "Duration: ${Utility.parseToMinutesSeconds(int.parse(song.duration))}",
                style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
              ),                 
            ],
          ),
          onTap: ()  {
          currentIndex=songIndex;
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PlayPage(changeTrack: changeTrack,songInfo: songList[currentIndex],key: key)));
      },
          imagePath: song.albumArtwork,
          leading: (song.albumArtwork == null)
              ? FutureBuilder<Uint8List>(
                  future: audioQuery.getArtwork(
                      type: ResourceType.SONG,
                      id: song.id,
                      size: Size(100, 100)),
                  builder: (_, snapshot) {
                    if (snapshot.data == null)
                      return CircleAvatar(
                        child: CircularProgressIndicator(),
                      );

                    if (snapshot.data.isEmpty)
                      return CircleAvatar(
                        backgroundImage: AssetImage("assets/no_cover.png"),
                      );

                    return CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: MemoryImage(
                        snapshot.data,
                      ),
                    );
                  }): null);
    }); 
  }
    }    

//   @override
//   Widget build(BuildContext context) {
//     final FlutterAudioQuery audioQuery=FlutterAudioQuery();
//     //   return MaterialApp(
//     //   home: MyHomePage(title: ""),
//     // );
    
//   }
// }

// //typedef OnSelected = void Function(int index);

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;


//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage>
//     with SingleTickerProviderStateMixin {
  
//   //final List<SongInfo> songList;
//   // final String _dialogTitle = "Choose Playlist";
//   // final bool addToPlaylistAction;

//   // final GlobalKey<PlayPageState> key=GlobalKey<PlayPageState>();
//   // var tabbarController;
//   // var selectIndex = 0;    
  
//   // List<SongInfo> songList; 
//   // FlutterAudioQuery audioQuery=FlutterAudioQuery();
//   //List<SongInfo> songList;
//   int currentIndex=0;
//   final GlobalKey<PlayPageState> key=GlobalKey<PlayPageState>();
//   var tabbarController;
//   var selectIndex = 0;

//   void initState()  {
//     super.initState();
//     tabbarController = TabController(vsync: this, initialIndex: 0, length: 2);
//     super.initState();
//     getTracks();
//   }

//     void getTracks() async  {
//     songList=await audioQuery.getSongs();
//     setState(() {
//       songList=songList;
//     });
//   }
//   void changeTrack(bool isNext) {
//     if(isNext)  {
//       if(currentIndex!=songList.length-1)  {
//         currentIndex++;
//       }
//     } else  {
//       if(currentIndex!=0) {
//         currentIndex--;
//       }
//     }
//     key.currentState.setSong(songList[currentIndex]);
//   }


//   @override
//   Widget build(BuildContext context) {
//   return ListView.builder(
//     itemCount: songList.length,
//     itemBuilder: (context, songIndex) {
//       SongInfo song = songList[songIndex];
//       return ListItemWidget(
//           title: Text("${song.title}"),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               Text("Artist: ${song.artist}"),
//               Text(
//                 "Duration: ${Utility.parseToMinutesSeconds(int.parse(song.duration))}",
//                 style:
//                     TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
//               ),                 
//             ],
//           ),
//           onTap: ()  {
//           currentIndex=songIndex;
//           Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PlayPage(changeTrack: changeTrack,songInfo: songList[currentIndex],key: key)));
//       },
//           imagePath: song.albumArtwork,
//           leading: (song.albumArtwork == null)
//               ? FutureBuilder<Uint8List>(
//                   future: audioQuery.getArtwork(
//                       type: ResourceType.SONG,
//                       id: song.id,
//                       size: Size(100, 100)),
//                   builder: (_, snapshot) {
//                     if (snapshot.data == null)
//                       return CircleAvatar(
//                         child: CircularProgressIndicator(),
//                       );

//                     if (snapshot.data.isEmpty)
//                       return CircleAvatar(
//                         backgroundImage: AssetImage("assets/no_cover.png"),
//                       );

//                     return CircleAvatar(
//                       backgroundColor: Colors.transparent,
//                       backgroundImage: MemoryImage(
//                         snapshot.data,
//                       ),
//                     );
//                   }): null);
//     }); 
//   }
//     }    


// // class PlaylistDialogContent extends StatefulWidget {
// //   final List<String> options;
// //   final OnSelected onSelected;
// //   final int initialIndexSelected;

// //   PlaylistDialogContent(
// //       {@required this.options, this.onSelected, this.initialIndexSelected});

// //   @override
// //   _PlaylistDialogContentState createState() => _PlaylistDialogContentState();
// // }

// // class _PlaylistDialogContentState extends State<PlaylistDialogContent> with SingleTickerProviderStateMixin{
// //   int selectedIndex;

// //   @override
// //   void initState() {
// //     super.initState();
// //     selectedIndex = widget.initialIndexSelected;
// //   }

// //   // @override
// //   // Widget build(BuildContext context) {
// //   //   return ListView.builder(
// //   //       shrinkWrap: true,
// //   //       itemCount: widget.options.length,
// //   //       itemBuilder: (context, index) {
// //   //         return RadioListTile(
// //   //             title: Text(widget.options[index]),
// //   //             value: index,
// //   //             groupValue: selectedIndex,
// //   //             onChanged: (value) {
// //   //               setState(() {
// //   //                 selectedIndex = value;
// //   //               });
// //   //               if (widget.onSelected != null) widget.onSelected(selectedIndex);
// //   //             });
// //   //       });
// //   // }
// // }
