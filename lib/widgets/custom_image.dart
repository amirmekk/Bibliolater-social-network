import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (ctx, url) => Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
    errorWidget: (ctx, url, error) => Icon(Icons.error),
  );
}
