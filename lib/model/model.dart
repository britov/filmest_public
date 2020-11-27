import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_create/secret.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

class FilmsModel extends ChangeNotifier {
  /// Data
  List<Movie> movies = [];
  List<Map<String, dynamic>> genres;

  /// Filters
  int _currentGenre;

  int get currentGenre => _currentGenre;

  set currentGenre(int genreId) {
    _currentGenre = genreId;
    notifyListeners();
    resetMoviesPagePosition();
    loadMovies();
  }

  int _fromYear;
  int _toYear;

  int get fromYear => _fromYear;

  int get toYear => _toYear;

  void setDateFilter(int fromYear, int toYear) {
    _toYear = toYear;
    _fromYear = fromYear;
    notifyListeners();
    resetMoviesPagePosition();
    loadMovies();
  }

  /// Inner data
  int _moviesRequestPage = 1;

  /// Extra data
  String _tmdbLanguage = 'en-US';

  void setLang(String lang) {
    print('language: $lang');
    _tmdbLanguage = lang;
  }

  Future<void> loadMovies() async {
    genres ??= await _getGenres(_tmdbLanguage);
    final results = (await _getMovies(_moviesRequestPage++, _currentGenre?.toString(), _tmdbLanguage))?.results;
    if (results != null && _moviesRequestPage != 1) {
      movies.addAll(results);
    } else {
      movies = results ?? [];
    }
    notifyListeners();
  }

  Future<PageableResult> _getMovies(int page, String genreId, String language, {int repeat = 0}) async {
    var url = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&page=$page&language=$language';
    if (genreId != null) {
      url += '&with_genres=$genreId';
    }
    if (fromYear != null) {
      url += '&release_date.gte=$fromYear-01-01';
    }
    if (toYear != null) {
      url += '&release_date.lte=$toYear-12-31';
    }
    print('getMovies from $url');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return PageableResult.fromJson(json.decode(response.body));
    } else if (response.statusCode == 429 && repeat < 1) {
      print('statusCode: 429 and repeat: $repeat');
      await Future.delayed(const Duration(seconds: 10));
      return _getMovies(page, genreId, language, repeat: repeat + 1);
    }
    print('getMovies return null');
    return null;
  }

  Future<List<Map<String, dynamic>>> _getGenres(String language) async {
    final response = await http.get('https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=$language');
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> genres = body['genres'];
      return genres.map((g) => g is Map<String, dynamic> ? g : null).toList();
    }
    if (response.statusCode == 429) {
      await Future.delayed(const Duration(seconds: 10));
    }
    return null;
  }

  Future<List<String>> getVideo(num id) async {
    final response =
        await http.get('https://api.themoviedb.org/3/movie/$id/videos?api_key=$apiKey&language=$_tmdbLanguage');
    if (response.statusCode == 200) {
      return VideoResult.fromJson(json.decode(response.body)).results.map((v) => v.key).toList();
    }
    if (response.statusCode == 429) {
      await Future.delayed(const Duration(seconds: 10));
    }
    return null;
  }

  void resetMoviesPagePosition() {
    _moviesRequestPage = 1;
  }
}

@JsonSerializable()
class PageableResult {

  const PageableResult(this.totalPages, this.results);

  factory PageableResult.fromJson(Map<String, dynamic> json) => _$PageableResultFromJson(json);

  @JsonKey(name: 'total_pages')
  final int totalPages;
  final List<Movie> results;
}

@JsonSerializable()
class Movie {

  Movie(this.id, this.title, this.overview, this.posterPath, this.releaseDate, this.voteAverage);
  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  final int id;
  final String title;
  final String overview;

  @JsonKey(name: 'poster_path')
  final String posterPath;

  @JsonKey(name: 'release_date')
  final String releaseDate;

  @JsonKey(name: 'vote_average')
  final num voteAverage;

  @JsonKey(ignore: true)
  Future<List<String>> videoKeys;
}

@immutable
@JsonSerializable()
class VideoResult {

  const VideoResult(this.id, this.results);
  factory VideoResult.fromJson(Map<String, dynamic> json) => _$VideoResultFromJson(json);

  final int id;
  final List<Video> results;
}

@immutable
@JsonSerializable()
class Video {

  const Video(this.key);
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  final String key;
}

@immutable
@JsonSerializable()
class Genre {

  const Genre(this.id, this.name);
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  final num id;
  final String name;
}
