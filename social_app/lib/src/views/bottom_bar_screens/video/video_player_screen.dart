
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_app/src/helpers/constants.dart';
import 'package:social_app/src/views/bottom_bar_screens/video/stop_words.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../myapp.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String videoDes;
  final String videoTitle;
  final String currentVideoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.videoDes,
    required this.currentVideoId,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final CacheManager _cacheManager = CacheManager(Config('videos_cache'));
  final RefreshController _refreshController = RefreshController();
  List<DocumentSnapshot> _relatedVideos = [];
  bool _isFullscreen = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_fullscreenListener);
    _loadRelatedVideos();
  }

  void _fullscreenListener() {
    if (_controller.value.isFullScreen != _isFullscreen) {
      setState(() => _isFullscreen = _controller.value.isFullScreen);
    }
  }

  Future<void> _loadRelatedVideos() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final currentVideoText = '${widget.videoTitle} ${widget.videoDes}';
      final keywords = _extractKeywords(currentVideoText);

      final snapshot = await FirebaseFirestore.instance
          .collection('saved_videos')
          .get();

      final videos = await _filterAndSortVideos(snapshot.docs, keywords);

      if (mounted) setState(() => _relatedVideos = videos);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _refreshController.refreshCompleted();
      }
    }
  }

  List<String> _extractKeywords(String text) {
    final stopWords = commonStopWords;
    final words = text
        .toLowerCase()
        .split(RegExp(r"[\W_]+"))
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();

    // Get unique words with frequency
    final wordCount = <String, int>{};
    for (final word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // Sort and take top 10 frequent words
    final sortedEntries = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(10).map((e) => e.key).toList();
  }

  Future<List<DocumentSnapshot>> _filterAndSortVideos(
      List<DocumentSnapshot> allVideos,
      List<String> keywords,
      ) async {
    final List<Map<String, dynamic>> videoScores = [];

    for (final doc in allVideos) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['videoId'] == widget.currentVideoId) continue;

      final videoText = '${data['title']} ${data['description']}'.toLowerCase();
      var score = 0;

      for (final keyword in keywords) {
        if (videoText.contains(keyword)) {
          score += keyword.length; // Longer keywords get more weight
        }
      }

      if (score > 0) {
        videoScores.add({'doc': doc, 'score': score});
      }
    }

    // Sort by score using the collection package
    return videoScores
        .sorted((a, b) => b['score'].compareTo(a['score']))
        .map((e) => e['doc'] as DocumentSnapshot)
        .toList();
  }

  void _onRefresh() => _loadRelatedVideos();

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: _isFullscreen ? null : _buildAppBar(),
      body: Column(
        children: [
          _buildVideoPlayer(),

          if (!_isFullscreen) Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(left: sw * 0.02, top: sw * 0.02, bottom: sw * 0.02),
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.012),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sw * 0.1),
                color: AppColors.containerdarkmode,
              ),
              child: Text('Related videos', style: TextStyle(fontSize: sw * 0.038, color: AppColors.white, fontWeight: FontWeight.bold),),
            ),
          ),
          if (!_isFullscreen) _buildRelatedVideos(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    title: SizedBox(
      width: 180,
      child: Text(
        widget.videoTitle,
        style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
      ),
    ),
  );

  Widget _buildVideoPlayer() => YoutubePlayerBuilder(
    onEnterFullScreen: () => setState(() => _isFullscreen = true),
    onExitFullScreen: () => setState(() => _isFullscreen = false),
    player: YoutubePlayer(
      key: ValueKey(widget.videoId), // Prevent unnecessary rebuilds
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      onReady: () => _controller.setPlaybackQuality(VideoQuality.hd1080),
    ),
    builder: (context, player) => player,
  );

  Widget _buildRelatedVideos() => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _isLoading
          ? _buildShimmerLoader()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: _relatedVideos.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          itemCount: _relatedVideos.length,
          itemBuilder: (context, index) =>
              _buildVideoItem(_relatedVideos[index]),
        ),
      ),
    ),
  );

  Widget _buildVideoItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListTile(
      title: Text(data['title']),
      subtitle: Text("Channel: ${data['channelTitle']}"),
      leading: _buildThumbnail(data['thumbnail']),
      onTap: () => _navigateToVideo(data),
    );
  }

  Widget _buildThumbnail(String url) {
    // Check if the URL is valid
    final decodedUrl = Uri.decodeFull(url);
    final isUrlValid = Uri.tryParse(decodedUrl)?.hasAbsolutePath ?? false;

    return SizedBox(
      width: 100,
      height: 60,
      child: isUrlValid
          ? FutureBuilder(
        future: _cacheManager.getSingleFile(decodedUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.file(snapshot.data!, fit: BoxFit.cover);
          }
          return Image.network(
            decodedUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => _buildFallbackImage(),
          );
        },
      )
          : _buildFallbackImage(), // Fallback for invalid URLs
    );
  }

  Widget _buildFallbackImage() {
    return Image.network(
      defaultProfile, // Use your fallback image URL
      fit: BoxFit.cover,
    );
  }

  void _navigateToVideo(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoId: data['videoId'],
          videoTitle: data['title'],
          videoDes: data['description'],
          currentVideoId: data['videoId'],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() => ListView.builder(
    itemCount: 5,
    itemBuilder: (_, __) => const ShimmerVideoListItem(),
  );

  Widget _buildErrorWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _loadRelatedVideos,
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Text("No related videos found"),
  );

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}

// Add this shimmer widget
class ShimmerVideoListItem extends StatelessWidget {
  const ShimmerVideoListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 100,
        height: 60,
        color: Colors.grey[300], // Shimmer placeholder color
      ),
      title: Container(
        height: 16,
        color: Colors.grey[300], // Shimmer placeholder color
      ),
      subtitle: Container(
        height: 14,
        color: Colors.grey[300], // Shimmer placeholder color
      ),
    );
  }
}

class VideoQuality {
  static var hd1080;
}

extension on YoutubePlayerController {
  void setPlaybackQuality(quality) {}
}