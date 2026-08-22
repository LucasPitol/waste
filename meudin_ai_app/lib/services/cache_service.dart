import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Entrada de cache em memória
class _CacheEntry {
  final List<Map<String, dynamic>> data;
  final int timestamp;
  final Map<String, dynamic>? metadata;
  static const Duration ttl = Duration(hours: 2);
  
  _CacheEntry(this.data, this.timestamp, [this.metadata]);
  
  bool isExpired() {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    final now = DateTime.now().toUtc();
    return now.difference(cacheTime) > ttl;
  }
}

/// Resultado de leitura do cache com metadados opcionais
class CacheEntryResult {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic>? metadata;

  CacheEntryResult({required this.data, this.metadata});
}

/// CacheService - Gerencia cache local de dados com TTL e invalidação por carteira
/// 
/// Estrutura de chaves:
/// - home_cache_wallet_<walletId>
/// - insights_cache_wallet_<walletId>
/// 
/// Cada entrada contém:
/// {
///   "data": [...],
///   "timestamp": 1234567890,
///   "metadata": { ... } // opcional
/// }
class CacheService {
  static const Duration _ttl = Duration(hours: 2);
  
  // Cache em memória para acesso instantâneo
  final Map<String, _CacheEntry> _memoryCache = {};
  
  // Secure storage configuration
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Gera chave de cache para uma tela e carteira
  String _getCacheKey(String screen, String walletId) {
    return '${screen}_cache_wallet_$walletId';
  }

  /// Salva dados no cache para uma tela e carteira específicas
  Future<void> saveCache(
    String screen,
    String walletId,
    List<Map<String, dynamic>> data, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final cacheKey = _getCacheKey(screen, walletId);
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      
      _memoryCache[cacheKey] = _CacheEntry(data, timestamp, metadata);
      
      final cacheData = {
        'data': data,
        'timestamp': timestamp,
        if (metadata != null) 'metadata': metadata,
      };
      
      final jsonString = jsonEncode(cacheData);
      await _secureStorage.write(key: cacheKey, value: jsonString);
    } catch (e) {
      // Silent error - cache é opcional
    }
  }

  /// Recupera dados do cache (compatível com telas que não usam metadata)
  Future<List<Map<String, dynamic>>?> getCache(String screen, String walletId) async {
    final entry = await getCacheEntry(screen, walletId);
    return entry?.data;
  }

  /// Recupera dados e metadata do cache, se válido
  Future<CacheEntryResult?> getCacheEntry(String screen, String walletId) async {
    try {
      final cacheKey = _getCacheKey(screen, walletId);
      
      // PRIMEIRO: Verifica cache em memória (instantâneo, sem I/O)
      final memoryEntry = _memoryCache[cacheKey];
      if (memoryEntry != null && !memoryEntry.isExpired()) {
        return CacheEntryResult(
          data: memoryEntry.data,
          metadata: memoryEntry.metadata,
        );
      }
      
      // Remove entrada expirada da memória
      if (memoryEntry != null && memoryEntry.isExpired()) {
        _memoryCache.remove(cacheKey);
      }
      
      // SEGUNDO: Se não tem em memória, lê do storage persistente
      final cachedJson = await _secureStorage.read(key: cacheKey);
      
      if (cachedJson == null || cachedJson.isEmpty) {
        return null;
      }
      
      final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final data = cacheData['data'] as List<dynamic>;
      final metadata = cacheData['metadata'] as Map<String, dynamic>?;
      
      // Verifica TTL
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      final now = DateTime.now().toUtc();
      final age = now.difference(cacheTime);
      
      if (age > _ttl) {
        // Cache expirado - remove e retorna null
        await _secureStorage.delete(key: cacheKey);
        _memoryCache.remove(cacheKey);
        return null;
      }
      
      // Cache válido - salva em memória para próximas leituras e retorna
      final dataList = data.map((e) => e as Map<String, dynamic>).toList();
      _memoryCache[cacheKey] = _CacheEntry(dataList, timestamp, metadata);
      
      return CacheEntryResult(data: dataList, metadata: metadata);
    } catch (e) {
      // Em caso de erro, remove cache corrompido
      try {
        final cacheKey = _getCacheKey(screen, walletId);
        await _secureStorage.delete(key: cacheKey);
        _memoryCache.remove(cacheKey);
      } catch (_) {
        // Silent error
      }
      return null;
    }
  }

  /// Verifica se existe cache válido (sem retornar os dados)
  Future<bool> hasValidCache(String screen, String walletId) async {
    final cache = await getCache(screen, walletId);
    return cache != null;
  }

  /// Invalida cache de uma tela específica para uma carteira
  Future<void> invalidateCache(String screen, String walletId) async {
    try {
      final cacheKey = _getCacheKey(screen, walletId);
      // Remove de ambos: memória e storage
      _memoryCache.remove(cacheKey);
      await _secureStorage.delete(key: cacheKey);
    } catch (e) {
      // Silent error
    }
  }

  /// Invalida cache de ambas as telas (home e insights) para uma carteira
  /// Útil quando uma transação é criada/editada/deletada
  Future<void> invalidateAllCachesForWallet(String walletId) async {
    try {
      await invalidateCache('home', walletId);
      await invalidateCache('insights', walletId);
    } catch (e) {
      // Silent error
    }
  }

  /// Invalida todo o cache (todas as carteiras, todas as telas)
  /// Útil para limpeza geral ou logout
  Future<void> invalidateAllCaches() async {
    try {
      // Limpa cache em memória
      _memoryCache.clear();
      // Limpa storage persistente
      await _secureStorage.deleteAll();
    } catch (e) {
      // Silent error
    }
  }

  /// Verifica se o cache está expirado (útil para debug)
  Future<bool> isCacheExpired(String screen, String walletId) async {
    try {
      final cacheKey = _getCacheKey(screen, walletId);
      final cachedJson = await _secureStorage.read(key: cacheKey);
      
      if (cachedJson == null || cachedJson.isEmpty) {
        return true; // Não existe = expirado
      }
      
      final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      final now = DateTime.now().toUtc();
      final age = now.difference(cacheTime);
      
      return age > _ttl;
    } catch (e) {
      return true; // Erro = considerar expirado
    }
  }
}

