import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_create/generated/i18n.dart';
import 'package:flutter_create/model/model.dart';
import 'package:flutter_create/widget/common.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isVisibleHelpInfo = false;
  static const _isHelpInfoShowedKey = 'helpInfoShowed';
  final _videoIndex$ = BehaviorSubject.seeded(0);
  final _index$ = BehaviorSubject.seeded(0);

  YoutubePlayerController _youtubePlayerController;
  SharedPreferences _prefs;

  final _swipeTrailersController = FlareControls();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SharedPreferences.getInstance().then((value) {
      _prefs ??= value;
      if (_prefs.getBool(_isHelpInfoShowedKey) != true) {
        _prefs.setBool(_isHelpInfoShowedKey, true);
        _isVisibleHelpInfo = true;
        if (mounted) return;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: _buildBottomAppBar(context),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              _buildBody(context),
              if (_isVisibleHelpInfo == true) _buildHelpInfo(context),
            ],
          ),
        ),
      );

  void _removeHelpInfo() {
    if (_isVisibleHelpInfo == true) {
      setState(() => _isVisibleHelpInfo = false);
    }
  }

  Widget _buildHelpInfo(BuildContext context) => GestureDetector(
        onPanStart: (_) => _removeHelpInfo(),
        onPanEnd: (_) => _removeHelpInfo(),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.white),
          child: Column(children: <Widget>[
            AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                      child: FlareActor(
                        'assets/swipe.flr',
                        animation: 'to_right',
                        callback: (_) => _swipeTrailersController.play('to_right'),
                      ),
                    ),
                    Text(S.of(context).swipeTrailer)
                  ],
                ))),
            Expanded(
                child: Center(
                    child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 80,
                  child: FlareActor(
                    'assets/swipe.flr',
                    controller: _swipeTrailersController,
                  ),
                ),
                Text(S.of(context).swipeFilms)
              ],
            )))
          ]),
        ),
      );

  Widget _buildBody(BuildContext context) => Column(children: [
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
              Colors.transparent,
              Colors.black,
            ], stops: [
              0.5,
              1
            ]),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPlayer(),
          ),
        ),
        Expanded(child: _buildMoviesPageView(context))
      ]);

  Widget _buildMoviesPageView(BuildContext context) => Consumer<FilmsModel>(
        builder: (context, model, child) => PageView.builder(
            onPageChanged: _index$.add,
            itemCount: model.movies.length,
            controller: PageController(initialPage: _index$.value),
            itemBuilder: (c, i) {
              if (i + 5 == model.movies.length) {
                model.loadMovies();
              }
              final movie = model.movies.elementAt(i);
              movie.videoKeys ??= model.getVideo(movie.id);
              movie.videoKeys.then((_) {});
              return Container(
                color: Colors.black,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const Icon(Icons.calendar_today),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Text(
                              MaterialLocalizations.of(context).formatShortDate(
                                DateTime.tryParse(movie.releaseDate),
                              ),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                              child: Text(
                                'IMDb',
                                style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: '${movie.voteAverage}',
                              style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w900),
                              children: [
                                TextSpan(
                                  text: '/10',
                                  style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('     ${movie.overview}',
                                textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headline6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      );

  Widget _buildPlayer() => Consumer<FilmsModel>(
        builder: (context, model, child) => StreamBuilder(
            stream: _index$.asyncMap((i) => model.movies?.elementAt(i)?.videoKeys),
            builder: (context, AsyncSnapshot<List<String>> videoKeysSnapshot) {
              _videoIndex$.add(0);
              return videoKeysSnapshot.data?.isEmpty != false
                  ? const SizedBox.shrink()
                  : Container(
                      color: Theme.of(context).primaryColor,
                      child: PageView.builder(
                        onPageChanged: _videoIndex$.add,
                        itemCount: videoKeysSnapshot.data.length,
                        itemBuilder: (context, i) => videoKeysSnapshot.data == null
                            ? const SizedBox.shrink()
                            : YoutubePlayer(
                                key: ValueKey(videoKeysSnapshot.data[i]),
                                showVideoProgressIndicator: true,
                                controller: _youtubePlayerController?.initialVideoId == videoKeysSnapshot.data[i]
                                    ? _youtubePlayerController
                                    : _youtubePlayerController = YoutubePlayerController(
                                        initialVideoId: videoKeysSnapshot.data[i],
                                        flags: const YoutubePlayerFlags(
                                          disableDragSeek: true,
                                          autoPlay: false,
                                          enableCaption: false,
                                        ),
                                      ),
                                bottomActions: <Widget>[
                                  const SizedBox(width: 14),
                                  CurrentPosition(),
                                  const SizedBox(width: 8),
                                  ProgressBar(isExpanded: true),
                                  RemainingDuration(),
                                ],
                              ),
                      ),
                    );
            }),
      );

  Widget _buildBottomAppBar(BuildContext context) => BottomAppBar(
        color: Colors.black12,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<FilmsModel>(
              builder: (contest, model, child) => StreamBuilder(
                stream: _index$.asyncExpand((i) => model.movies[i].videoKeys.asStream()),
                builder: (context, AsyncSnapshot<List<String>> snapshot) => IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: snapshot.data?.isEmpty != false
                      ? null
                      : () => Share.share('https://youtu.be/${snapshot.data[_videoIndex$.value]}'),
                ),
              ),
            ),
            Consumer<FilmsModel>(
                builder: (contest, model, child) => FlatButton(
                      child: Text(S.of(context).searchInGoogle),
                      onPressed: () => launch(
                        'https://www.google.com/search?q=${model.movies[_index$.value].title..replaceAll(' ', '+')}+${S.of(context).online}',
                        forceSafariVC: true,
                        forceWebView: true,
                      ),
                    )),
            Consumer<FilmsModel>(
              builder: (contest, model, child) => IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => BottomSheet(
                          onClosing: () {},
                          builder: (_) => Consumer<FilmsModel>(
                            builder: (contest, model, child) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                                      child: Text(
                                        'Filters',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text('Release date'),
                                      subtitle: Text(_buildReleaseDateSubtitle(model.fromYear, model.toYear)),
                                      onTap: () async {
                                        final result = await showModalBottomSheet<Tuple2<int, int>>(
                                            context: context,
                                            builder: (_) => SelectDateRange(
                                                  fromYear: model.fromYear,
                                                  toYear: model.toYear,
                                                ));
                                        if (result != null) {
                                          context.read<FilmsModel>().setDateFilter(result.item1, result.item2);
                                        }
                                      },
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            'Genre',
                                            textAlign: TextAlign.start,
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: DropdownButtonFormField<int>(
                                        value: model.currentGenre,
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('All'),
                                          ),
                                          for (final genre in model.genres)
                                            DropdownMenuItem<int>(
                                              value: genre['id'],
                                              child: Text(genre['name']),
                                            )
                                        ],
                                        onChanged: (value) {
                                          context.read<FilmsModel>().currentGenre = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
            )
          ],
        ),
      );

  String _buildReleaseDateSubtitle(int fromYear, int toYear) {
    if (fromYear == null && toYear == null) {
      return 'Any';
    }

    var result = '';

    if (fromYear != null) {
      result += 'After $fromYear';
    }
    if (toYear != null && fromYear != null) {
      result += ' and before $fromYear';
    } else if (toYear != null) {
      result += 'Before $toYear';
    }

    return result;
  }
}
