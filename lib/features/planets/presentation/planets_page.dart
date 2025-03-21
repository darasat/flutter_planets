import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart'; // Importa ClientException

class Planet {
  final String id;
  final String name;

  Planet({required this.id, required this.name});

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      id: json['id'].toString(),
      name: json['name'] ?? 'Nombre desconocido',
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
      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map &&
          decodedResponse.containsKey('data') &&
          decodedResponse['data'] is List) {
        final List<dynamic> data = decodedResponse['data'];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => Planet.fromJson(json))
            .toList();
      } else {
        throw FormatException(
            'La respuesta de la API no contiene una lista de planetas válida.');
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

class PlanetsPage extends ConsumerWidget {
  const PlanetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planetsAsync = ref.watch(planetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planetas')),
      body: planetsAsync.when(
        data: (planets) {
          if (planets.isEmpty) {
            return const Center(child: Text('No hay planetas disponibles'));
          }
          return ListView.builder(
            itemCount: planets.length,
            itemBuilder: (context, index) {
              final planet = planets[index];

              return ListTile(
                title: Text(planet.name),
                onTap: () => context.go('/planets/${planet.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}
