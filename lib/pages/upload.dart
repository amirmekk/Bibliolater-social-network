import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'home.dart';

class Upload extends StatefulWidget {
  final currentUser;

  const Upload({Key key, this.currentUser}) : super(key: key);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
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
        isUploading ? linearProgress(context) : Text(''),
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
              controller: captionController,
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
              controller: locationController,
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

  createPostInFireStore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'location': location,
      'description': description,
      'timestamp': timestamp,
      'likes': {}
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  handleSubmit() async {
    // enter the state of uploading
    setState(() {
      isUploading = true;
    });
    //compress the image(take time !)
    await compressImage();
    //upload the image and get a url of the file
    String mediaUrl = await uploadImage(file);
    // create post in firestore collection with optional location caption
    createPostInFireStore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    // clear my state

    locationController.clear();
    captionController.clear();
    setState(() {
      isUploading = false;
      file = null;
      postId = Uuid().v4();
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
          onPressed: isUploading ? null : () => handleSubmit(),
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
