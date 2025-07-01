import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:vacapp/core/constants/endpoints.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/vaccines/data/models/vaccines_dto.dart';

class VaccinesService {
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

  Future<void> createVaccine(VaccinesDto vaccine, File imageFile) async {
    print('🔍 [DEBUG] Iniciando creación de vacuna: ${vaccine.name}');
    
    // 1. Subir imagen a Cloudinary
    final imageUrl = await uploadImageToCloudinary(imageFile);
    print('✅ [DEBUG] Imagen subida a Cloudinary: $imageUrl');

    // 2. Preparar request multipart/form-data
    final token = await TokenService.instance.getToken();
    final uri = Uri.parse(Endpoints.vaccine);
    print('🔍 [DEBUG] URI para crear: $uri');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = vaccine.name
      ..fields['vaccineType'] = vaccine.vaccineType
      ..fields['vaccineDate'] = vaccine.vaccineDate
      ..fields['vaccineImg'] = imageUrl // ← esta es la URL pública
      ..fields['bovineId'] = vaccine.bovineId.toString(); // Convertir int a string

    print('🔍 [DEBUG] Campos enviados: ${request.fields}');

    // 3. Enviar
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    
    print('🔍 [DEBUG] Status Code crear: ${response.statusCode}');
    print('🔍 [DEBUG] Response Body crear: ${responseBody.body}');

    if (response.statusCode != HttpStatus.created) {
      throw Exception(
        responseBody.body.isNotEmpty
            ? jsonDecode(responseBody.body)['message'] ?? 'Error al crear vacuna'
            : 'Error al crear vacuna. Código: ${response.statusCode}',
      );
    }
    print('✅ Vacuna creada exitosamente: ${vaccine.name}');
  }

  Future<void> createVaccineWithUrl(VaccinesDto vaccine) async {
    print('🔍 [DEBUG] Iniciando creación de vacuna con URL predeterminada: ${vaccine.name}');
    
    // Preparar request con URL de imagen predeterminada
    final token = await TokenService.instance.getToken();
    final uri = Uri.parse(Endpoints.vaccine);
    print('🔍 [DEBUG] URI para crear: $uri');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = vaccine.name
      ..fields['vaccineType'] = vaccine.vaccineType
      ..fields['vaccineDate'] = vaccine.vaccineDate
      ..fields['vaccineImg'] = vaccine.vaccineImg // URL predeterminada
      ..fields['bovineId'] = vaccine.bovineId.toString();

    print('🔍 [DEBUG] Campos enviados: ${request.fields}');

    // Enviar
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    
    print('🔍 [DEBUG] Status Code crear: ${response.statusCode}');
    print('🔍 [DEBUG] Response Body crear: ${responseBody.body}');

    if (response.statusCode != HttpStatus.created) {
      throw Exception(
        responseBody.body.isNotEmpty
            ? jsonDecode(responseBody.body)['message'] ?? 'Error al crear vacuna'
            : 'Error al crear vacuna. Código: ${response.statusCode}',
      );
    }
    print('✅ Vacuna creada exitosamente con imagen predeterminada: ${vaccine.name}');
  }

  Future<List<VaccinesDto>> fetchVaccines() async{
    print('🔍 [DEBUG] Iniciando fetch de vacunas...');
    
    final headers =  await TokenService.instance.getJsonAuthHeaders();
    print('🔍 [DEBUG] Headers obtenidos: $headers');

    final Uri uri = Uri.parse(Endpoints.vaccine);
    print('🔍 [DEBUG] URI: $uri');
    
    final response = await http.get(uri, headers: headers);
    print('🔍 [DEBUG] Status Code: ${response.statusCode}');
    print('🔍 [DEBUG] Response Body: ${response.body}');

    if(response.statusCode == HttpStatus.ok){
      final List<dynamic> data = jsonDecode(response.body);
      print('✅ [DEBUG] Vacunas obtenidas exitosamente: ${data.length}');
      
      // Log de cada vacuna
      for (int i = 0; i < data.length; i++) {
        print('🔍 [DEBUG] Vacuna $i: ${data[i]['name']} - Tipo: ${data[i]['vaccineType']}');
      }
      
      return data.map((e) => VaccinesDto.fromJson(e)).toList();
    } else {
      print('❌ [DEBUG] Error al obtener vacunas: ${response.statusCode}');
      print('❌ [DEBUG] Error body: ${response.body}');
      throw Exception( jsonDecode(response.body)['message'] ?? 'Error al obtener vacunas');
    }
  }

  Future<VaccinesDto> fetchVaccineById(int id) async {
    final headers = await TokenService.instance.getJsonAuthHeaders();

    final Uri uri = Uri.parse('${Endpoints.vaccine}/$id');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == HttpStatus.ok) {
      return VaccinesDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Error al obtener vacuna',
      );
    }
  }

   Future<void> updateVaccine(int id, Map<String, dynamic> data, File? imageFile) async {
    print('🔍 [DEBUG] Iniciando actualización de vacuna ID: $id');
    
    final token = await TokenService.instance.getToken();

    final uri = Uri.parse('${Endpoints.vaccine}/$id');
    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = data['name'];
    request.fields['vaccineType'] = data['vaccineType'];
    request.fields['vaccineDate'] = data['vaccineDate'];
    if (imageFile != null) {
      final imageUrl = await uploadImageToCloudinary(imageFile);
      request.fields['vaccineImg'] = imageUrl; // URL pública de la imagen
      print('✅ [DEBUG] Nueva imagen subida: $imageUrl');
    } else {
      request.fields['vaccineImg'] = data['vaccineImg']; // Mantener la imagen actual si no se sube una nueva
      print('🔍 [DEBUG] Manteniendo imagen actual: ${data['vaccineImg']}');
    }
    request.fields['bovineId'] = data['bovineId'].toString(); // Asegurar que sea string

    print('🔍 [DEBUG] Campos para actualizar: ${request.fields}');

    // Enviar y obtener respuesta
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🔍 [DEBUG] Status Code actualizar: ${response.statusCode}');
    print('🔍 [DEBUG] Response Body actualizar: ${response.body}');

    if(response.statusCode == 200 || response.statusCode == 204) {
      print('✅ Vacuna actualizada exitosamente: ${data['name']}');
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'La actualización de la vacuna falló. Código: ${response.statusCode}';
      throw Exception('Error al actualizar vacuna: $message');
    }
   }

   Future<void> deleteVaccine(int id) async{
     print('🔍 [DEBUG] Iniciando eliminación de vacuna ID: $id');
     
     final headers = await TokenService.instance.getJsonAuthHeaders();
     print('🔍 [DEBUG] Headers para delete: $headers');

     final Uri uri = Uri.parse('${Endpoints.vaccine}/$id');
     print('🔍 [DEBUG] URI delete: $uri');
     
     final response = await http.delete(uri, headers: headers);
     print('🔍 [DEBUG] Delete Status Code: ${response.statusCode}');
     print('🔍 [DEBUG] Delete Response Body: ${response.body}');

     if (response.statusCode == HttpStatus.noContent || response.statusCode == HttpStatus.ok) {
       print('✅ Vacuna $id eliminada exitosamente');
     } else {
       print('❌ [DEBUG] Error al eliminar vacuna: ${response.statusCode}');
       throw Exception(
         response.body.isNotEmpty 
           ? (jsonDecode(response.body)['message'] ?? 'Error al eliminar vacuna')
           : 'Error al eliminar vacuna',
       );
     }
   }

   Future<List<VaccinesDto>> fetchVaccinesByBovineId(int bovineId) async {
     final headers = await TokenService.instance.getJsonAuthHeaders();

     final Uri uri = Uri.parse('${Endpoints.vaccine}/bovine/$bovineId');
     final response = await http.get(uri, headers: headers);

     if (response.statusCode == HttpStatus.ok) {
       final List<dynamic> data = jsonDecode(response.body);
       print('✅ Vacunas obtenidas para bovino $bovineId: ${data.length}');
       return data.map((e) => VaccinesDto.fromJson(e)).toList();
     } else if (response.statusCode == HttpStatus.notFound) {
        print('⚠️ No se encontraron vacunas para el bovino $bovineId');
        return [];
     } else {
      print('❌ Error al obtener vacunas para bovino $bovineId: ${response.statusCode}');
      return await _fetchVaccinesByBovineIdFallback(bovineId);
     }
   }

   Future<List<VaccinesDto>> _fetchVaccinesByBovineIdFallback(int bovineId) async {
     try{
      final allvaccines = await fetchVaccines();
      final filteredVaccines = allvaccines.where((vaccine) => vaccine.bovineId == bovineId).toList();
      print('✅ Vacunas filtradas para bovino $bovineId: ${filteredVaccines.length}');
      return filteredVaccines;
     }catch (e) {
       print('❌ Error en el fallback al obtener vacunas para bovino $bovineId: $e');
       return [];
     }
   }
}
