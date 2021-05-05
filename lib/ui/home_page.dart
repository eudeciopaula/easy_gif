import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _pesquisa;
  int _offSet = 0;
  int _gifPorPagina = 25;

  Future<Map>_obterGifs() async{
    http.Response response;
    if (_pesquisa == null || _pesquisa.isEmpty)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=Myfcfs9rNu7BaWumaWQHTTxRnzYW82KH&limit=26&rating=g");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=Myfcfs9rNu7BaWumaWQHTTxRnzYW82KH&q=$_pesquisa&limit=$_gifPorPagina&offset=$_offSet&rating=g&lang=pt");
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obterGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
                decoration: InputDecoration(
                    labelText: "Pesquise aqui",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                    ),
                ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                  setState(() {
                    _pesquisa = text;
                    _offSet = 0;
                  });
               },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _obterGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.00,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) return Container();
                    else return _criarTabelaGif(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _obterContagem(List data){
    if (_pesquisa == null || _pesquisa.isEmpty){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Widget _criarTabelaGif(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _obterContagem(snapshot.data["data"]),
        itemBuilder: (context, index){
          if (_pesquisa == null || _pesquisa.isEmpty || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_width"]["url"],
                height: 300.0,
                fit: BoxFit.cover,

              ),
              onTap: (){
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_width"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offSet += _gifPorPagina;
                    _obterGifs();
                  });
                },
              ),
            );
        }
    );
  }

}
