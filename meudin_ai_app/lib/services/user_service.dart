import 'dart:convert';

import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  static User? currentUser;
  String apiUrl = Environment.apiUrl;
  late LocalStorageService _localStorageService;

  UserService() {
    _localStorageService = LocalStorageService();
  }

  User? getCurrentUser() {
    return currentUser;
  }

  /// Get headers with authentication token
  static Map<String, String> getAuthHeaders() {
    final headers = {
      "Accept": "application/json",
      "content-type": "application/json",
    };

    if (currentUser?.token != null && currentUser!.token!.isNotEmpty) {
      headers["Authorization"] = "Bearer ${currentUser!.token}";
    }

    return headers;
  }

  /// Refresh token - renova o token JWT e retorna dados atualizados do usuário
  Future<ResponseDto> refreshToken() async {
    Uri url = Uri.parse('${apiUrl}auth/refresh-token');

    try {
      var response = await http.post(
        url,
        headers: getAuthHeaders(),
      );

      ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

      if (responseDto.success) {
        User user = _handleUser(responseDto.data);
        currentUser = user;
        await _localStorageService.storeUserData(user);
      }

      return responseDto;
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro ao renovar token: $e',
      );
    }
  }

  /// Logout - invalida a sessão no servidor
  Future<ResponseDto> logout() async {
    Uri url = Uri.parse('${apiUrl}auth/logout');

    try {
      var response = await http.post(
        url,
        headers: getAuthHeaders(),
      );

      ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

      // Limpar dados locais independente do resultado
      currentUser = null;
      await _localStorageService.deleteUserData();

      return responseDto;
    } catch (e) {
      // Mesmo com erro, limpar dados locais
      currentUser = null;
      await _localStorageService.deleteUserData();
      
      return ResponseDto(
        success: false,
        errorMessage: 'Erro ao fazer logout: $e',
      );
    }
  }

  /// Get current user data from server
  Future<ResponseDto> getCurrentUserData() async {
    Uri url = Uri.parse('${apiUrl}auth/me');

    try {
      var response = await http.get(
        url,
        headers: getAuthHeaders(),
      );

      ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

      if (responseDto.success) {
        User user = _handleUser(responseDto.data);
        currentUser = user;
        await _localStorageService.storeUserData(user);
      }

      return responseDto;
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro ao buscar dados do usuário: $e',
      );
    }
  }

  Future<ResponseDto> signInByEmailAndPassword(
    String userMail,
    String password,
  ) async {
    Uri url = Uri.parse('${apiUrl}auth/login');

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          'email': userMail,
          'password': password,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    if (responseDto.success) {
      User user = _handleUser(responseDto.data);
      currentUser = user;
      await _localStorageService.storeUserData(user);
    }

    return responseDto;
  }

  Future<ResponseDto> createNewUser(NewUserDto newUserDto) async {
    Uri url = Uri.parse('${apiUrl}auth/register');

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          'name': newUserDto.name,
          'email': newUserDto.email,
          'password': newUserDto.password,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  User _handleUser(Map<String, dynamic> userMap) {
    User user = User();

    user.id = userMap['id'];
    user.displayName = userMap['displayName'];
    user.email = userMap['email'];
    user.token = userMap['token'] ?? '';
    user.creationDate = DateTime.parse(userMap['creationDate']);
    user.lastUpdate = userMap['lastUpdate'] != null
        ? DateTime.parse(userMap['lastUpdate'])
        : user.creationDate;
    user.currentWalletId = userMap['currentWalletId'];

    List<dynamic> walletListMap = userMap['walletList'];
    List<Wallet> walletList = [];

    for (var i = 0; i < walletListMap.length; i++) {
      Wallet wallet = handleWallet(walletListMap[i]);
      walletList.add(wallet);
    }

    user.walletList = walletList;

    return user;
  }

  Wallet handleWallet(Map<String, dynamic> walletMap) {
    Wallet wallet = Wallet();

    wallet.id = walletMap['id'];
    wallet.name = walletMap['name'];
    wallet.ownerId = walletMap['ownerId'] ?? walletMap['owner_id'];

    final lastUpdateStr = walletMap['lastUpdate'] ?? walletMap['updated_at'];
    wallet.lastUpdate = lastUpdateStr != null 
        ? DateTime.parse(lastUpdateStr)
        : DateTime.now();

    final creationDateStr = walletMap['creationDate'] ?? walletMap['created_at'];
    wallet.creationDate = creationDateStr != null
        ? DateTime.parse(creationDateStr)
        : DateTime.now();

    List<String> membersId = [];
    var membersIdMap = walletMap['membersIds'];
    
    if (membersIdMap != null && membersIdMap is List) {
      for (var element in membersIdMap) {
        String id = element.toString();
        membersId.add(id);
      }
    }

    wallet.membersIds = membersId;

    return wallet;
  }

  /// Force sign out (local only, without calling API)
  Future<void> forceSignOut() async {
    currentUser = null;
    await _localStorageService.deleteUserData();
  }
}
