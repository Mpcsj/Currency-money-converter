import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const REQUEST_URL = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
      home: HomePage(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.black
    ),
  ));
}

Future<Map> loadDataApi() async {
  http.Response response = await http.get(REQUEST_URL);
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double dolar;
  double euro;
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final realController = TextEditingController();

  void updateCurrencies(Map data){
    // setState(() {
      dolar = data['results']['currencies']['USD']['buy'];
      euro = data['results']['currencies']['EUR']['buy'];
    // });
  }
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  void _onRealChange(String value){
    if(value.isEmpty){
      _clearAll();
    }else{
      double real = double.parse(value);
      dolarController.text = (real/dolar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
    }
  }
  void _onDolarChange(String value){
    if(value.isEmpty){
      _clearAll();
    }else{
      double dolar = double.parse(value);
      realController.text = (dolar*this.dolar).toStringAsFixed(2);
      euroController.text = (dolar*this.dolar/euro).toStringAsFixed(2);
    }
  }
  void _onEuroChange(String value){
    if(value.isEmpty){
      _clearAll();
    }else{
      double euro = double.parse(value);
      realController.text = (euro*this.euro).toStringAsFixed(2);
      dolarController.text = (euro*this.euro/dolar).toStringAsFixed(2);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
          title: Text(
            "\$ Conversor de moedas",
          ),
          backgroundColor: Colors.amber),
      body: FutureBuilder<Map>(
        future: loadDataApi(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                'Carregando ...',
                style: TextStyle(color: Colors.amberAccent),
              ));
            default:
              if(snapshot.hasError){
                return Center(
                    child: Text(
                      'Erro ao carregar :(',
                      style: TextStyle(color: Colors.amberAccent),
                    ));
              }else{
                updateCurrencies(snapshot.data);
                //Container(color: Colors.green)
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on,size:150,color:Colors.amber),
                      buildTextField('Dólares', 'U\$',dolarController,_onDolarChange),
                      Divider(),
                      buildTextField('Reais', 'R\$',realController,_onRealChange),
                      Divider(),
                      buildTextField('Euros', '€',euroController,_onEuroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label,
    String prefix,
    TextEditingController controller,
    Function onChange){
  return(
      TextField(
        controller: controller,
        onChanged: onChange,
        style: TextStyle(
            color: Colors.amber
        ),
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.0),
            ),
            prefixText: prefix,
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.amber,

            )
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      )
  );
}