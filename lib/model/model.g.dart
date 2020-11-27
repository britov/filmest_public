// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageableResult _$PageableResultFromJson(Map<String, dynamic> json) {
  return PageableResult(
    json['total_pages'] as int,
    (json['results'] as List)
        ?.map(
            (e) => e == null ? null : Movie.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PageableResultToJson(PageableResult instance) =>
    <String, dynamic>{
      'total_pages': instance.totalPages,
      'results': instance.results,
    };

Movie _$MovieFromJson(Map<String, dynamic> json) {
  return Movie(
    json['id'] as int,
    json['title'] as String,
    json['overview'] as String,
    json['poster_path'] as String,
    json['release_date'] as String,
    json['vote_average'] as num,
  );
}

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'release_date': instance.releaseDate,
      'vote_average': instance.voteAverage,
    };

VideoResult _$VideoResultFromJson(Map<String, dynamic> json) {
  return VideoResult(
    json['id'] as int,
    (json['results'] as List)
        ?.map(
            (e) => e == null ? null : Video.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$VideoResultToJson(VideoResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'results': instance.results,
    };

Video _$VideoFromJson(Map<String, dynamic> json) {
  return Video(
    json['key'] as String,
  );
}

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'key': instance.key,
    };

Genre _$GenreFromJson(Map<String, dynamic> json) {
  return Genre(
    json['id'] as num,
    json['name'] as String,
  );
}

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
