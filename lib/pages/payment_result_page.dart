import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import 'payment_history_page.dart';

class PaymentResultPage extends StatelessWidget {
  final String estado;
  final Producto producto;
  final String ultimos4;
  final String titular;

  const PaymentResultPage({
    super.key,
    required this.estado,
    required this.producto,
    required this.ultimos4,
    required this.titular,
  });

  @override
  Widget build(BuildContext context) {
    final bool esAprobado = estado == 'APROBADO';
    final PaymentService paymentService = PaymentService();
    final bool isFbInitialized = paymentService.isFirebaseInitialized;

    final primaryColor = esAprobado ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final secondaryColor = esAprobado ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final iconData = esAprobado ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Icono animado/glowing
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            iconData,
                            color: primaryColor,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Título de estado
                        Text(
                          esAprobado ? '¡Pago Aprobado!' : 'Pago Rechazado',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          esAprobado
                              ? 'La simulación de tu compra se ha procesado correctamente.'
                              : 'La simulación del pago ha fallado debido a fondos o validación simulada.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Tarjeta de detalles
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Producto:', producto.nombre),
                              const Divider(height: 20, thickness: 1),
                              _buildDetailRow('Total cobrado:', '\$${producto.precio.toStringAsFixed(2)} USD', valueColor: primaryColor, isBold: true),
                              const Divider(height: 20, thickness: 1),
                              _buildDetailRow('Titular:', titular),
                              const Divider(height: 20, thickness: 1),
                              _buildDetailRow('Tarjeta:', '•••• •••• •••• $ultimos4'),
                              const Divider(height: 20, thickness: 1),
                              _buildDetailRow('Estado de Transacción:', estado, valueColor: primaryColor, isBold: true),
                              const Divider(height: 20, thickness: 1),
                              _buildDetailRow('Sincronización:', isFbInitialized ? 'Guardado en Firebase Cloud' : 'Guardado en Local Sandbox (Offline)'),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        // Botón de Volver al Catálogo
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              // Volver a la primera pantalla (Catálogo)
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            child: const Text(
                              'Volver a la Tienda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botón de Ir al Historial
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7E8494), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              // Navegar al historial limpiando la pantalla de resultado del stack
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentHistoryPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Ver Historial de Transacciones',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E2C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E1E2C),
            ),
          ),
        ),
      ],
    );
  }
}
