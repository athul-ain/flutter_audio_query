import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_query_example/src/bloc/BlocBase.dart';
import 'package:rxdart/rxdart.dart';

class NewPlaylistDialog extends StatefulWidget {
  @override
  _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {

  TextEditingController _textEditingController;
  final PlaylistDialogBloc bloc = PlaylistDialogBloc();

  bool creationStatus = false;
  @override
  void initState() {
    super.initState();
    _textEditingController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Playlist"),
      actions: <Widget>[
        StreamBuilder<PlaylistInfo>(
          stream: bloc.creationOutput,
          builder: (context, snapshot){
            return FlatButton(
              child: Text("Create"),
              onPressed: () async {
                bloc.createPlaylist( _textEditingController.text, context );
              },
            );

          }
        ),
      ],

      content: StreamBuilder<String>(
        stream: bloc.errorOutput,
        builder: (context, snapshot){
          return TextFormField(
            decoration: InputDecoration(
                hintText: 'Playlist name',
                errorText: snapshot.error,
            ),
            autofocus: true,
            controller: _textEditingController,
            maxLines: 1,
            minLines: 1,

          );
        },
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class PlaylistDialogBloc extends BlocBase {
  final PublishSubject<String> _errorController = new PublishSubject();
  Observable<String> get errorOutput => _errorController.stream;

  final PublishSubject<PlaylistInfo> _creationController = new PublishSubject();
  Observable<PlaylistInfo> get creationOutput => _creationController.stream;

  createPlaylist(final String playlistName, BuildContext context) async {

    if (playlistName.isEmpty)
      _errorController.sink.addError("Playlist name is empty!");

    else {
      FlutterAudioQuery.createPlaylist(playlistName: playlistName)
          .then((data) {
          Navigator.pop(context, data);
      })
          .catchError((error) {
        _errorController.sink.addError(
            "Was not able create the playlist. Maybe Already exists a"
                " playlist with same name.");
        // _errorController.sink.addError(error.toString());
      });
    }
  }

  @override
  void dispose() {
    _errorController?.close();
    _creationController?.close();
  }
}