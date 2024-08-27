import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hussein TV',
      theme: ThemeData(
        primaryColor: Color(0xFF512da8),
        scaffoldBackgroundColor: Color(0xFF673ab7),
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF512da8),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF512da8),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<dynamic>> channelCategories;
  late Future<List<dynamic>> newsArticles;
  late Future<List<dynamic>> matches;

  @override
  void initState() {
    super.initState();
    channelCategories = fetchChannelCategories();
    newsArticles = fetchNews();
    matches = fetchMatches();
  }

  Future<List<dynamic>> fetchChannelCategories() async {
    try {
      final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/channel-categories?populate=channels'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Channel Categories Data: $data');
        return data['data'];
      } else {
        throw Exception('Failed to load channel categories');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load channel categories');
    }
  }

  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/news?populate=*'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('News Data: $data');
        return data['data'];
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load news');
    }
  }

  Future<List<dynamic>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/matches?populate=*'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Matches Data: $data');
        return data['data'];
      } else {
        throw Exception('Failed to load matches');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load matches');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hussein TV'),
      ),
      body: _selectedIndex == 0
          ? ChannelsSection(channelCategories: channelCategories)
          : _selectedIndex == 1
          ? NewsSection(newsArticles: newsArticles)
          : MatchesSection(matches: matches),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tv),
            label: 'القنوات',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.newspaper),
            label: 'الأخبار',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.futbol),
            label: 'المباريات',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ChannelsSection extends StatelessWidget {
  final Future<List<dynamic>> channelCategories;

  ChannelsSection({required this.channelCategories});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: channelCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع القنوات'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا توجد قنوات لعرضها'));
        } else {
          final categories = snapshot.data!;
          return ListView.separated(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return ChannelBox(category: categories[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          );
        }
      },
    );
  }
}

class ChannelBox extends StatelessWidget {
  final dynamic category;

  ChannelBox({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Center(
          child: Text(
            category['attributes']['name'] ?? 'Unknown Category',
            style: TextStyle(
              color: Color(0xFF673ab7),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryChannelsScreen(channels: category['attributes']['channels']['data'] ?? []),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChannelsScreen extends StatelessWidget {
  final List<dynamic> channels;

  CategoryChannelsScreen({required this.channels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القنوات'),
      ),
      body: ListView.separated(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return ChannelTile(channel: channels[index]);
        },
        separatorBuilder: (context, index) => SizedBox(height: 16),
      ),
    );
  }
}

class ChannelTile extends StatelessWidget {
  final dynamic channel;

  ChannelTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Center(
          child: Text(
            channel['attributes']['name'] ?? 'Unknown Channel',
            style: TextStyle(
              color: Color(0xFF673ab7),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          openVideo(context, channel['attributes']['streamLink']);
        },
      ),
    );
  }

  void openVideo(BuildContext context, String? url) {
    if (url != null && url.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: url),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد رابط للبث المباشر')),
      );
    }
  }
}

class NewsSection extends StatelessWidget {
  final Future<List<dynamic>> newsArticles;

  NewsSection({required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: newsArticles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع الأخبار'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا توجد أخبار لعرضها'));
        } else {
          final articles = snapshot.data!;
          return ListView.separated(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index]['attributes'];
              return NewsBox(article: article);
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          );
        }
      },
    );
  }
}

class NewsBox extends StatelessWidget {
  final dynamic article;

  NewsBox({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        title: Text(
          article['title'] ?? 'Unknown Title',
          style: TextStyle(
            color: Color(0xFF673ab7),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Image.network(article['image']['data']['attributes']['url']),
            SizedBox(height: 10),
            Text(article['content'] ?? 'No content available'),
            SizedBox(height: 10),
            Text(article['date'] ?? 'No date available'),
          ],
        ),
        onTap: () {
          if (article['link'] != null && article['link'].isNotEmpty) {
            _launchURL(article['link']);
          }
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class MatchesSection extends StatelessWidget {
  final Future<List<dynamic>> matches;

  MatchesSection({required this.matches});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: matches,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع المباريات'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا توجد مباريات لعرضها'));
        } else {
          final matches = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
            ),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchBox(match: matches[index]);
            },
          );
        }
      },
    );
  }
}

class MatchBox extends StatelessWidget {
  final dynamic match;

  MatchBox({required this.match});

  @override
  Widget build(BuildContext context) {
    final teamA = match['attributes']['teamA'] ?? 'Team A';
    final teamB = match['attributes']['teamB'] ?? 'Team B';
    final logoA = match['attributes']['logoA']['data']['attributes']['url'] ?? '';
    final logoB = match['attributes']['logoB']['data']['attributes']['url'] ?? '';
    final matchTime = match['attributes']['matchTime'] ?? '00:00';
    final streamLink = match['attributes']['streamLink'] ?? '';
    final commentator = match['attributes']['commentator'] ?? '';
    final channel = match['attributes']['channel'] ?? '';

    return GestureDetector(
      onTap: () {
        openVideo(context, streamLink);
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.network(logoA, width: 50, height: 50),
                Text('VS', style: TextStyle(fontWeight: FontWeight.bold)),
                Image.network(logoB, width: 50, height: 50),
              ],
            ),
            SizedBox(height: 10),
            Text('$teamA vs $teamB', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Time: $matchTime'),
            Text('Commentator: $commentator'),
            Text('Channel: $channel'),
          ],
        ),
      ),
    );
  }

  void openVideo(BuildContext context, String? url) {
    if (url != null && url.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: url),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد رابط للبث المباشر')),
      );
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _vlcPlayerController;

  @override
  void initState() {
    super.initState();
    _vlcPlayerController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VlcPlayer(
          controller: _vlcPlayerController,
          aspectRatio: 16 / 9,
          placeholder: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
