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

  void _onMapTap(LatLng latLng) {
    if (_isDrawing) {
      setState(() {
        _polylinePoints.add(latLng);
      });
    }
  }

  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _showOverlayMap = true;
    });
  }

  void _stopDrawing() {
    setState(() {
      _isDrawing = false;
      _showOverlayMap = false;
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
          if (_isDrawing)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _stopDrawing,
              tooltip: 'Salvar Linha',
            ),
        ],
      ),
      body: Row(
        children: [
          // Barra lateral para controle das camadas (parecido com QGIS)
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
                  onChanged: (value) {
                    _toggleBaseLayer();
                  },
                ),
                CheckboxListTile(
                  title: Text("Camada Linha"),
                  value: _showPolyline,
                  onChanged: (value) {
                    _togglePolylineLayer();
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
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isDrawing)
            FloatingActionButton(
              onPressed: _removeLastPoint,
              backgroundColor: Colors.orange,
              child: Icon(Icons.undo, color: Colors.white),
              tooltip: 'Desfazer último ponto',
            ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _isDrawing ? _clearPolyline : _startDrawing,
            backgroundColor: _isDrawing ? Colors.red : Colors.green,
            child: Icon(
              _isDrawing ? Icons.clear : Icons.edit,
              color: Colors.white,
            ),
            tooltip: _isDrawing ? 'Limpar Linha' : 'Iniciar Cadastro',
          ),
        ],
      ),
    );
  }
}
