import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import './CardItemWidget.dart';
import 'package:just_audio/just_audio.dart';

class ArtistListWidget extends StatelessWidget {
  final List<ArtistInfo> artistList;
  final _callback;

  ArtistListWidget(
      {@required this.artistList, onArtistSelected(final ArtistInfo info)})
      : _callback = onArtistSelected;

  @override
  Widget build(BuildContext context) {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 16.0),
        itemCount: artistList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          ArtistInfo artist = artistList[index];
          return Stack(
            children: <Widget>[
              (artist.artistArtPath == null)
                  ? FutureBuilder<Uint8List>(
                      future: audioQuery.getArtwork(
                          type: ResourceType.ARTIST, id: artist.id),
                      builder: (_, snapshot) {
                        if (snapshot.data == null)
                          return Container(
                            height: 450.0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        return CardItemWidget(
                          height: 250.0,
                          title: "Artist: ${artist.name}",
                          subtitle:
                              "Number of Albums: ${artist.numberOfAlbums}",
                          infoText: "Number of Songs: ${artist.numberOfTracks}",
                          backgroundImage: artist.artistArtPath,
                          rawImage: snapshot.data,
                        );
                      })
                  : CardItemWidget(
                      height: 150.0,
                      title: "Artist: ${artist.name}",
                      subtitle: "Number of Albums: ${artist.numberOfAlbums}",
                      infoText: "Number of Songs: ${artist.numberOfTracks}",
                      backgroundImage: artist.artistArtPath,
                    ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: () {
                    if (_callback != null) _callback(artist);
                    print("Artist clicked ${artist.name}");
                  }),
                ),
              ),
            ],
          );
        });
  }
}
