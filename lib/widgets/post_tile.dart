import 'package:flutter/material.dart';
import 'package:social_network/widgets/custom_image.dart';
import 'package:social_network/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('showing post');
      },
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
