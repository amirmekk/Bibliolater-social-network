import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network/widgets/progress.dart';

class Upload extends StatefulWidget {
  final currentUser;

  const Upload({Key key, this.currentUser}) : super(key: key);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  handleTakePhoto() async {
    Navigator.pop(context);
    final file = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    File image = File(file.path);
    setState(() {
      this.file = image;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final file = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    File image = File(file.path);
    setState(() {
      this.file = image;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Photo with camera',
              ),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text(
                'Image from gallery',
              ),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/upload.svg',
              height: orientation == Orientation.portrait ? 300 : 150,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
              child: RaisedButton(
                color: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () {
                  selectImage(context);
                },
                child: Text(
                  'Upload Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                //'Find Users',
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildUploadForm() {
    return ListView(
      children: <Widget>[
        Container(
          height: 220,
          width: MediaQuery.of(context).size.width * 0.80,
          child: Center(
            child: AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  ),
                ),
              ),
            ),
          ),
          //linearProgress(context),
        ),
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              widget.currentUser.photoUrl,
            ),
          ),
          title: Container(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.pin_drop,
            color: Colors.orange,
            size: 35,
          ),
          title: Container(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Where was this photo taken?',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Container(
          width: 200,
          height: 100,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            color: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            onPressed: () {
              print('to do : get user location');
            },
            label: Text(
              'Use current location',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  AppBar buildUploadFormAppBar() {
    return AppBar(
      backgroundColor: Colors.white70,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage),
      title: Text(
        'Caption post',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            print(file);
          },
          child: Text(
            'Post',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: file == null ? null : buildUploadFormAppBar(),
      backgroundColor: file != null
          ? Colors.white
          : Theme.of(context).accentColor.withOpacity(0.8),
      body: file == null ? buildNoContent() : buildUploadForm(),
    );
  }
}
