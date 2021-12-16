import 'package:flutter/material.dart';

class EnviarCoord extends StatefulWidget {
  const EnviarCoord({Key? key}) : super(key: key);

  @override
  _EnviarCoordState createState() => _EnviarCoordState();
}

class _EnviarCoordState extends State<EnviarCoord> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 40,
      child: ElevatedButton(
          onPressed: () {},
          child: const Text('Enviar'),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green))),
    );
  }
}
