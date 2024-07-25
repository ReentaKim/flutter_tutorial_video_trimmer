import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tutorial_video_trimmer/view/preview.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerScreen extends StatefulWidget {
  final File file;

  const TrimmerScreen(this.file, {super.key});

  @override
  State<TrimmerScreen> createState() => _TrimmerScreenState();
}

class _TrimmerScreenState extends State<TrimmerScreen> {
  final _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() => _trimmer.loadVideo(videoFile: widget.file);

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Preview(outputPath),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);
        if (navigator.userGestureInProgress) {
          return;
        }

        navigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Video Trimmer'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            debugPrint('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                              content: Text(
                                'Video Saved successfully\n$outputPath',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          });
                        },
                  child: const Text('SAVE'),
                ),
                Expanded(child: VideoViewer(trimmer: _trimmer)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_MM_SS,
                      maxVideoLength: Duration(
                        seconds: _trimmer.videoPlayerController!.value.duration.inSeconds,
                      ),
                      editorProperties: TrimEditorProperties(
                        borderPaintColor: Colors.yellow,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.yellow.shade800,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(
                        thumbnailQuality: 10,
                      ),
                      onChangeStart: (startValue) => _startValue = startValue,
                      onChangeEnd: (endValue) => _endValue = endValue,
                      onChangePlaybackState: (isPlaying) => setState(() {
                        _isPlaying = isPlaying;
                      }),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
