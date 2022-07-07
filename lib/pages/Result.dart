import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:diagnoma/classes/database.dart';
import 'package:diagnoma/classes/result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:uuid/uuid.dart';

class ResultScreen extends StatelessWidget {
  File image;
  ResultScreen({required this.image});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ResultScreenState(
        image: image,
      ),
    );
  }
}

class ResultScreenState extends StatefulWidget {
  File image;
  ResultScreenState({required this.image});
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<ResultScreenState> {
  late File _image;
  late List _recognitions;
  late double _imageHeight;
  late double _imageWidth;
  bool _busy = false;
  late Database _database;
  late Result _result;

  List<Probability> recognitionsToProbabilities() {
    List<Probability> probabilities = <Probability>[];

    for (var value in _recognitions) {
      probabilities.add(new Probability(
        confidence: value["confidence"],
        index: value["index"],
        label: value["label"],
      ));
    }
    return probabilities;
  }

//  Future predictImagePicker() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    if (image == null) return;
//    setState(() {
//      _busy = true;
//    });
//    predictImage(image);
//  }

  void _loadResults() async {
    await DatabaseFileRoutines().readResults().then((resultsJson) {
      _database = databaseFromJson(resultsJson);
      _database.result
          .sort((comp1, comp2) => comp2.dateTime.compareTo(comp1.dateTime));
    });
  }

  void _saveImage({required String id}) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    print('Path: $path');
    await _image.copy('$path/$id.jpg');
  }

  Future recognizeImageBinary(File image) async {
    var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image oriImage = img.decodeJpg(imageBytes.asUint8List());
    img.Image resizedImage = img.copyResize(oriImage, height: 512, width: 512);
    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, 512, 127.5, 127.5),
      numResults: 6,
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions!;
    });
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future predictImage(File image) async {
    if (image == null) return;
    await recognizeImage(image);
//    await recognizeImageBinary(image);

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadResults();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = true;
      });
    });

    setState(() {
      _image = widget.image;
    });
    predictImage(_image);
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future recognizeImage(File image) async {
    var uuid = new Uuid();
    String id = uuid.v1();
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    _saveImage(id: id);
    setState(() {
      _recognitions = recognitions!;
      print(_recognitions);
      print("recognitionsType: ${_recognitions.runtimeType}");

      _result = Result(
        id: id,
        dateTime: DateTime.now().toString(),
        probabilities: recognitionsToProbabilities(),
      );
      print(_result);
      _loadResults();
      _database.result.add(_result);
    });
    DatabaseFileRoutines().writeResults(databaseToJson(_database));
  }

  String getLabelWithHighestProbability() {
    double highestConf = 0.0;
    var label;
    for (var value in _recognitions) {
      if (value['confidence'] > highestConf) {
        highestConf = value['confidence'];
        label = value['label'];
      }
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];

    if (_recognitions != null) {
      stackChildren.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _image == null
                  ? Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Text('No image selected.'))
                  : Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Image.file(_image)),
                    ),
              _recognitions != null
                  ? Container(
                      color: Colors.blue[100],
                      padding: EdgeInsets.all(30.0),
                      child: Center(
                        child: Text(
                          getLabelWithHighestProbability(),
                          style: TextStyle(
                            color: Colors.cyan[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  : Text('Not processed.'),
            ],
          ),
        ),
      );
    }

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('diagnoma Home'),
      ),
      body: Center(
        child: Stack(
          children: stackChildren,
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: predictImagePicker,
//        tooltip: 'Pick Image',
//        child: Icon(Icons.image),
//      ),
    );
  }
}
