import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import 'payment_result_page.dart';

class PaymentFormPage extends StatefulWidget {
  final Producto producto;

  const PaymentFormPage({super.key, required this.producto});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titularCtrl = TextEditingController();
  final _tarjetaCtrl = TextEditingController();
  final _expiracionCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  // Datos para actualizar el diseño de la tarjeta en tiempo real
  String _cardHolder = 'NOMBRE DEL TITULAR';
  String _cardNumber = '•••• •••• •••• ••••';
  String _expiryDate = 'MM/YY';
  String _cvv = '•••';

  @override
  void initState() {
    super.initState();
    _titularCtrl.addListener(() {
      setState(() {
        _cardHolder = _titularCtrl.text.isEmpty
            ? 'NOMBRE DEL TITULAR'
            : _titularCtrl.text.toUpperCase();
      });
    });
    _tarjetaCtrl.addListener(() {
      setState(() {
        _cardNumber = _tarjetaCtrl.text.isEmpty
            ? '•••• •••• •••• ••••'
            : _tarjetaCtrl.text;
      });
    });
    _expiracionCtrl.addListener(() {
      setState(() {
        _expiryDate = _expiracionCtrl.text.isEmpty
            ? 'MM/YY'
            : _expiracionCtrl.text;
      });
    });
    _cvvCtrl.addListener(() {
      setState(() {
        _cvv = _cvvCtrl.text.isEmpty
            ? '•••'
            : _cvvCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _titularCtrl.dispose();
    _tarjetaCtrl.dispose();
    _expiracionCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String _simularPago() {
    final aprobado = Random().nextBool();
    return aprobado ? 'APROBADO' : 'RECHAZADO';
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulamos un pequeño retraso de procesamiento para dar realismo a la transacción
    await Future.delayed(const Duration(seconds: 2));

    final estado = _simularPago();
    final tarjetaCompleta = _tarjetaCtrl.text.replaceAll(' ', '');
    final String ultimos4 = tarjetaCompleta.substring(tarjetaCompleta.length - 4);

    // Guardar el pago en base de datos (Firebase Firestore o fallback local)
    // Pasamos tarjetaCompleta pero el servicio SOLO guardará los últimos 4 dígitos
    await _paymentService.guardarPago(
      producto: widget.producto.nombre,
      total: widget.producto.precio,
      titular: _titularCtrl.text.trim(),
      tarjeta: tarjetaCompleta,
      estado: estado,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navegamos al resultado de la simulación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          estado: estado,
          producto: widget.producto,
          ultimos4: ultimos4,
          titular: _titularCtrl.text.trim(),
        ),
      ),
      (route) => route.isFirst, // Limpia el stack hasta la raíz (el catálogo)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Información de Pago',
          style: TextStyle(
            color: Color(0xFF1E1E2C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de crédito visual interactiva
                    _buildVisualCreditCard(),
                    const SizedBox(height: 30),
                    
                    // Input: Nombre del Titular
                    const Text(
                      'Nombre del Titular',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2C)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titularCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _buildInputDecoration('Ingresa el nombre tal como aparece en la tarjeta'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre del titular es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Input: Número de Tarjeta
                    const Text(
                      'Número de Tarjeta',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2C)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tarjetaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter(),
                      ],
                      decoration: _buildInputDecoration('0000 0000 0000 0000').copyWith(
                        prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF7E8494)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El número de tarjeta es obligatorio';
                        }
                        final digits = value.replaceAll(' ', '');
                        if (digits.length < 16) {
                          return 'El número de tarjeta debe tener al menos 16 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Fila con Fecha Expiración y CVV
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha de Expiración
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiración',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2C)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _expiracionCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  CardExpirationInputFormatter(),
                                ],
                                decoration: _buildInputDecoration('MM/YY'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  if (value.length < 5) {
                                    return 'Incompleto';
                                  }
                                  // Validar mes y año
                                  final partes = value.split('/');
                                  final mes = int.tryParse(partes[0]) ?? 0;
                                  final anio = int.tryParse(partes[1]) ?? 0;

                                  if (mes < 1 || mes > 12) {
                                    return 'Mes inválido';
                                  }

                                  // Validar que no esté expirada
                                  final ahora = DateTime.now();
                                  final anioActual = ahora.year % 100; // Tomar últimos 2 dígitos
                                  final mesActual = ahora.month;

                                  if (anio < anioActual || (anio == anioActual && mes < mesActual)) {
                                    return 'Tarjeta expirada';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // CVV
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVV',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2C)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cvvCtrl,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: _buildInputDecoration('123'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  if (value.length < 3) {
                                    return 'Debe ser de 3 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Botón Pagar Ahora
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E6AD2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _procesarPago,
                        child: Text(
                          'Pagar \$${widget.producto.precio.toStringAsFixed(2)} USD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pantalla de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E6AD2)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Procesando simulación...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E2C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Verificando transacciones en la red',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9EA3AE), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E6AD2), width: 2),
      ),
    );
  }

  Widget _buildVisualCreditCard() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1E2C),
            Color(0xFF3F3F5F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1E2C).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.contactless_rounded,
                color: Colors.white70,
                size: 28,
              ),
              Text(
                'PREMIUM CARD',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAR DE LA TARJETA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cardHolder,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRA',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CVV',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cvv,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Formateador para agregar espacios al número de tarjeta cada 4 dígitos (XXXX XXXX XXXX XXXX)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final int nonSpaceLength = i + 1;
      if (nonSpaceLength % 4 == 0 && nonSpaceLength != text.length) {
        buffer.write(' '); // Agregar espacio cada 4 dígitos
      }
    }

    final String string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

// Formateador para la fecha de expiración para agregar '/' (MM/YY)
class CardExpirationInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final int nonSlashLength = i + 1;
      if (nonSlashLength == 2 && nonSlashLength != text.length) {
        buffer.write('/'); // Agregar barra después de los 2 dígitos del mes
      }
    }

    final String string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
