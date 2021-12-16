import 'dart:async';
import 'dart:io';

import 'package:brokergps/blocs/camera.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

TextStyle style = const TextStyle(fontFamily: "Roboto", fontSize: 14.0);
TextStyle styleFontCoord =
    const TextStyle(fontFamily: "Roboto", fontSize: 20.0);
const espacamento = Padding(padding: EdgeInsets.all(6));
TextEditingController soldCliente = TextEditingController();
TextEditingController lat = TextEditingController();
late Location _localizacao = Location();
bool _loading = false;
String _status = 'Não enviado';
double progresValue = 0;
late String coordenadas;

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

  Future _insert() async {
    try {
      var response = await http.post(
          Uri.parse('https://brokersaoluis.com.br/apis-appgps/insert.php'),
          body: {
            "sold": soldCliente.text.toString(),
            "coord": coordenadas.toString(),
            "foto_faixada": imgAutenticacao.toString()
          });
      setState(() {
        const oneSec = Duration(milliseconds: 50);
        Timer.periodic(oneSec, (Timer t) {
          setState(() {
            progresValue += 0.1;
            if (progresValue.toStringAsFixed(1) == '1.0') {
              if (response.statusCode == 200) {
                _loading = false;
                _status = "Coordenadas Enviadas";
                t.cancel();
                progresValue = 0.0;
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text("Aviso"),
                          content: const Text(
                            "Coordenadas enviadas",
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    textStyle: MaterialStateProperty.all(
                                        const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Roboto',
                                            color: Colors.black))),
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Ok',
                                    style: TextStyle(color: Color(0xff2A4968))))
                          ],
                        ));
              }
            }
          });
        });
      });
      if (response.statusCode != 200) {
        throw HttpException('${response.statusCode}');
      }
    } on SocketException {
      setState(() {
        _status = 'Sem conexão com internet';
      });
    }
  }

  Future _verificacao() async {
    if (storedImage == null) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text("Aviso"),
                content: const Text(
                  "Prezado vendedor, realize a captura da faixada do cliente",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                          textStyle: MaterialStateProperty.all(const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.black))),
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Ok',
                          style: TextStyle(color: Color(0xff2A4968))))
                ],
              ));
    } else {
      setState(() {
        _loading = true;
        _insert();
      });
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            FocusScope.of(context).requestFocus(FocusNode());
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
                    espacamento,
                    _StringPosicaoLat != ''
                        ? Text(
                            "|${soldCliente.text}||||$_StringPosicaoLat|$_StringPosicaoLong|S",
                            style: styleFontCoord,
                          )
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
                    // ignore: unrelated_type_equality_checks
                    Card(
                        elevation: 4,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                                title: const Text('Coordenadas do Cliente'),
                                subtitle: Text('Status: $_status')),
                            _loading ? _linearProgressIndicator() : Container(),
                            Text('${progresValue.toStringAsPrecision(2)}%')
                          ],
                        )),
                    const Spacer(
                      flex: 1,
                    ),
                    Row(
                      children: [
                        espacamento,
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _verificacao();
                              },
                              child: const Text('Enviar'),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green))),
                        ),
                        espacamento,
                      ],
                    ),

                    espacamento
                  ],
                ))));
  }

  pegarLocalizacao() async {
    late Location _localizacao = Location();

    await _localizacao.getLocation().then((posicao) {
      setState(() {
        _StringPosicaoLat = "${posicao.latitude}";
        _StringPosicaoLong = "${posicao.longitude}";
        coordenadas =
            "|${soldCliente.text}||||$_StringPosicaoLat|$_StringPosicaoLong|S";
      });
    }).catchError((e) {
      _StringPosicaoLat = e.toString();
      _StringPosicaoLong = e.toString();
    });
  }

  Widget _linearProgressIndicator() {
    return LinearProgressIndicator(
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2A4968)),
      value: progresValue,
    );
  }
}
