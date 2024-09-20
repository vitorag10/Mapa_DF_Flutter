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
  List<LatLng> _polylinePoints = []; // Lista de pontos da linha desenhada
  bool _isDrawing = false; // Controle para o modo de desenho
  bool _showOverlayMap = false; // Controle para exibir ou ocultar a segunda camada de sobreposição

  void _onMapTap(LatLng latLng) {
    if (_isDrawing) {
      setState(() {
        _polylinePoints.add(latLng); // Adiciona os pontos à linha desenhada
      });
    }
  }

  // Inicia o modo de desenho na segunda camada
  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _showOverlayMap = true; // Oculta a primeira camada
    });
  }

  // Finaliza o desenho e volta para a primeira camada
  void _stopDrawing() {
    setState(() {
      _isDrawing = false;
      _showOverlayMap = false; // Mostra a primeira camada novamente após salvar
    });
  }

  // Limpa os pontos desenhados
  void _clearPolyline() {
    setState(() {
      _polylinePoints.clear();
    });
  }

  // Remove o último ponto desenhado
  void _removeLastPoint() {
    setState(() {
      if (_polylinePoints.isNotEmpty) {
        _polylinePoints.removeLast();
      }
    });
  }

  // Reseta o estado do mapa e retorna para a tela inicial
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
          onPressed: _resetMap, // Volta para a tela inicial e reseta o mapa
        ),
        actions: [
          if (_isDrawing)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _stopDrawing, // Salva o desenho e volta para a primeira camada
              tooltip: 'Salvar Linha',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Exibe a primeira camada apenas quando não estiver desenhando
          if (!_showOverlayMap)
            FlutterMap(
              options: MapOptions(
                onTap: (tapPosition, latLng) {
                  _onMapTap(latLng); // Permite adicionar pontos ao clicar no mapa
                },
                initialCenter: LatLng(-15.7801, -47.9292), // Coordenadas centrais de Brasília
                initialZoom: 12.0, // Zoom inicial
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                // Camada de linha desenhada na primeira camada
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
          // Segunda camada do mapa com sobreposição (zoom 19)
          if (_showOverlayMap)
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: FlutterMap(
                  options: MapOptions(
                    onTap: (tapPosition, latLng) {
                      _onMapTap(latLng); // Adiciona pontos também na segunda camada
                    },
                    initialCenter: LatLng(-15.7801, -47.9292), // Coordenadas centrais de Brasília
                    initialZoom: 19.0, // Zoom 19 para maior precisão
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _polylinePoints, // Mostra os pontos da linha desenhada
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
      // Botões flutuantes para controle de desenho
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isDrawing)
            FloatingActionButton(
              onPressed: _removeLastPoint, // Remove o último ponto
              backgroundColor: Colors.orange,
              child: Icon(Icons.undo, color: Colors.white),
              tooltip: 'Desfazer último ponto',
            ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _isDrawing ? _clearPolyline : _startDrawing, // Limpa ou inicia o modo de desenho
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
