// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
//
// import '../../widget/theme.dart';
//
// class AudioDetails extends StatefulWidget {
//   final List learningAudioData;
//   final String name;
//   final int id;
//
//   const AudioDetails({Key key, this.learningAudioData, this.name, this.id}) : super(key: key);
//
//   @override
//   _AudioDetailsState createState() => _AudioDetailsState();
// }
//
// class _AudioDetailsState extends State<AudioDetails> {
//   final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
//   List<AssetsAudioPlayer> players = [];
//
//   @override
//   void initState() {
//     _assetsAudioPlayer.playlistFinished.listen((data) {});
//     _assetsAudioPlayer.playlistAudioFinished.listen((data) {});
//     _assetsAudioPlayer.current.listen((data) {});
//     super.initState();
//
//     widget.learningAudioData.map(
//       (audio) {
//         audio['player'] = new AssetsAudioPlayer();
//       },
//     ).toList();
//   }
//
//   @override
//   void dispose() {
//     _assetsAudioPlayer.stop();
//     _assetsAudioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(capitalize(widget.name))),
//       body: ListView.builder(
//         shrinkWrap: true,
//         itemCount: widget.learningAudioData.length,
//         itemBuilder: (BuildContext context, int index) {
//           return PlayerWidget(
//             myAudio: widget.learningAudioData[index],
//             index: index.toString(),
//             player: widget.learningAudioData[index]['player'],
//             allData: widget.learningAudioData,
//             callback: (value) {},
//           );
//         },
//       ),
//     );
//   }
// }
//
// class PlayerWidget extends StatefulWidget {
//   final Map myAudio;
//   final List allData;
//   final String index;
//   final callback;
//   final AssetsAudioPlayer player;
//
//   @override
//   _PlayerWidgetState createState() => _PlayerWidgetState();
//
//   const PlayerWidget({
//     @required this.myAudio,
//     this.index,
//     this.callback,
//     this.player,
//     this.allData,
//   });
// }
//
// class _PlayerWidgetState extends State<PlayerWidget> {
//   bool _isViewMore = false;
//
//   String playerId;
//
//   @override
//   void dispose() {
//     widget.player.stop();
//     widget.player.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: widget.player.loopMode,
//       initialData: false,
//       builder: (context, snapshotLooping) {
//         return StreamBuilder(
//           stream: widget.player.isPlaying,
//           initialData: false,
//           builder: (context, snapshotPlaying) {
//             final isPlaying = snapshotPlaying.data;
//             return Neumorphic(
//               margin: EdgeInsets.all(8),
//               style: NeumorphicStyle(
//                 boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
//               ),
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       Expanded(
//                         flex: 3,
//                         child: Row(
//                           children: <Widget>[
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Neumorphic(
//                                 style: NeumorphicStyle(
//                                   boxShape: NeumorphicBoxShape.circle(),
//                                   depth: 8,
//                                   surfaceIntensity: 1,
//                                   shape: NeumorphicShape.concave,
//                                 ),
//                                 child: Image.network(
//                                   widget.myAudio['thumbnail'],
//                                   height: 50,
//                                   width: 50,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   this.widget.myAudio['title'],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: PlayingControlsSmall(
//                           onStop: () {
//                             widget.player.stop();
//                           },
//                           isPlaying: isPlaying,
//                           toggleLoop: () {
//                             widget.player.toggleLoop();
//                           },
//                           onPlay: () {
//                             widget.allData.map((audio) {
//                               if (widget.allData.indexOf(audio).toString() != widget.index) {
//                                 audio['player'].stop();
//                               }
//                             }).toList();
//
//                             if (widget.player.current.value == null) {
//                               widget.player.open(
//                                 Audio.network(widget.myAudio['file']),
//                                 autoStart: true,
//                                 showNotification: false,
//                                 playInBackground: PlayInBackground.disabledPause,
//                                 phoneCallStrategy: PhoneCallStrategy.pauseOnPhoneCallResumeAfter,
//                                 headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
//                                 respectSilentMode: true,
//                               );
//                             } else {
//                               widget.player.playOrPause();
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   StreamBuilder(
//                     stream: widget.player.realtimePlayingInfos,
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return Container();
//                       }
//                       RealtimePlayingInfos infos = snapshot.data;
//                       return PositionSeekWidget(
//                         seekTo: (to) {
//                           widget.player.seek(to);
//                         },
//                         duration: infos.duration,
//                         currentPosition: infos.currentPosition,
//                       );
//                     },
//                   ),
//                   Text(
//                     widget.myAudio['description'],
//                     maxLines: !_isViewMore ? 2 : 999,
//                     overflow: !_isViewMore ? TextOverflow.fade : TextOverflow.visible,
//                     style: TextStyle(),
//                   ),
//                   if (widget.myAudio['description'].length > 90)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: <Widget>[
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _isViewMore = !_isViewMore;
//                             });
//                           },
//                           child: Text(
//                             !_isViewMore ? "View More" : "Less",
//                           ),
//                         ),
//                       ],
//                     )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class PositionSeekWidget extends StatefulWidget {
//   final Duration currentPosition;
//   final Duration duration;
//   final Function(Duration) seekTo;
//
//   const PositionSeekWidget({
//     @required this.currentPosition,
//     @required this.duration,
//     @required this.seekTo,
//   });
//
//   @override
//   _PositionSeekWidgetState createState() => _PositionSeekWidgetState();
// }
//
// class _PositionSeekWidgetState extends State<PositionSeekWidget> {
//   Duration _visibleValue;
//   bool listenOnlyUserInteraction = false;
//
//   double get percent => widget.duration.inMilliseconds == 0
//       ? 0
//       : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;
//
//   @override
//   void initState() {
//     super.initState();
//     _visibleValue = widget.currentPosition;
//   }
//
//   @override
//   void didUpdateWidget(PositionSeekWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!listenOnlyUserInteraction) {
//       _visibleValue = widget.currentPosition;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(7.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Expanded(
//             flex: 0,
//             child: SizedBox(
//               width: 45,
//               child: Text(durationToString(widget.currentPosition)),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Slider(
//               inactiveColor: Colors.pink,
//               value: percent * widget.duration.inMilliseconds.toDouble(),
//               min: 0.0,
//               max: widget.duration.inMilliseconds.toDouble(),
//               onChangeEnd: (newValue) {
//                 setState(
//                   () {
//                     listenOnlyUserInteraction = false;
//                     widget.seekTo(_visibleValue);
//                   },
//                 );
//               },
//               onChangeStart: (_) {
//                 setState(
//                   () {
//                     listenOnlyUserInteraction = true;
//                   },
//                 );
//               },
//               onChanged: (newValue) {
//                 setState(
//                   () {
//                     final to = Duration(milliseconds: newValue.floor());
//                     _visibleValue = to;
//                   },
//                 );
//               },
//             ),
//           ),
//           SizedBox(
//             width: 45,
//             child: Text(durationToString(widget.duration)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// String durationToString(Duration duration) {
//   String twoDigits(int n) {
//     if (n >= 10) return "$n";
//     return "0$n";
//   }
//
//   String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
//   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
//   return "$twoDigitMinutes:$twoDigitSeconds";
// }
//
// class PlayingControlsSmall extends StatelessWidget {
//   final bool isPlaying;
//   final LoopMode loopMode;
//   final Function() onPlay;
//   final Function() onStop;
//   final Function() toggleLoop;
//
//   PlayingControlsSmall({
//     @required this.isPlaying,
//     this.loopMode,
//     this.toggleLoop,
//     @required this.onPlay,
//     this.onStop,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         NeumorphicButton(
//           style: NeumorphicStyle(
//             boxShape: NeumorphicBoxShape.circle(),
//           ),
//           padding: EdgeInsets.all(16),
//           onPressed: this.onPlay,
//           child: Icon(
//             isPlaying ? Icons.pause : Icons.play_arrow,
//             size: 32,
//           ),
//         ),
//         SizedBox(width: 12),
//         if (onStop != null)
//           NeumorphicButton(
//             style: NeumorphicStyle(
//               boxShape: NeumorphicBoxShape.circle(),
//             ),
//             padding: EdgeInsets.all(16),
//             onPressed: this.onStop,
//             child: Icon(
//               Icons.stop,
//               size: 18,
//             ),
//           ),
//       ],
//     );
//   }
// }
