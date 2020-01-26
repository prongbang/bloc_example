import 'package:bloc_example/core/widget/bottom_loader.dart';
import 'package:bloc_example/post/bloc/post_bloc.dart';
import 'package:bloc_example/post/bloc/post_event.dart';
import 'package:bloc_example/post/bloc/post_state.dart';
import 'package:bloc_example/post/presenter/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class PostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) =>
              PostBloc(httpClient: http.Client())..add(Fetch()),
          child: _PostPage(),
        ),
      ),
    );
  }
}

class _PostPage extends StatefulWidget {
  @override
  __PostPageState createState() => __PostPageState();
}

class __PostPageState extends State<_PostPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(Fetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostError) {
          return Center(child: Text('failed to fetch posts'));
        }
        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return Center(child: Text('no posts'));
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.posts.length
                  ? BottomLoader()
                  : PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
