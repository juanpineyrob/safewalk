import 'dart:convert';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/ubicacion.dart';
import '../models/zona_peligrosa.dart';

class RutaCandidata {
  final List<LatLng> puntos;
  final double distanciaMetros;
  final double duracionSegundos;
  final bool conDetour;
  int intrusiones;

  RutaCandidata({
    required this.puntos,
    required this.distanciaMetros,
    required this.duracionSegundos,
    this.conDetour = false,
    this.intrusiones = 0,
  });
}

class RuteoException implements Exception {
  RuteoException(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'RuteoException: $mensaje';
}

class RuteoService {
  RuteoService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _osrmBase = 'https://router.project-osrm.org';

  /// Consulta OSRM. Si se pasa `via`, fuerza un waypoint intermedio
  /// (origen → via → destino) para que la ruta evite cierta zona.
  Future<List<RutaCandidata>> obtenerRutas(
    Ubicacion origen,
    Ubicacion destino, {
    Ubicacion? via,
  }) async {
    final segmentos = via != null
        ? '${origen.longitud},${origen.latitud};'
            '${via.longitud},${via.latitud};'
            '${destino.longitud},${destino.latitud}'
        : '${origen.longitud},${origen.latitud};'
            '${destino.longitud},${destino.latitud}';
    final uri = Uri.parse(
      '$_osrmBase/route/v1/foot/$segmentos'
      '?alternatives=true&overview=full&geometries=geojson&steps=false',
    );
    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw RuteoException('OSRM respondió ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['code'] != 'Ok') {
      throw RuteoException('OSRM code=${body['code']}');
    }
    final rutas = body['routes'] as List<dynamic>;
    return rutas.map((r) {
      final map = r as Map<String, dynamic>;
      final geom = map['geometry'] as Map<String, dynamic>;
      final coords = (geom['coordinates'] as List<dynamic>)
          .map((p) => LatLng(
                ((p as List<dynamic>)[1] as num).toDouble(),
                ((p)[0] as num).toDouble(),
              ))
          .toList();
      return RutaCandidata(
        puntos: coords,
        distanciaMetros: (map['distance'] as num).toDouble(),
        duracionSegundos: (map['duration'] as num).toDouble(),
        conDetour: via != null,
      );
    }).toList();
  }

  /// Estrategia "ruta segura":
  /// 1) Pide a OSRM rutas base entre origen y destino.
  /// 2) Si la mejor ya no atraviesa zonas, listo.
  /// 3) Si todavía cruza zonas: por cada zona cruzada genera dos waypoints
  ///    perpendiculares a la línea origen→destino (izq/der) fuera del radio
  ///    de la zona y reconsulta OSRM en paralelo.
  /// 4) Junta todas las candidatas y devuelve la lista ordenada por
  ///    [intrusiones] y [distanciaMetros].
  Future<List<RutaCandidata>> obtenerRutasConEvasion(
    Ubicacion origen,
    Ubicacion destino,
    List<ZonaPeligrosa> zonas,
  ) async {
    final base = await obtenerRutas(origen, destino);
    if (base.isEmpty) return base;

    _anotarIntrusiones(base, zonas);
    _ordenar(base);

    if (zonas.isEmpty || base.first.intrusiones == 0) return base;

    // Tomamos hasta 3 zonas cruzadas (limita la cantidad de calls extra).
    final cruzadas = _zonasCruzadas(base.first, zonas).take(3).toList();

    final futures = <Future<List<RutaCandidata>>>[];
    for (final z in cruzadas) {
      for (final via in _puntosDetour(origen, destino, z)) {
        futures.add(
          obtenerRutas(origen, destino, via: via)
              .catchError((_) => <RutaCandidata>[]),
        );
      }
    }

    final extras = (await Future.wait(futures)).expand((e) => e).toList();
    _anotarIntrusiones(extras, zonas);

    final todas = [...base, ...extras];
    _ordenar(todas);
    return todas;
  }

  void _anotarIntrusiones(
      List<RutaCandidata> rutas, List<ZonaPeligrosa> zonas) {
    for (final ruta in rutas) {
      var contador = 0;
      for (final punto in ruta.puntos) {
        for (final zona in zonas) {
          final d = Geolocator.distanceBetween(
            punto.latitude,
            punto.longitude,
            zona.ubicacion.latitud,
            zona.ubicacion.longitud,
          );
          if (d <= zona.radioMetros) {
            contador++;
            break;
          }
        }
      }
      ruta.intrusiones = contador;
    }
  }

  void _ordenar(List<RutaCandidata> rutas) {
    rutas.sort((a, b) {
      final porIntrusion = a.intrusiones.compareTo(b.intrusiones);
      if (porIntrusion != 0) return porIntrusion;
      return a.distanciaMetros.compareTo(b.distanciaMetros);
    });
  }

  List<ZonaPeligrosa> _zonasCruzadas(
    RutaCandidata ruta,
    List<ZonaPeligrosa> zonas,
  ) {
    final cruzadas = <ZonaPeligrosa>[];
    for (final z in zonas) {
      final dentro = ruta.puntos.any((p) =>
          Geolocator.distanceBetween(
            p.latitude,
            p.longitude,
            z.ubicacion.latitud,
            z.ubicacion.longitud,
          ) <=
          z.radioMetros);
      if (dentro) cruzadas.add(z);
    }
    return cruzadas;
  }

  /// Genera dos puntos perpendiculares a la línea origen→destino, ambos
  /// fuera del radio de la zona, uno a cada lado.
  List<Ubicacion> _puntosDetour(
    Ubicacion origen,
    Ubicacion destino,
    ZonaPeligrosa zona,
  ) {
    final bearingOD = Geolocator.bearingBetween(
      origen.latitud,
      origen.longitud,
      destino.latitud,
      destino.longitud,
    );
    final perpIzq = (bearingOD - 90 + 360) % 360;
    final perpDer = (bearingOD + 90) % 360;
    final offsetM = zona.radioMetros + 60; // buffer extra para que OSRM no toque el círculo

    final pIzq = _offset(
        zona.ubicacion.latitud, zona.ubicacion.longitud, perpIzq, offsetM);
    final pDer = _offset(
        zona.ubicacion.latitud, zona.ubicacion.longitud, perpDer, offsetM);

    return [
      Ubicacion(latitud: pIzq[0], longitud: pIzq[1], timestamp: DateTime.now()),
      Ubicacion(latitud: pDer[0], longitud: pDer[1], timestamp: DateTime.now()),
    ];
  }

  /// Devuelve [lat, lon] desplazado `distM` metros con `bearingDeg` grados
  /// desde (lat, lon) usando fórmula great-circle.
  List<double> _offset(
      double lat, double lon, double bearingDeg, double distM) {
    const r = 6371000.0;
    final br = bearingDeg * math.pi / 180;
    final lat1 = lat * math.pi / 180;
    final lon1 = lon * math.pi / 180;
    final dr = distM / r;
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(dr) +
          math.cos(lat1) * math.sin(dr) * math.cos(br),
    );
    final lon2 = lon1 +
        math.atan2(
          math.sin(br) * math.sin(dr) * math.cos(lat1),
          math.cos(dr) - math.sin(lat1) * math.sin(lat2),
        );
    return [lat2 * 180 / math.pi, lon2 * 180 / math.pi];
  }
}

/// Selector puro: cuenta intrusiones por ruta, ordena y devuelve la mejor.
/// Se conserva como función separada por compatibilidad y para tests unitarios.
RutaCandidata seleccionarRutaSegura(
  List<RutaCandidata> rutas,
  List<ZonaPeligrosa> zonas,
) {
  if (rutas.isEmpty) {
    throw RuteoException('No hay rutas candidatas');
  }
  for (final ruta in rutas) {
    var contador = 0;
    for (final punto in ruta.puntos) {
      for (final zona in zonas) {
        final distancia = Geolocator.distanceBetween(
          punto.latitude,
          punto.longitude,
          zona.ubicacion.latitud,
          zona.ubicacion.longitud,
        );
        if (distancia <= zona.radioMetros) {
          contador++;
          break;
        }
      }
    }
    ruta.intrusiones = contador;
  }
  rutas.sort((a, b) {
    final porIntrusion = a.intrusiones.compareTo(b.intrusiones);
    if (porIntrusion != 0) return porIntrusion;
    return a.distanciaMetros.compareTo(b.distanciaMetros);
  });
  return rutas.first;
}
