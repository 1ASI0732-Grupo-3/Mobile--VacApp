import 'dart:convert';
import 'dart:io';
import 'package:vacapp/core/constants/endpoints.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:vacapp/features/animals/data/models/animal_dto.dart';


class AnimalsService {
  // 🔼 Subir imagen a Cloudinary
  Future<String> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dgcgdxn0u';         // ⚠️ tu cloud_name
    const uploadPreset = 'vacapp_unsigned'; // ⚠️ tu upload_preset

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path,
          filename: path.basename(imageFile.path)));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);
      return data['secure_url']; // ✅ URL pública
    } else {
      throw Exception('Error al subir imagen a Cloudinary');
    }
  }

  // 🔁 Crear animal (ahora con imagen)
  Future<void> createAnimal(AnimalDto animal, File imageFile) async {
    // 1. Subir imagen a Cloudinary
    final imageUrl = await uploadImageToCloudinary(imageFile);

    // 2. Preparar request multipart/form-data
    final token = await TokenService.instance.getToken();
    final uri = Uri.parse(Endpoints.animal);

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = animal.name
      ..fields['gender'] = animal.gender
      ..fields['birthDate'] = animal.birthDate
      ..fields['breed'] = animal.breed
      ..fields['location'] = animal.location
      ..fields['bovineImg'] = imageUrl // ← esta es la URL pública
      ..fields['stableId'] = animal.stableId.toString();

    // 3. Enviar
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
  
    if (response.statusCode != HttpStatus.created) {
      throw Exception(
        responseBody.body.isNotEmpty
            ? jsonDecode(responseBody.body)['message'] ?? 'Error al crear animal'
            : 'Error al crear animal. Código: ${response.statusCode}',
      );
    }
    print('✅ Animal created');
  }



  Future<List<AnimalDto>> fetchAnimals() async {
    final headers = await TokenService.instance.getJsonAuthHeaders();

    final Uri uri = Uri.parse(Endpoints.animal);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AnimalDto.fromJson(e)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al cargar animales');
    }
  }

  Future<AnimalDto> fetchAnimalById(int id) async {
    final headers = await TokenService.instance.getJsonAuthHeaders();

    final Uri uri = Uri.parse('${Endpoints.animal}/$id');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      return AnimalDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al cargar el animal');
    }
  }


  Future<void> updateAnimal(int id, Map<String, dynamic> data) async {
    final token = await TokenService.instance.getToken();

    final uri = Uri.parse('${Endpoints.animal}/$id');
    final request = http.MultipartRequest('PUT', uri);

    // Header con autorización
    request.headers['Authorization'] = 'Bearer $token';

    // Mapear los datos según el backend
    request.fields['name'] = data['name'];
    request.fields['gender'] = data['gender'];

    if (data['birthDate'] != null) {
      request.fields['birthDate'] = data['birthDate']; // Ya debe venir como yyyy-MM-dd
    }

    if (data['breed'] != null) {
      request.fields['breed'] = data['breed'];
    }

    if (data['location'] != null) {
      request.fields['location'] = data['location'];
    }

    if (data['stableId'] != null) {
      request.fields['stableId'] = data['stableId'].toString();
    }

    // Enviar y obtener respuesta
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('✅ Animal $id updated');
      return;
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Respuesta vacía del backend con código ${response.statusCode}';
      throw Exception('Error al actualizar el animal: $message');
    }
  }


  Future<void> deleteAnimal(int id) async {
    final headers = await TokenService.instance.getJsonAuthHeaders();

    final Uri uri = Uri.parse('${Endpoints.animal}/$id');
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != HttpStatus.noContent) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al eliminar el animal');
    }
    print('✅ Animal $id deleted');
  }

  Future<List<AnimalDto>> fetchAnimalByStableId(int stableId) async {
    final headers = await TokenService.instance.getJsonAuthHeaders();

    final Uri uri = Uri.parse('${Endpoints.animal}/stable/$stableId');
    
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Stable $stableId: ${data.length} animals');
      return data.map((e) => AnimalDto.fromJson(e)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      // Si el endpoint no existe o no hay animales, retornamos lista vacía
      print('Stable $stableId: No animals found');
      return [];
    } else {
      // Como respaldo, intentamos obtener todos los animales y filtrar
      print('Fallback method for stable $stableId');
      return await _fetchAnimalsByStableIdFallback(stableId);
    }
  }

  // Método de respaldo: obtener todos los animales y filtrar por establo
  Future<List<AnimalDto>> _fetchAnimalsByStableIdFallback(int stableId) async {
    try {
      final allAnimals = await fetchAnimals();
      final filteredAnimals = allAnimals.where((animal) => animal.stableId == stableId).toList();
      print('Fallback found ${filteredAnimals.length} animals for stable $stableId');
      return filteredAnimals;
    } catch (e) {
      print('❌ Fallback failed: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }
  

}