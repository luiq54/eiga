import '../../models/sources/4anime.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../graphql/graphql_api.dart';

class AnimeInfo extends StatelessWidget {
  final int id;

  AnimeInfo({this.id});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
          documentNode: AnimeInfoQuery().document, variables: {'id': id}),
      builder: (
        QueryResult result, {
        Future<QueryResult> Function() refetch,
        FetchMore fetchMore,
      }) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.data == null && result.loading) {
          return Center(child: CircularProgressIndicator());
        }

        final anime = AnimeInfo$Query.fromJson(result.data).media;
        final animeName = anime.title.romaji;

        return Scaffold(
          appBar: AppBar(
            title: Text(animeName),
          ),
          body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                animeName,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Text(
                                anime.title.native,
                                style: Theme.of(context).textTheme.subtitle2,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 3,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  anime.coverImage.medium,
                                  fit: BoxFit.cover,
                                )))
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Description",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 10),
                    Container(
                      constraints: BoxConstraints(maxHeight: 250),
                      // child: Expanded(
                      //   flex: 1,
                      child: SingleChildScrollView(
                        child: Text(
                          anime.description.replaceAll(RegExp('<br>'), ""),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      //                  ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton.icon(
                            label: Text("Watch Now"),
                            icon: Icon(Icons.play_arrow),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          FourAnime(search: animeName)));
                            }),
                      ],
                    )
                  ],
                )),
          ),
        );
      },
    );
  }
}