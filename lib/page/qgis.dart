import 'package:flutter/material.dart'; // Importa o pacote de UI do Flutter.
import 'package:flutter_map/flutter_map.dart'; // Importa a biblioteca de mapas no Flutter.
import 'package:latlong2/latlong.dart'; // Importa a biblioteca para lidar com coordenadas de latitude e longitude.

// Função principal que inicia o aplicativo.
void main() {
  runApp(MyApp()); // Executa a aplicação 'MyApp'.
}

// Classe principal do aplicativo que define a interface.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define a cor primária do app.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapta a densidade da interface conforme a plataforma.
      ),
      home: QgisPage(), // Define a página principal do app como 'QgisPage'.
    );
  }
}

// Define a página onde será feito o cadastro da linha.
class QgisPage extends StatefulWidget {
  @override
  _QgisPageState createState() => _QgisPageState(); // Cria o estado associado à página.
}

// Classe que gerencia o estado da página 'QgisPage'.
class _QgisPageState extends State<QgisPage> {
  List<LatLng> _polylinePoints = []; // Lista para armazenar os pontos da linha desenhada.
  bool _isDrawing = false; // Variável de controle para saber se o modo de desenho está ativo.
  bool _showOverlayMap = false; // Variável para mostrar o mapa de sobreposição (overlay).

  // Função que é chamada quando o mapa é clicado, adiciona um ponto se o modo de desenho estiver ativo.
  void _onMapTap(LatLng latLng) {
    if (_isDrawing) {
      setState(() {
        _polylinePoints.add(latLng); // Adiciona o ponto à linha desenhada.
      });
    }
  }

  // Ativa o modo de desenho e exibe o mapa de sobreposição.
  void _startDrawing() {
    setState(() {
      _isDrawing = true; // Ativa o modo de desenho.
      _showOverlayMap = true; // Exibe o mapa com zoom 19 para desenho mais preciso.
    });
  }

  // Finaliza o modo de desenho.
  void _stopDrawing() {
    setState(() {
      _isDrawing = false; // Desativa o modo de desenho.
    });
  }

  // Limpa todos os pontos da linha desenhada.
  void _clearPolyline() {
    setState(() {
      _polylinePoints.clear(); // Limpa a lista de pontos.
    });
  }

  // Remove o último ponto adicionado na linha desenhada.
  void _removeLastPoint() {
    setState(() {
      if (_polylinePoints.isNotEmpty) {
        _polylinePoints.removeLast(); // Remove o último ponto da lista.
      }
    });
  }

  // Função que constrói a interface da página.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Linha - Mapa do Distrito Federal'), // Define o título do app.
        actions: [
          if (_isDrawing) // Se o modo de desenho estiver ativo, exibe um botão de salvar.
            IconButton(
              icon: Icon(Icons.check), // Ícone de "check" para finalizar o desenho.
              onPressed: _stopDrawing, // Quando pressionado, finaliza o modo de desenho.
              tooltip: 'Salvar Linha', // Texto que aparece ao passar o mouse sobre o botão.
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camada principal do mapa.
          FlutterMap(
            options: MapOptions(
              onTap: (tapPosition, latLng) {
                _onMapTap(latLng); // Permite adicionar pontos ao clicar no mapa.
              },
              initialCenter: LatLng(-15.7801, -47.9292), // Define o ponto central do mapa (Brasília).
              initialZoom: 12.0, // Define o nível inicial de zoom do mapa.
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // Fonte dos tiles do mapa.
                subdomains: ['a', 'b', 'c'], // Subdomínios para carregar os tiles.
              ),
              // Camada da linha desenhada no mapa.
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _polylinePoints, // Lista de pontos para desenhar a linha.
                    color: Colors.red, // Cor da linha.
                    strokeWidth: 4.0, // Largura da linha.
                  ),
                ],
              ),
            ],
          ),
          // Verifica se o mapa de sobreposição (zoom 19) está ativo.
          if (_showOverlayMap)
            Positioned.fill(
              child: Opacity(
                opacity: 0.7, // Define a opacidade (transparência) do mapa de sobreposição.
                child: FlutterMap(
                  options: MapOptions(
                    onTap: (tapPosition, latLng) {
                      _onMapTap(latLng); // Permite adicionar pontos na camada de sobreposição.
                    },
                    initialCenter: LatLng(-15.7801, -47.9292), // Centro da sobreposição.
                    initialZoom: 19.0, // Zoom 19 para exibir detalhes das vias.
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // Fonte dos tiles do mapa.
                      subdomains: ['a', 'b', 'c'], // Subdomínios para carregar os tiles.
                    ),
                    // Camada da linha desenhada na sobreposição do mapa.
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _polylinePoints, // Lista de pontos para desenhar a linha.
                          color: Colors.red, // Cor da linha.
                          strokeWidth: 4.0, // Largura da linha.
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Botões flutuantes para ações de desenho.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Alinha os botões na parte inferior.
        children: [
          if (_isDrawing) // Exibe o botão de desfazer ponto apenas se estiver desenhando.
            FloatingActionButton(
              onPressed: _removeLastPoint, // Remove o último ponto ao clicar.
              child: Icon(Icons.undo), // Ícone de desfazer (undo).
              tooltip: 'Desfazer último ponto', // Texto que aparece ao passar o mouse sobre o botão.
            ),
          FloatingActionButton(
            onPressed: _isDrawing ? _clearPolyline : _startDrawing, // Limpa ou inicia o modo de desenho.
            child: Icon(_isDrawing ? Icons.clear : Icons.edit), // Ícone de limpar ou editar, dependendo do estado.
            tooltip: _isDrawing ? 'Limpar Linha' : 'Iniciar Cadastro', // Texto do botão dependendo do estado.
          ),
        ],
      ),
    );
  }
}
