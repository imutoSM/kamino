import 'package:kamino/api.dart' as api;
import 'package:kamino/ui/uielements.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/view/home/tv_shows/popular_tv.dart';
import 'package:kamino/view/home/tv_shows/top_rated.dart';
import 'package:kamino/view/home/tv_shows/on_the_air.dart';


const splashColour = Colors.purpleAccent;
const primaryColor = const Color(0xFF8147FF);
const secondaryColor = const Color(0xFF303A47);
const backgroundColor = const Color(0xFF26282C);
const highlightColor = const Color(0x968147FF);

class TVHome extends StatefulWidget{
  @override
  _TVHomeState createState() => _TVHomeState();
}

class _TVHomeState extends State<TVHome> with AutomaticKeepAliveClientMixin<TVHome>{

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: ListView(
        addAutomaticKeepAlives: true,
        children: <Widget>[
          AirToday(),
          OnAirTV(),
          PopularShows(),
          TopRated(),
        ],
      ),
    );
  }

  // TODO: implement wantKeepAlive
  @override
  bool get wantKeepAlive => true;

}

class AirToday extends StatelessWidget{

  Future<List<AiringTodayModel>> getTodayShows() async{

    List<AiringTodayModel> _data = new List();

    String url = "https://api.themoviedb.org/3/tv/airing_today?"
        "api_key=${api.tvdb_api_key}&language=en-US&page=";

    final http.Client _client = http.Client();

    await _client
        .get(url)
        .then((res) => res.body)
        .then(jsonDecode)
        .then((json) => json["results"])
        .then((tvShows) => tvShows.forEach((tv) => _data.add(AiringTodayModel.fromJSON(tv))));

    return _data;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return _genTodayCard(context, screenWidth);
  }

  Widget airTodayListView(BuildContext context, double screenWidth, AsyncSnapshot snapshot){

    TextStyle _overlayTextStyle = TextStyle(
        fontFamily: 'GlacialIndifference', color: Colors.white,
        fontSize: 12.0);

    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: index == 0
                ? const EdgeInsets.only(left: 10.0)
                : const EdgeInsets.only(left: 0.0),
            child: InkWell(
              onTap: null,
              splashColor: Colors.white,
              child: Container(
                child: Column(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Card(
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(5.0),
                          child: Container(
                            child:snapshot.data[index].poster_path != null
                                ? Image.network(
                              "http://image.tmdb.org/t/p/w500" +
                                  snapshot.data[index].poster_path,
                              fit: BoxFit.fill,
                              height: 170.0,
                            ) : Image.asset(
                              "assets/images/no_image_detail.jpg",
                              fit: BoxFit.fill,
                              width: 135.0,
                              height: 170.0,
                            ),
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _genTodayCard(BuildContext context, double screenWidth){

    return FutureBuilder(
      future: getTodayShows(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.waiting:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator(backgroundColor: Colors.white,)),
            );
          case ConnectionState.none:
            return Container();
          default:
            if (snapshot.hasData){
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: backgroundColor,
                  elevation: 6.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Row(
                          children: <Widget>[

                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, right: 147.0),
                              child: Text("Airing Today", style: TextStyle(
                                  fontFamily: 'GlacialIndifference', color: Colors.white,
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                            ),

                            FlatButton(onPressed: null, child: Text("See All")),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 195.0,
                        child: airTodayListView(context, screenWidth, snapshot),
                      ),

                    ],
                  ),
                ),
              );
            } else return Container();
        }
      },
    );

  }
}

class AiringTodayModel{

  final int id;
  final String first_air_date, poster_path, backdrop_path;
  final String name;
  final double popularity;

  AiringTodayModel.fromJSON(Map json)
      : id = json["id"],
        first_air_date = json["first_air_date"],
        poster_path = json["poster_path"],
        backdrop_path = json["backdrop_path"],
        name = json["original_name"] == null ?
        json["name"] : json["original_name"],
        popularity = json["popularity"];
}