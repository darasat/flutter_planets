import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../planets/data/planets_provider.dart';

class PlanetDetailPage extends ConsumerStatefulWidget {
  final String planetId;
  const PlanetDetailPage({super.key, required this.planetId});

  @override
  ConsumerState<PlanetDetailPage> createState() => _PlanetDetailPageState();
}

class _PlanetDetailPageState extends ConsumerState<PlanetDetailPage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final planetsAsync = ref.watch(planetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Planeta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/planets'), // Navega a la lista de planetas
        ),
      ),
      body: planetsAsync.when(
        data: (planets) {
          final planet = planets.firstWhere(
            (p) => p.id == widget.planetId,
            orElse: () => Planet(
              id: '',
              name: 'Planeta no encontrado',
              mass: 0,
              distance: 0,
              imageUrl: '',
            ),
          );

          if (planet.id.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(planet.name),
                  ElevatedButton(
                    onPressed: () => context.go('/planets'),
                    child: const Text('Volver a la lista'),
                  ),
                ],
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              _isFavorite = prefs.getBool('favorite_${planet.id}') ?? false;
            });
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${planet.name}',
                    style: const TextStyle(fontSize: 20)),
                Text('Masa: ${planet.mass ?? 'Desconocida'} kg'),
                Text('Distancia: ${planet.distance ?? 'Desconocida'} km'),
                if (planet.imageUrl.isNotEmpty)
                  Image.network(
                    planet.imageUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Imagen no disponible'),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                          'favorite_${planet.id}', !_isFavorite);
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error al guardar favorito: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                  child: Text(_isFavorite
                      ? 'Quitar de Favoritos'
                      : 'Marcar como Favorito'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
