import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var url =
    Uri.parse("https://api.hgbrasil.com/finance?format=json&key=57525a08");

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          hintStyle: TextStyle(color: Colors.pink),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll() {
    FocusScope.of(context).requestFocus(FocusNode());
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  } // Coloquei para recolher o teclado, pois assim obriga o usuário a clicar

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / precoDolar).toStringAsFixed(2);
    euroController.text = (real / precoEuro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * precoDolar).toStringAsFixed(2);
    euroController.text = (dolar * precoDolar / precoEuro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * precoEuro).toStringAsFixed(2);
    dolarController.text = (euro * precoEuro / euro).toStringAsFixed(2);
  }

  double precoDolar = 0;
  double precoEuro = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        toolbarHeight: 50,
        leading: IconButton(
          onPressed: null,
          padding: EdgeInsets.only(left: 10),
          icon: Icon(Icons.menu, color: Colors.white, size: 30),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _clearAll,
            padding: const EdgeInsets.only(right: 10),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
          ),
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando dados...",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao carregar dados...",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center),
                  );
                } else {
                  precoDolar =
                      snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  precoEuro =
                      snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Reais", "R\$ ", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "U\$ ", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€ ", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Future<Map> getData() async {
  var response = await http.get(url);
  if (response.statusCode == 200) {
    return (jsonDecode(utf8.decode(response.bodyBytes)));
  } else {
    throw Exception("erro ao carregar dados do servidor");
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) f) {
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: f,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      //border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 25),
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25),
  );
}
