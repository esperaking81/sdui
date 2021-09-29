import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'parser.dart';

/// Returns the content of a route
abstract class RouteContentProvider {
  Future<String> getContent();
}

/// Static implementation of RouteContentProvider with static content
class StaticRouteContentProvider implements RouteContentProvider {
  String json;

  StaticRouteContentProvider(this.json);

  @override
  Future<String> getContent() {
    return Future(() => json);
  }
}

/// Static implementation of RouteContentProvider with static content
class HttpRouteContentProvider implements RouteContentProvider {
  static final Logger _logger = Logger(
    printer: LogfmtPrinter(),
  );

  String url;

  HttpRouteContentProvider(this.url);

  @override
  Future<String> getContent() async {
    _logger.i('Loading content from $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('FAILED: $url - ${response.statusCode}');
    }
  }
}

/// Dynamic Route
class DynamicRoute extends StatefulWidget {
  final RouteContentProvider provider;

  const DynamicRoute({Key? key, required this.provider}) : super(key: key);

  @override
  DynamicRouteState createState() => DynamicRouteState(provider);
}

class DynamicRouteState extends State<DynamicRoute> {
  final RouteContentProvider provider;
  late Future<String> content;

  DynamicRouteState(this.provider);

  @override
  void initState() {
    super.initState();
    content = provider.getContent();
  }

  @override
  Widget build(BuildContext context) => Center(
      child: FutureBuilder<String>(
          future: content,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var json = jsonDecode(snapshot.data!);
              return SDUIParser.fromJson(json).toWidget(context);
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          }));
}
