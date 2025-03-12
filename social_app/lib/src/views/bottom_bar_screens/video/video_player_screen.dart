
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../models/video_model/video_keywords.dart';
import '../../../myapp.dart';
import '../../../widgets/shimmer_loader.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String videoDes;
  final String videoTitle; // Pass the current video's title
  final List<DocumentSnapshot> relatedVideos; // Pass related videos

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.relatedVideos, required this.videoDes,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final CacheManager _cacheManager = CacheManager(Config('youtube_cache'));
  late TextEditingController _resolutionController;
  List<DocumentSnapshot> _relatedVideos = []; // Store related videos
  bool _isFullscreen = false;
  bool _isLoadingRelatedVideos = false;
  bool _hasError = false;
  String _errorMessage = '';
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        forceHD: false,
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(() {
      if (_controller.value.isFullScreen != _isFullscreen) {
        setState(() {
          _isFullscreen = _controller.value.isFullScreen;
        });
      }
    });

    _resolutionController = TextEditingController();
    _fetchRelatedVideos(); // Fetch related videos when the screen loads
  }

  /// Fetch related videos based on the current video's title

  void _fetchRelatedVideos() async {
    setState(() {
      _isLoadingRelatedVideos = true;
      _hasError = false;
    });

    try {
      // Extract keywords from the current video's title
      final keywords = _extractKeywords(widget.videoDes);
      print("Extracted Keywords: $keywords"); // Debug statement

      // Break the keywords into chunks of 10 (Firestore's `whereIn` limit)
      final keywordChunks = _chunkKeywords(keywords);

      // Fetch videos that match any of the keywords
      final List<DocumentSnapshot> allVideos = [];
      for (final chunk in keywordChunks) {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('saved_videos')
            .where('title', arrayContainsAny:  chunk) // Filter by keywords
            .get();

        allVideos.addAll(snapshot.docs);
      }

      print("Fetched ${allVideos.length} related videos");  // Debug statement

      setState(() {
        _relatedVideos = allVideos;
        _isLoadingRelatedVideos = false;
      });
    } catch (e) {
      print("Error fetching related videos: $e"); // Debug statement
      setState(() {
        _isLoadingRelatedVideos = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      _refreshController.refreshCompleted();
    }
  }


  List<String> _extractKeywords(String title) {
    // Define a list of common keywords
    var keywords = videoKeywords;

    // Find matching keywords in the title
    return keywords
        .where((keyword) => title.toLowerCase().contains(keyword))
        .toList();
  }

  // Break the keywords into chunks of 10
  List<List<String>> _chunkKeywords(List<String> keywords) {
    const chunkSize = 10; // Firestore's `whereIn` limit
    final List<List<String>> chunks = [];
    for (var i = 0; i < keywords.length; i += chunkSize) {
      chunks.add(keywords.sublist(
          i, i + chunkSize > keywords.length ? keywords.length : i + chunkSize));
    }
    return chunks;
  }

  void _onRefresh() async {
    _fetchRelatedVideos();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
        title: SizedBox(
            width: 180,
            child: Text(
              widget.videoTitle,
              style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
            )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Playing Video
          YoutubePlayerBuilder(
            onEnterFullScreen: () {
              setState(() => _isFullscreen = true);
            },
            onExitFullScreen: () {
              setState(() => _isFullscreen = false);
            },
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              onReady: () {
                // Fetch available resolutions when the video is ready
                setState(() {
                  _controller.setPlaybackQuality(VideoQuality.hd1080);
                });
              },
            ),
            builder: (context, player) {
              return player;
            },
          ),
          if(!_isFullscreen) const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text("Other Videos: ", style: TextStyle(fontSize: 14),),
          ),
          if(!_isFullscreen) Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _isLoadingRelatedVideos
                  ? buildShimmerLoader() // Show shimmer effect while loading
                  : _hasError
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: _fetchRelatedVideos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: _relatedVideos.isEmpty

                // if related videos not match then other videos are show on screen
                    ? ListView.builder(
                  itemCount: widget.relatedVideos.length,
                  itemBuilder: (context, index) {
                    final video = widget.relatedVideos[index];

                    final data =
                    video.data() as Map<String, dynamic>;
                    return ListTile(
                      isThreeLine: true,
                      minLeadingWidth: 100,
                      minTileHeight: 70,
                      title: Text(
                        data['title'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "Channel: ${data['channelTitle']}",
                        style: const TextStyle(fontSize: 10),
                      ),
                      leading: SizedBox(
                        width: 100,
                        height: 60,
                        child: FutureBuilder(
                          future: _cacheManager.getSingleFile(data['thumbnail']),
                          builder: (context, snapshot) {
                            String decodedUrl = Uri.decodeFull(data['thumbnail']);

                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return (snapshot.data != null) ? Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    defaultProfile,
                                    fit: BoxFit.cover,
                                  ); // Fallback image
                                },
                              ) : Image.network(
                                defaultProfile,
                                fit: BoxFit.cover,
                              );
                            }
                            return Image.network(
                              decodedUrl,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  defaultProfile,
                                  fit: BoxFit.cover,
                                ); // Fallback image
                              },
                            );
                          },
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoId: data['videoId'],
                              videoTitle: data['title'],
                              videoDes: data['description'],
                              relatedVideos: widget.relatedVideos,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
                    : ListView.builder(
                  itemCount: _relatedVideos.length,
                  itemBuilder: (context, index) {
                    final video = _relatedVideos[index];

                    final videoData =
                    video.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(videoData['title']),
                      subtitle: Text(
                          "Channel: ${videoData['channelTitle']}"),
                      leading: SizedBox(
                        width: 100,
                        height: 60,
                        child: FutureBuilder(
                          future: _cacheManager.getSingleFile(videoData['thumbnail']),
                          builder: (context, snapshot) {
                            String decodedUrl = Uri.decodeFull(videoData['thumbnail']);

                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return (snapshot.data != null) ? Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    defaultProfile,
                                    fit: BoxFit.cover,
                                  ); // Fallback image
                                },
                              ) : Image.network(
                                defaultProfile,
                                fit: BoxFit.cover,
                              );
                            }
                            return Image.network(
                              decodedUrl,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  defaultProfile,
                                  fit: BoxFit.cover,
                                ); // Fallback image
                              },
                            );
                          },
                        ),
                      ),
                      onTap: () {
                        // Navigate to the selected related video
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoId: videoData['videoId'],
                              videoTitle: videoData['title'],
                              videoDes: videoData['description'],
                              relatedVideos: _relatedVideos,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    _resolutionController.dispose();
    super.dispose();
  }
}

extension on String {
  get availableQualities => null;
}

class VideoQuality {
  static var hd1080;
}

extension on YoutubePlayerController {
  void setPlaybackQuality(quality) {}
}