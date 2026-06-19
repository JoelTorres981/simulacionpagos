import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_model.dart';
import '../firebase_options.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  // Inicializar Firebase con try-catch
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseInitialized = true;
      debugPrint("Firebase inicializado con éxito.");
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint("Firebase no configurado o no pudo inicializar. Usando almacenamiento local fallback. Error: $e");
    }
  }

  // Guardar un pago (Firebase o SharedPreferences)
  Future<void> guardarPago({
    required String producto,
    required double total,
    required String titular,
    required String tarjeta,
    required String estado,
  }) async {
    final String ultimos4 = tarjeta.length >= 4 ? tarjeta.substring(tarjeta.length - 4) : tarjeta;
    final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime fechaActual = DateTime.now();

    final nuevoPago = PagoSimulado(
      id: uniqueId,
      producto: producto,
      total: total,
      titular: titular,
      ultimos4: ultimos4,
      estado: estado,
      fecha: fechaActual,
    );

    if (_isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('pagos_simulados').add({
          'producto': producto,
          'total': total,
          'titular': titular,
          'ultimos4': ultimos4,
          'estado': estado,
          'fecha': FieldValue.serverTimestamp(),
        });
        debugPrint("Pago guardado en Firebase.");
        // También guardamos localmente en SharedPreferences como respaldo
        await _guardarLocalmente(nuevoPago);
      } catch (e) {
        debugPrint("Error al guardar en Firebase, guardando en local. Error: $e");
        await _guardarLocalmente(nuevoPago);
      }
    } else {
      await _guardarLocalmente(nuevoPago);
    }
  }

  // Guardar pago en SharedPreferences
  Future<void> _guardarLocalmente(PagoSimulado pago) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historialRaw = prefs.getStringList('historial_pagos') ?? [];
      historialRaw.add(jsonEncode(pago.toMap()));
      await prefs.setStringList('historial_pagos', historialRaw);
      debugPrint("Pago guardado en SharedPreferences.");
    } catch (e) {
      debugPrint("Error al guardar en SharedPreferences: $e");
    }
  }

  // Obtener historial completo (de Firebase o SharedPreferences)
  Future<List<PagoSimulado>> obtenerHistorial() async {
    if (_isFirebaseInitialized) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('pagos_simulados')
            .orderBy('fecha', descending: true)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return PagoSimulado.fromMap(data, doc.id);
        }).toList();
      } catch (e) {
        debugPrint("Error al leer de Firebase, leyendo de local. Error: $e");
        return _obtenerHistorialLocal();
      }
    } else {
      return _obtenerHistorialLocal();
    }
  }

  // Obtener historial local de SharedPreferences
  Future<List<PagoSimulado>> _obtenerHistorialLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historialRaw = prefs.getStringList('historial_pagos') ?? [];
      final List<PagoSimulado> lista = historialRaw.map((rawItem) {
        final map = jsonDecode(rawItem) as Map<String, dynamic>;
        return PagoSimulado.fromMap(map, map['id'] ?? '');
      }).toList();
      
      // Ordenar de más reciente a más antiguo
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      return lista;
    } catch (e) {
      debugPrint("Error al obtener historial local: $e");
      return [];
    }
  }
}
