import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widget.dart';

class SDUIButton extends SDUIWidget {
  String? caption;

  @override
  Widget toWidget(BuildContext context) => ElevatedButton(
        child: Text(caption ?? "<NONE>"),
        onPressed: () {
          super.action.execute(context, null);
        },
      );

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    caption = json?["caption"];
    return this;
  }
}
