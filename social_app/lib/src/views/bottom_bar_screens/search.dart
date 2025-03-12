import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../providers/data_search_provider.dart';
import '../../widgets/custom_txt.dart';
import '../chat_screen/chatroom_screen.dart';
import '../profile_screen/other_users_info.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

Stream<QuerySnapshot<Map<String, dynamic>>> hosts = FirebaseFirestore.instance.collection('Users').snapshots();

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.fetchAllUsers(); // Fetch all users initially
    searchProvider.fetchSearchHistory(); // Fetch search history
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              userSearchBar(sw: sw, searchProvider: searchProvider),
              14.height,
              // Recent Search History
              historyUsers(sw),
              // Suggestions
              CustomText(
                  txt: 'Suggestions',
                  fontSize: sw * 0.036,
                ),
              10.height,
              // User List (All Users or Filtered Users)
              allOrFilterUsers(sw)
            ],
          ),
        ),
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

  // Users Search Bar
  Widget userSearchBar({required double sw, required SearchProvider searchProvider}){
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: sw * 0.13,
        width: double.infinity,
        child: SearchBar(
          controller: searchController,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            searchProvider.filterSearchData(value);
          },
          hintText: 'Search',
          hintStyle: WidgetStatePropertyAll(TextStyle(
            fontSize: sw * 0.04,
          )),
          leading: Icon(
            Icons.search,
            size: sw * 0.07,
            color: AppColors.grey.withAlpha(200),
          ),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: sw * 0.04)),
        ),
      ),
    );
  }

  // Recent Search History Users
  Widget historyUsers(double sw){
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  txt: 'Recent History',
                  fontSize: sw * 0.036,
                ),
                if (searchProvider.searchHistory.isNotEmpty)
                  GestureDetector(
                    onTap: () => searchProvider.clearSearchHistory(),
                    child: Icon(
                      Icons.delete,
                      size: sw * 0.06,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            04.height,
            Wrap(
              spacing: 8,
              children: searchProvider.searchHistory.map((query) {
                return Chip(
                  label: Text(query, style: TextStyle(fontSize: sw * 0.03),),
                  deleteIcon: Icon(
                    Icons.cancel,
                    size: sw * 0.05,
                    color: Colors.red,
                  ),
                  onDeleted: () async {
                    await searchProvider.removeSearchQuery(query); // Remove query from history
                  },
                );
              }).toList(),
            ),
            04.height,
          ],
        );
      },
    );
  }

  // User List (All Users or Filtered Users)
  Widget allOrFilterUsers(double sw){
    return Expanded(
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isSearching) {
            return Center(child: CircularProgressIndicator());
          }
          if (searchProvider.filteredUsers.isEmpty) {
            return Center(child: SizedBox(
                width: sw * 0.8,
                child: Text('🔍 Nothings Else \n"${searchController.text}"', style: TextStyle(fontSize: sw * 0.04, fontFamily: 'Poppins'),textAlign: TextAlign.center,)),);
          }
          return ListView.builder(
            itemCount: searchProvider.filteredUsers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final user = searchProvider.filteredUsers[index];
              return Card(
                child: ListTile(
                  onTap: () async {
                    // Save the searched user to search history
                    await searchProvider.saveSearchedUser(user);

                    // Navigate to the user's info screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUsersInfo(data: user),
                      ),
                    );
                  },
                  leading: Container(
                    width: sw * 0.15,
                    height: sw * 0.15,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: (user['imgUrl'] != '')
                        ? Image.network(
                      user['imgUrl'],
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/images/2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: highlightText(user['fullName'], searchController.text),
                  subtitle: Text(
                    user['bio'],
                    style: TextStyle(fontSize: sw * 0.028),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: InkWell(
                    onTap: () async {
                      final roomId = await searchProvider.chatRoomID(user['userId']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatroomScreen(
                            chatRoomId: roomId,
                            otherUserMap: user,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      CupertinoIcons.chat_bubble_text,
                      size: sw * 0.06,
                      color: AppColors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}