import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "c3d361b7f5e7965cbc5032177e7561bc9cce439a";
  StreamController _streamController;
  Stream _stream;
  Timer _debounce;
  TextEditingController _controller = TextEditingController();
  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");

    http.Response response = await http.get(
        Uri.parse(_url + _controller.text.trim()),
        headers: {"Authorization": "Token " + _token});
    if (response.statusCode == 200) {
      _streamController.add(jsonDecode(response.body));
    }
  }

  @override
  void initState() {
    _streamController = StreamController();
    _stream = _streamController.stream;
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dictionay"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 12, bottom: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white),
                child: TextFormField(
                  onChanged: (String text) {},
                  controller: _controller,
                  decoration: InputDecoration(
                      hintText: "Search Word Here",
                      contentPadding: EdgeInsets.only(left: 48),
                      border: InputBorder.none),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _search();
              },
              color: Colors.white,
            )
          ]),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Enter a word"),
              );
            }

            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]
                                    ["image_url"] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data["definitions"][index]["image_url"]),
                              ),
                        title: Text(_controller.text.trim() +
                            "(" +
                            snapshot.data["definitions"][index]["type"] +
                            ")"),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                            snapshot.data["definitions"][index]["definition"]))
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
