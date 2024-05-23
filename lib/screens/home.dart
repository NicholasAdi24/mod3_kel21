import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'detail.dart';
import 'profile.dart'; // Import profile page

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Show>?> shows;

  late Future<List<AnimeSeason>?> animeSeasons;
  // Tambahkan Future untuk daftar anime musim ini

  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    shows = fetchShows(currentPage);
    animeSeasons =
        fetchAnimeSeasons(); // Panggil metode untuk mengambil daftar anime musim ini
  }

  Future<List<Show>?> fetchShows(int page) async {
    final response = await http
        .get(Uri.parse('https://api.jikan.moe/v4/top/anime?page=$page'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final shows = jsonResponse['data'] as List;
      return shows.map((show) => Show.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load shows');
    }
  }

  Future<List<AnimeSeason>?> fetchAnimeSeasons() async {
    final response =
        await http.get(Uri.parse('https://api.jikan.moe/v4/seasons/now'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final animeSeasons = jsonResponse['data'] as List;
      return animeSeasons
          .map((season) => AnimeSeason.fromJson(season))
          .toList();
    } else {
      throw Exception('Failed to load anime seasons');
    }
  }

  void nextPage() {
    if (currentPage < 10) {
      setState(() {
        currentPage++;
        shows = fetchShows(currentPage);
      });
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        shows = fetchShows(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyAnimeList')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'This Season', // Teks "This Season"
              style: TextStyle(
                fontSize: 24, // Ukuran teks
                fontWeight: FontWeight.bold, // Ketebalan teks
              ),
            ),
            FutureBuilder<List<AnimeSeason>?>(
              builder: (context, AsyncSnapshot<List<AnimeSeason>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available.'));
                } else {
                  return SizedBox(
                    height: 200, // Atur tinggi sesuai kebutuhan
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final season = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  item: season
                                      .malId, // Gunakan ID dari Anime Season
                                  title: season
                                      .title, // Gunakan judul dari Anime Season
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Image.network(
                                  season.images.jpg.image_url,
                                  width: 190,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    season.title,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
              future: animeSeasons,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: previousPage,
                  child: Text('Previous Page'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: nextPage,
                  child: Text('Next Page'),
                ),
              ],
            ),
            FutureBuilder<List<Show>?>(
              builder: (context, AsyncSnapshot<List<Show>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final show = snapshot.data![index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(show.images.jpg.image_url),
                          ),
                          title: Text(show.title),
                          subtitle: Text('Score: ${show.score}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  item: show.malId,
                                  title: show.title,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
              future: shows,
            ),
          ],
        ),
      ),
      // Tambahkan bottomNavigationBar untuk navbar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Index pertama (Home) dipilih awal
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Home (tidak perlu tindakan tambahan)
          } else if (index == 1) {
            // Navigasi ke halaman Profile
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfilePage(),
            ));
          }
        },
      ),
    );
  }
}

class Show {
  final int malId;
  final String title;
  Images images;
  final double score;

  Show({
    required this.malId,
    required this.title,
    required this.images,
    required this.score,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      malId: json['mal_id'],
      title: json['title'],
      images: Images.fromJson(json['images']),
      score: json['score'].toDouble(),
    );
  }
}

//
class AnimeSeason {
  final int malId;
  final String title;
  Images images;

  AnimeSeason({
    required this.malId,
    required this.title,
    required this.images,
  });

  factory AnimeSeason.fromJson(Map<String, dynamic> json) {
    final title =
        json['title'] ?? 'No Title'; // Menggunakan 'No Title' jika title null
    return AnimeSeason(
      malId: json['mal_id'],
      title: title,
      images:
          Images.fromJson(json['images'] ?? 'https://example.com/default.jpg'),
    );
  }
}

class Images {
  final Jpg jpg;

  Images({required this.jpg});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      jpg: Jpg.fromJson(json['jpg']),
    );
  }
}

class Jpg {
  String image_url;
  String small_image_url;
  String large_image_url;

  Jpg({
    required this.image_url,
    required this.small_image_url,
    required this.large_image_url,
  });

  factory Jpg.fromJson(Map<String, dynamic> json) {
    return Jpg(
      image_url: json['image_url'],
      small_image_url: json['small_image_url'],
      large_image_url: json['large_image_url'],
    );
  }
}
