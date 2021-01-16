import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautifulsoup/beautifulsoup.dart';
import 'dart:io';
import 'package:eiga/models/episode_entry.dart';

class EpisodeListView extends StatelessWidget {
  final String animeLink;

  const EpisodeListView({Key key, @required this.animeLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadEpisodeList(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else
                return GridView.count(
                    padding: EdgeInsets.all(20),
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(snapshot.data.length, (index) {
                      return RaisedButton(
                        child: Text(snapshot.data[index].title),
                        onPressed: () =>
                            OpenEpisode(snapshot.data[index].link, context),
                      );
                    }));
          }
        });
  }

  Future<List> loadEpisodeList() async {
    var response = await http.get(animeLink);
    var soup = Beautifulsoup(response.body);
    return soup
        .find_all('ul.episodes.range.active > li > a')
        .map((e) => EpisodeEntry(e.text, soup.attr(e, 'href')))
        .toList();
  }

  void OpenEpisode(String link, BuildContext con) async {
    showDialog(
        context: con,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10),
            children: [
              Container(child: Center(child: CircularProgressIndicator())),
            ],
          );
        });
    var response = await http.get(link);
    var soup = Beautifulsoup(response.body);
    var vidLink = Beautifulsoup(soup.find(id: 'div.videojs-desktop').innerHtml)
        .find(id: 'source')
        .attributes['src'];

    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: vidLink,
        type: 'video/**',
        flags: [Flag.FLAG_GRANT_READ_URI_PERMISSION],
      );
      await intent.launch();
    }
  }
}