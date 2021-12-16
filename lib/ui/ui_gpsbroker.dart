import 'package:brokergps/blocs/camera.dart';
import 'package:brokergps/blocs/send_gpsbroker.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';

TextStyle style = const TextStyle(fontFamily: "Roboto", fontSize: 14.0);
const espacamento = Padding(padding: EdgeInsets.all(6));
TextEditingController soldCliente = TextEditingController();
TextEditingController lat = TextEditingController();
late Location _localizacao = Location();

class UiGps extends StatefulWidget {
  const UiGps({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _UiGpsState createState() => _UiGpsState();
}

class _UiGpsState extends State<UiGps> {
  late bool _habilitarServico;
  dynamic _permissaoGarantida;

  // ignore: non_constant_identifier_names
  late String _StringPosicaoLat = '';
  // ignore: non_constant_identifier_names
  late String _StringPosicaoLong = '';

  permLocalizar() async {
    _habilitarServico = await _localizacao.serviceEnabled();
    if (!_habilitarServico) {
      _habilitarServico = await _localizacao.requestService();
      if (!_habilitarServico) {
        return;
      }
    }

    _permissaoGarantida = await _localizacao.hasPermission();
    if (_permissaoGarantida == PermissionStatus.denied) {
      _permissaoGarantida = await _localizacao.requestPermission();
      if (_permissaoGarantida != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.fromLTRB(6.0, 14.0, 6.0, 1.0),
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: style,
                          controller: soldCliente,
                          onChanged: (text) => {},
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(6),
                            labelText: "Sold do cliente",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ),
                      espacamento,
                      Flexible(
                          child: IconButton(
                        icon: const Icon(Icons.gps_fixed),
                        onPressed: () {
                          pegarLocalizacao();
                        },
                        iconSize: 30.0,
                        color: const Color(0xff2A4968),
                      )),
                    ],
                  ),
                  espacamento,
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: style,
                          enabled: false,
                          controller: TextEditingController()
                            ..text = _StringPosicaoLat,
                          onChanged: (text) => {},
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(6),
                            labelText: "Latitude",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ),
                      espacamento,
                      Flexible(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: style,
                          enabled: false,
                          controller: TextEditingController()
                            ..text = _StringPosicaoLong,
                          onChanged: (text) => {},
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(6),
                            labelText: "Longitude",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  espacamento,
                  Row(children: const [
                    Text('Coordenadas*',
                        style: TextStyle(
                          color: Colors.red,
                        )),
                  ]),
                  _StringPosicaoLat != ''
                      ? Text(
                          "|${soldCliente.text}||||$_StringPosicaoLat|$_StringPosicaoLong|S")
                      : const Text(''),
                  espacamento,
                  Row(
                    children: <Widget>[
                      Builder(builder: (context) {
                        return const Text('Foto da faixada do cliente*',
                            style: TextStyle(
                              color: Colors.red,
                            ));
                      }),
                    ],
                  ),
                  espacamento,
                  SizedBox(
                    child: Row(
                      children: const [AbrirCamera()],
                    ),
                  ),
                  espacamento,
                  espacamento,
                  Row(
                    children: const [
                      Text(
                          'INSTRUÇÕES DE USO:\n1- Insira o sold do cliente.\n2- Pressione no botão do gps (Ao lado de Sold).\n3- Tire a foto da faixada do cliente.\n4- Pressionar no botão enviar')
                    ],
                  ),
                  espacamento,
                  espacamento,
                  espacamento,
                  // ignore: unrelated_type_equality_checks

                  SizedBox(
                    child: Row(
                      children: const [EnviarCoord()],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  pegarLocalizacao() async {
    late Location _localizacao = Location();

    await _localizacao.getLocation().then((posicao) {
      setState(() {
        _StringPosicaoLat = "${posicao.latitude}";
        _StringPosicaoLong = "${posicao.longitude}";
      });
    }).catchError((e) {
      _StringPosicaoLat = e.toString();
      _StringPosicaoLong = e.toString();
    });
  }
}
