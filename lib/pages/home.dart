import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Result.dart';

class Home extends StatelessWidget {
  String _value;

  @override
  Widget build(BuildContext context) {
    return MyHome();
  }
}

class MyHome extends StatelessWidget {
  Future<File> pickCameraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future<File> pickFileImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    return image;
  }

  void _pickImage(
      {String imageSource, BuildContext context, bool fullScreenDialog}) {
    if (imageSource == 'camera') {
      pickCameraImage().then((image) {
        if(image != null)
        _openPageResult(
          context: context,
          fullScreenDialog: fullScreenDialog,
          image: image,
        );
        else
          return;
      });
    } else if (imageSource == 'gallery') {
      pickFileImage().then((image) {
        if(image != null)
        _openPageResult(
          context: context,
          fullScreenDialog: fullScreenDialog,
          image: image,
        );
        else
          return;
      });
    }
  }

  void _openPageResult(
      {BuildContext context, bool fullScreenDialog = false, File image}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: fullScreenDialog,
        builder: (context) => ResultScreen(
          image: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            iconSize: 50.0,
            padding: const EdgeInsets.all(20.0),
            tooltip: 'Capture retina image using camera',
            onPressed: () {
              _pickImage(
                imageSource: 'camera',
                context: context,
                fullScreenDialog: true,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            iconSize: 50.0,
            padding: const EdgeInsets.all(20.0),
            tooltip: 'Select retina image from gallery',
            onPressed: () {
              _pickImage(
                imageSource: 'gallery',
                context: context,
                fullScreenDialog: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
