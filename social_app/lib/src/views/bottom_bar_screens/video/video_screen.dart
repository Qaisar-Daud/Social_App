
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_app/src/myapp.dart';
import 'package:social_app/src/views/bottom_bar_screens/video/video_player_screen.dart';
import '../../../helpers/constants.dart';
import '../../../widgets/shimmer_loader.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final Query<Map<String, dynamic>> _videosCollection = FirebaseFirestore.instance.collection('saved_videos');
  final TextEditingController _searchController = TextEditingController();
  final CacheManager _cacheManager = CacheManager(Config('youtube_cache'));
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  final List<DocumentSnapshot> _videos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  final int _fetchLimit = 50;
  int _currentIndex = 0;
  List<DocumentSnapshot> _allVideos = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchAllVideos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _loadMoreVideos();
    }
  }

  void _fetchAllVideos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _videos.clear();
      _allVideos.clear();
      _currentIndex = 0;
    });

    try {
      final QuerySnapshot snapshot = await _videosCollection.get();
      _allVideos = snapshot.docs;

      // 🎲 Randomly shuffle videos before displaying
      _allVideos.shuffle(Random());

      _loadMoreVideos();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _refreshController.refreshCompleted();
    }
  }

  void _loadMoreVideos() {
    if (_currentIndex >= _allVideos.length) return;

    setState(() {
      int endIndex = (_currentIndex + _fetchLimit).clamp(0, _allVideos.length);
      _videos.addAll(_allVideos.sublist(_currentIndex, endIndex));
      _currentIndex = endIndex;
    });
  }

  void _onRefresh() async {
    _fetchAllVideos();
  }

  void _onSearch() async {
    final query = _searchController.text.trim();
    _fetchAllVideos();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery
        .sizeOf(context)
        .width;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: SizedBox(
              height: sw * 0.13,
              width: double.infinity,
              child: SearchBar(
                controller: _searchController,
                keyboardType: TextInputType.text,
                hintText: 'Search',
                onChanged: (value) {
                  _onSearch();
                },
                hintStyle: WidgetStatePropertyAll(TextStyle(
                  fontSize: sw * 0.04,
                )),
                leading: Icon(
                  Icons.search,
                  size: sw * 0.07,
                  color: AppColors.grey.withAlpha(200),
                ),
                textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: sw * 0.04)),
              ),
            ),
          ),

          // Error Message
          if (_hasError)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => _fetchAllVideos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Data Values
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                onRefresh: _onRefresh,
                child: _isLoading && _videos.isEmpty
                    ? buildShimmerLoader()
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: _videos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _videos.length) {
                      return _currentIndex < _allVideos.length
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : SizedBox();
                    }
                    final video = _videos[index];
                    return _buildVideoItem(video);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Highlight matching text in search results
  Widget highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(fontSize: 16, color: Colors.black),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(fontSize: 16, color: Colors.black),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
  // List Of Videos
  Widget _buildVideoItem(DocumentSnapshot video) {
    final data = video.data() as Map<String, dynamic>;
    return ListTile(
      isThreeLine: true,
      minLeadingWidth: 100,
      minTileHeight: 70,
      title: highlightText(data['title'], _searchController.text),
      subtitle: Text("Channel: ${data['channelTitle']}", style: const TextStyle(fontSize: 10),),
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
              relatedVideos: _videos,
            ),
          ),
        );
      },
    );
  }
}

// class _VideoScreenState extends State<VideoScreen> {
//   final Query<Map<String, dynamic>> _videosCollection = FirebaseFirestore.instance.collection('saved_videos').orderBy('publishedAt', descending: false);
//   final TextEditingController _searchController = TextEditingController();
//   final CacheManager _cacheManager = CacheManager(Config('youtube_cache'));
//   final RefreshController _refreshController = RefreshController();
//   final ScrollController _scrollController = ScrollController();
//
//   final List<DocumentSnapshot> _videos = [];
//   bool _isLoading = false;
//   bool _hasError = false;
//   String _errorMessage = '';
//   DocumentSnapshot? _lastDocument;
//   bool _hasMore = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _fetchVideos();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _refreshController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent &&
//         !_isLoading &&
//         _hasMore) {
//       _fetchVideos(loadMore: true);
//     }
//   }
//
//   void _fetchVideos({bool loadMore = false, String? searchQuery}) async {
//     if (_isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       if (!loadMore) {
//         _videos.clear();
//         _lastDocument = null;
//         _hasMore = true;
//       }
//     });
//
//     try {
//       Query query = _videosCollection.limit(10); // Fetch 10 videos at a time
//       if (searchQuery != null && searchQuery.isNotEmpty) {
//         query = query.where('title', isGreaterThanOrEqualTo: searchQuery);
//       }
//       if (loadMore && _lastDocument != null) {
//         query = query.startAfterDocument(_lastDocument!);
//       }
//
//       final QuerySnapshot snapshot = await query.get();
//       if (snapshot.docs.isEmpty) {
//         setState(() {
//           _hasMore = false;
//         });
//       } else {
//         setState(() {
//           _videos.addAll(snapshot.docs);
//           _lastDocument = snapshot.docs.last;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       if (loadMore) {
//         _refreshController.loadComplete();
//       } else {
//         _refreshController.refreshCompleted();
//       }
//     }
//   }
//
//   void _onRefresh() async {
//     _fetchVideos();
//   }
//
//   void _onSearch() async {
//     final query = _searchController.text.trim();
//     _fetchVideos(searchQuery: query);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double sw = MediaQuery.sizeOf(context).width;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: EdgeInsets.all(sw * 0.04),
//             child: SizedBox(
//               height: sw * 0.13,
//               width: double.infinity,
//               child: SearchBar(
//                 controller: _searchController,
//                 keyboardType: TextInputType.text,
//                 hintText: 'Search',
//                 onChanged: (value) {
//                   _onSearch();
//                 },
//                 hintStyle: WidgetStatePropertyAll(TextStyle(
//                   fontSize: sw * 0.04,
//                 )),
//                 leading: Icon(
//                   Icons.search,
//                   size: sw * 0.07,
//                   color: AppColors.grey.withAlpha(200),
//                 ),
//                 textStyle: WidgetStatePropertyAll(TextStyle(fontSize: sw * 0.04)),
//               ),
//             ),
//           ),
//
//           // Error Message
//           if (_hasError)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Text(
//                     _errorMessage,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => _fetchVideos(loadMore: true),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//
//           // Data Values
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(8.0), // Move Padding inside Expanded
//               child: SmartRefresher(
//                 controller: _refreshController,
//                 enablePullUp: true,
//                 onRefresh: _onRefresh,
//                 onLoading: () => _fetchVideos(loadMore: true),
//                 child: _isLoading && _videos.isEmpty
//                     ? buildShimmerLoader()
//                     : ListView.builder(
//                   controller: _scrollController,
//                   itemCount: _videos.length + (_hasMore ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == _videos.length) {
//                       // When Video List Reach To End.
//                       return const SizedBox();
//                     }
//                     final video = _videos[index];
//                     return _buildVideoItem(video);
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // Highlight matching text in search results
//   Widget highlightText(String text, String query) {
//     if (query.isEmpty) {
//       return Text(text);
//     }
//
//     final matches = query.toLowerCase().allMatches(text.toLowerCase());
//     final spans = <TextSpan>[];
//     int lastMatchEnd = 0;
//
//     for (final match in matches) {
//       if (match.start > lastMatchEnd) {
//         spans.add(TextSpan(
//           text: text.substring(lastMatchEnd, match.start),
//           style: TextStyle(fontSize: 16, color: Colors.black),
//         ));
//       }
//
//       spans.add(TextSpan(
//         text: text.substring(match.start, match.end),
//         style: TextStyle(
//           fontSize: 16,
//           color: Colors.blue,
//           fontWeight: FontWeight.bold,
//         ),
//       ));
//
//       lastMatchEnd = match.end;
//     }
//
//     if (lastMatchEnd < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(lastMatchEnd),
//         style: TextStyle(fontSize: 16, color: Colors.black),
//       ));
//     }
//
//     return RichText(text: TextSpan(children: spans));
//   }
//   // List Of Videos
//   Widget _buildVideoItem(DocumentSnapshot video) {
//     final data = video.data() as Map<String, dynamic>;
//     return ListTile(
//       isThreeLine: true,
//       minLeadingWidth: 100,
//       minTileHeight: 70,
//       title: highlightText(data['title'], _searchController.text),
//       subtitle: Text("Channel: ${data['channelTitle']}", style: const TextStyle(fontSize: 10),),
//       leading: SizedBox(
//         width: 100,
//         height: 60,
//         child: FutureBuilder(
//           future: _cacheManager.getSingleFile(data['thumbnail']),
//           builder: (context, snapshot) {
//             String decodedUrl = Uri.decodeFull(data['thumbnail']);
//
//             if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//               return (snapshot.data != null) ? Image.file(
//                 snapshot.data!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Image.network(
//                   defaultProfile,
//                     fit: BoxFit.cover,
//                   ); // Fallback image
//                 },
//               ) : Image.network(
//                 defaultProfile,
//                 fit: BoxFit.cover,
//               );
//             }
//             return Image.network(
//               decodedUrl,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return const Center(child: CircularProgressIndicator());
//               },
//               errorBuilder: (context, error, stackTrace) {
//                 return Image.network(
//                   defaultProfile,
//                   fit: BoxFit.cover,
//                 ); // Fallback image
//               },
//             );
//           },
//         ),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoPlayerScreen(
//               videoId: data['videoId'],
//               videoTitle: data['title'],
//               videoDes: data['description'],
//               relatedVideos: _videos,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }