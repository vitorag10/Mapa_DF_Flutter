import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QgisPage(),
    );
  }
}

class QgisPage extends StatefulWidget {
  @override
  _QgisPageState createState() => _QgisPageState();
}

class _QgisPageState extends State<QgisPage> {
  List<LatLng> _polylinePoints = [];
  bool _isDrawing = false;
  bool _showPolyline = true;
  bool _showBaseLayer = true;
  bool _showOverlayMap = false;
  LatLng? _lastTappedLatLng;
  List<String> _layers = []; // Lista de camadas adicionadas

  // Função para abrir o explorador de arquivos ao adicionar nova camada
  Future<void> _addNewLayer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['shp', 'geojson'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _layers.add(file.path); // Adiciona o caminho do arquivo à lista de camadas
      });
    }
  }

  void _onMapTap(LatLng latLng) {
    if (_isDrawing) {
      setState(() {
        _polylinePoints.add(latLng);
      });
    }

    setState(() {
      _lastTappedLatLng = latLng;
    });
  }

  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _showOverlayMap = true;
    });
  }


  void _clearPolyline() {
    setState(() {
      _polylinePoints.clear();
    });
  }

  void _removeLastPoint() {
    setState(() {
      if (_polylinePoints.isNotEmpty) {
        _polylinePoints.removeLast();
      }
    });
  }

  void _toggleBaseLayer() {
    setState(() {
      _showBaseLayer = !_showBaseLayer;
    });
  }

  void _togglePolylineLayer() {
    setState(() {
      _showPolyline = !_showPolyline;
    });
  }

  void _resetMap() {
    setState(() {
      _polylinePoints.clear();
      _isDrawing = false;
      _showOverlayMap = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  // Função para remover uma camada
  void _removeLayer(String layerPath) {
    setState(() {
      _layers.remove(layerPath);
    });
  }

  // Função para salvar a linha em GeoJSON
  void _saveLineAsGeoJSON() {
    // Aqui você pode implementar a lógica para salvar a linha como GeoJSON
    // Isso pode envolver a conversão dos pontos da polilinha em um formato GeoJSON e salvar em um arquivo.
    // Como exemplo, apenas imprimimos os pontos.
    print("Salvando linha como GeoJSON: $_polylinePoints");
    // Adicione o código para salvar em um arquivo ou mostrar um diálogo de confirmação
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Linha - Mapa do Distrito Federal'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _resetMap,
        ),
        actions: [
          // O botão de salvar aparece apenas no modo de desenho
          if (_isDrawing)
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: _saveLineAsGeoJSON,
                backgroundColor: Color(0xFF003DA5), // Azul do GDF
                child: Icon(Icons.save, color: Colors.white), // Ícone branco
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[200],
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                Text(
                  'Camadas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text("Camada Mapa"),
                  value: _showBaseLayer,
                  activeColor: Color(0xFF003DA5), // Cor da caixa de seleção
                  onChanged: (value) {
                    _toggleBaseLayer();
                  },
                ),
                CheckboxListTile(
                  title: Text("Camada Linha"),
                  value: _showPolyline,
                  activeColor: Color(0xFF003DA5), // Cor da caixa de seleção
                  onChanged: (value) {
                    _togglePolylineLayer();
                  },
                ),
                Divider(),
                Text(
                  'Gerenciar Camadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addNewLayer,
                  icon: Icon(Icons.add, color: Colors.white), // Ícone branco
                  label: Text(
                    'Adicionar Camada',
                    style: TextStyle(color: Colors.white), // Texto branco
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003DA5), // Azul do GDF
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _layers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_layers[index].split('/').last),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeLayer(_layers[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_showOverlayMap)
                  FlutterMap(
                    options: MapOptions(
                      onTap: (tapPosition, latLng) {
                        _onMapTap(latLng);
                      },
                      initialCenter: LatLng(-15.7801, -47.9292),
                      initialZoom: 12.0,
                    ),
                    children: [
                      if (_showBaseLayer)
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                      if (_showPolyline)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _polylinePoints,
                              color: Colors.red,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                    ],
                  ),
                if (_showOverlayMap)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.9,
                      child: FlutterMap(
                        options: MapOptions(
                          onTap: (tapPosition, latLng) {
                            _onMapTap(latLng);
                          },
                          initialCenter: LatLng(-15.7801, -47.9292),
                          initialZoom: 19.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _polylinePoints,
                                color: Colors.red,
                                strokeWidth: 4.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                // Exibir latitude e longitude dentro de caixas brancas com nomes em negrito
                if (_lastTappedLatLng != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Latitude: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '${_lastTappedLatLng!.latitude.toStringAsFixed(7)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Longitude: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '${_lastTappedLatLng!.longitude.toStringAsFixed(7)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isDrawing) ...[
            FloatingActionButton(
              onPressed: _clearPolyline,
              tooltip: 'Excluir Linha',
              backgroundColor: Colors.red, // Vermelho para excluir
              child: Icon(Icons.clear, color: Colors.white), // Ícone branco
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: _removeLastPoint,
              tooltip: 'Desfazer Último Ponto',
              backgroundColor: Colors.orange, // Laranja para desfazer
              child: Icon(Icons.undo, color: Colors.white), // Ícone branco
            ),
          ],
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _startDrawing,
            tooltip: 'Desenhar Linha',
            backgroundColor: Color(0xFF003DA5), // Azul do GDF
            child: Icon(Icons.create, color: Colors.white), // Ícone branco
          ),
        ],
      ),
    );
  }
}
