import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostsPage(),
    ));

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'],
        title: json['title'],
        body: json['body'],
      );
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<List<Post>> futuroPosts;

  @override
  void initState() {
    super.initState();
    futuroPosts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (res.statusCode != 200) {
      throw Exception('Error al cargar publicaciones: HTTP ${res.statusCode}');
    }
    final List datos = jsonDecode(res.body);
    return datos.map((e) => Post.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluación: Posts REST')),
      body: FutureBuilder<List<Post>>(
        future: futuroPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No hay publicaciones disponibles'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futuroPosts = fetchPosts();
              });
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(post: post),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle #${post.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}