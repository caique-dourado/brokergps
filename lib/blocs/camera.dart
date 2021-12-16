import 'dart:convert';
import 'dart:io';

import 'package:brokergps/ui/ui_gpsbroker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

File? storedImage;
dynamic imgAutenticacao;
String base64Image = '';

class AbrirCamera extends StatefulWidget {
  const AbrirCamera({Key? key}) : super(key: key);

  @override
  _AbrirCameraState createState() => _AbrirCameraState();
}

class _AbrirCameraState extends State<AbrirCamera> {
  _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    PickedFile? imageFile = await _picker.getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) return;

    setState(() {
      storedImage = File(imageFile.path);
    });
    imgAutenticacao = base64Encode(File(imageFile.path).readAsBytesSync());
  }

  @override
  Widget build(BuildContext context) {
    final camera = storedImage != null
        ? Image.file(
            storedImage!,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        : const Text('Sem captura');

    final cxFotoAtt = Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.7,
      height: 200,
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: camera,
    );
    final buttonCam = IconButton(
      icon: const Icon(
        Icons.photo_camera,
        size: 40,
      ),
      color: const Color(0xff2A4968),
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _takePicture();
      },
    );

    return Flexible(
        child: Row(
      children: [cxFotoAtt, espacamento, buttonCam],
    ));
  }
}
