import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final int item;
  final String title;
  const DetailPage({Key? key, required this.item, required this.title})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<AnimeSeason?> animeSeason;
  late Future<List<Episode>?> episodes;
  late Future<List<Character>?> characters; // Tambahkan ini

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    animeSeason = fetchAnimeSeason(widget.item);
    episodes = fetchEpisodes(widget.item);
    characters = fetchCharacters(
        widget.item); // Ambil data karakter anime dan voice actors
  }

  // Function to handle refresh
  Future<void> _refresh() async {
    setState(() {
      animeSeason = fetchAnimeSeason(widget.item);
      episodes = fetchEpisodes(widget.item);
      characters = fetchCharacters(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: RefreshIndicator(
          // Assign the key to the RefreshIndicator
          key: _refreshIndicatorKey,
          onRefresh: _refresh, // Specify the refresh callback function
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<AnimeSeason?>(
                  future: animeSeason,
                  builder: (context, animeSeasonSnapshot) {
                    if (animeSeasonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (animeSeasonSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${animeSeasonSnapshot.error}'));
                    } else if (animeSeasonSnapshot.data == null) {
                      return Center(child: Text('No info available.'));
                    }

                    final anime = animeSeasonSnapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tampilkan gambar anime
                        Center(
                          child: Image.network(
                            anime.images.jpg.large_image_url,
                            width: 200,
                            height: 300,
                          ),
                        ),
                        // Tampilkan judul anime
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              anime.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              anime.japan,
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Score: ${anime.score.toString()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        // Tampilkan sinopsis
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            anime.synopsis,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                FutureBuilder<List<Episode>?>(
                  future: episodes,
                  builder: (context, episodeSnapshot) {
                    if (episodeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (episodeSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${episodeSnapshot.error}'));
                    } else if (episodeSnapshot.data == null ||
                        episodeSnapshot.data!.isEmpty) {
                      return Center(child: Text('No episodes available.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: episodeSnapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(episodeSnapshot.data![index].title),
                        );
                      },
                    );
                  },
                ),
                FutureBuilder<List<Character>?>(
                  future: fetchCharacters(widget.item),
                  builder: (context, characterSnapshot) {
                    if (characterSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (characterSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${characterSnapshot.error}'));
                    } else if (characterSnapshot.data == null ||
                        characterSnapshot.data!.isEmpty) {
                      return Center(child: Text('No characters available.'));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: characterSnapshot.data!.map((character) {
                          return Container(
                            width: 200,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Image.network(
                                  character.imageUrl,
                                  width: 120,
                                  height: 120,
                                ),
                                Text(character.name),
                                Text(character.role),
                                Image.network(
                                  character.voiceActorImageUrl,
                                  width: 120,
                                  height: 120,
                                ),
                                Text(character.voiceActorName),
                                Text(character.voiceActorLanguage),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                // Bagian FutureBuilder untuk AnimeChara
              ],
            ),
          ),
        ));
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

class Episode {
  final String title;

  Episode({required this.title});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'],
    );
  }
}

class AnimeSeason {
  final int malId;
  final String title;
  Images images;
  final String synopsis;
  final String japan;
  final double score;

  AnimeSeason(
      {required this.malId,
      required this.title,
      required this.images,
      required this.synopsis,
      required this.japan,
      required this.score});

  factory AnimeSeason.fromJson(Map<String, dynamic> json) {
    final title =
        json['title'] ?? 'No Title'; // Menggunakan 'No Title' jika title null
    return AnimeSeason(
        malId: json['mal_id'],
        title: title,
        images: Images.fromJson(
            json['images'] ?? 'https://example.com/default.jpg'),
        synopsis: json['synopsis'],
        japan: json['title_japanese'],
        score: json['score']);
  }
}

class Character {
  final int malId;
  final String name;
  final String imageUrl;
  final String role;
  final String voiceActorName;
  final String voiceActorImageUrl;
  final String voiceActorLanguage;

  Character({
    required this.malId,
    required this.name,
    required this.imageUrl,
    required this.role,
    required this.voiceActorName,
    required this.voiceActorImageUrl,
    required this.voiceActorLanguage,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final character = json['character'];
    final voiceActors = json['voice_actors'] as List;

    String voiceActorName = '';
    String voiceActorImageUrl = '';
    String voiceActorLanguage = '';

    if (voiceActors.isNotEmpty) {
      final voiceActor = voiceActors[0];
      voiceActorName = voiceActor['person']['name'];
      voiceActorImageUrl = voiceActor['person']['images']['jpg']['image_url'];
      voiceActorLanguage = voiceActor['language'];
    }

    return Character(
      malId: character['mal_id'],
      name: character['name'],
      imageUrl: character['images']['jpg']['image_url'],
      role: json['role'],
      voiceActorName: voiceActorName,
      voiceActorImageUrl: voiceActorImageUrl,
      voiceActorLanguage: voiceActorLanguage,
    );
  }
}

Future<List<Episode>?> fetchEpisodes(int id) async {
  final response =
      await http.get(Uri.parse('https://api.jikan.moe/v4/anime/$id/episodes'));

  if (response.statusCode == 200) {
    var episodesJson = jsonDecode(response.body)['data'] as List;
    return episodesJson.map((episode) => Episode.fromJson(episode)).toList();
  } else {
    throw Exception('Failed to load episodes');
  }
}

Future<AnimeSeason?> fetchAnimeSeason(int id) async {
  final response =
      await http.get(Uri.parse('https://api.jikan.moe/v4/anime/$id/full'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return AnimeSeason.fromJson(jsonResponse['data']);
  } else {
    throw Exception('Failed to load anime season');
  }
}

Future<List<Character>?> fetchCharacters(int id) async {
  final response = await http
      .get(Uri.parse('https://api.jikan.moe/v4/anime/$id/characters'));

  if (response.statusCode == 200) {
    final charactersJson = jsonDecode(response.body)['data'] as List;
    return charactersJson
        .map((characterData) => Character.fromJson(characterData))
        .toList();
  } else {
    throw Exception('Failed to load characters');
  }
}
