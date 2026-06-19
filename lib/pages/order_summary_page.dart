import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payment_form_page.dart';

class OrderSummaryPage extends StatelessWidget {
  final Producto producto;

  const OrderSummaryPage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    IconData getIcon(String name) {
      switch (name) {
        case 'headphones':
          return Icons.headphones_rounded;
        case 'keyboard':
          return Icons.keyboard_rounded;
        case 'mouse':
          return Icons.mouse_rounded;
        default:
          return Icons.devices_rounded;
      }
    }

    Color getThemeColor(String name) {
      switch (name) {
        case 'headphones':
          return const Color(0xFF5E6AD2);
        case 'keyboard':
          return const Color(0xFF00B0FF);
        case 'mouse':
          return const Color(0xFFFF3D00);
        default:
          return const Color(0xFF673AB7);
      }
    }

    final themeColor = getThemeColor(producto.iconName);
    const double envio = 0.00; // Envío gratuito simulado
    final double total = producto.precio + envio;

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
          'Resumen del Pedido',
          style: TextStyle(
            color: Color(0xFF1E1E2C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirma tu Total',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Por favor verifica los detalles de tu compra antes de pasar a la pantalla de pago.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Detalle Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      getIcon(producto.iconName),
                                      color: themeColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto.nombre,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E1E2C),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Dispositivo Tecnológico',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${producto.precio.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E2C),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 35, thickness: 1),
                              // Detalle de costos
                              _buildCostRow('Subtotal', '\$${producto.precio.toStringAsFixed(2)}', isBold: false),
                              const SizedBox(height: 10),
                              _buildCostRow('Envío', envio == 0 ? 'Gratis' : '\$${envio.toStringAsFixed(2)}', isBold: false, valueColor: envio == 0 ? Colors.green : null),
                              const Divider(height: 35, thickness: 1),
                              _buildCostRow('Total a Pagar', '\$${total.toStringAsFixed(2)}', isBold: true, valueColor: themeColor, fontSize: 18),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        // Botones de acción
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentFormPage(producto: producto),
                                ),
                              );
                            },
                            child: const Text(
                              'Confirmar y proceder al pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7E8494),
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

  Widget _buildCostRow(String title, String value, {required bool isBold, Color? valueColor, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF1E1E2C) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E1E2C),
          ),
        ),
      ],
    );
  }
}
