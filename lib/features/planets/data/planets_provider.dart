import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';

class Planet {
  final String id;
  final String name;
  final double mass;
  final double distance;
  final String imageUrl;

  Planet({
    required this.id,
    required this.name,
    required this.mass,
    required this.distance,
    required this.imageUrl,
  });

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      id: json['id'].toString(),
      name: json['name'] ?? 'Nombre desconocido',
      mass: (json['mass'] as num?)?.toDouble() ?? 0.0,
      distance: (json['orbital_distance_km'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image'] ?? '',
    );
  }
}

final planetsProvider = FutureProvider<List<Planet>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://us-central1-a-academia-espacial.cloudfunctions.net/planets'),
    );

    if (response.statusCode == 200) {
      // 1. Imprimir la respuesta sin decodificar
      print('Respuesta de la API sin decodificar: ${response.body}');

      final dynamic decodedResponse = jsonDecode(response.body);

      // 2. Imprimir la respuesta decodificada
      print('Respuesta de la API decodificada: $decodedResponse');

      if (decodedResponse is Map && decodedResponse.containsKey('data')) {
        final dynamic data = decodedResponse['data'];

        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => Planet.fromJson(json))
              .toList();
        } else {
          // 3. Manejo de error detallado
          throw FormatException(
              'La clave "data" no contiene una lista de planetas válida. Tipo de "data": ${data.runtimeType}');
        }
      } else {
        // 3. Manejo de error detallado
        throw FormatException(
            'La respuesta de la API no contiene la clave "data". Respuesta: $decodedResponse');
      }
    } else {
      throw ClientException(
          'Error al cargar los planetas: Código ${response.statusCode}');
    }
  } on ClientException catch (e) {
    throw Exception('Error de red al obtener los planetas: ${e.toString()}');
  } on FormatException catch (e) {
    throw Exception(
        'Error de formato JSON al obtener los planetas: ${e.toString()}');
  } catch (e) {
    throw Exception(
        'Error desconocido al obtener los planetas: ${e.toString()}');
  }
});
