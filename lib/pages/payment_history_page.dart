import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<PagoSimulado>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() {
    setState(() {
      _historyFuture = _paymentService.obtenerHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFbInitialized = _paymentService.isFirebaseInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historial de Pagos',
          style: TextStyle(
            color: Color(0xFF1E1E2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E1E2C)),
            onPressed: _cargarHistorial,
            tooltip: 'Actualizar historial',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de origen de datos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: isFbInitialized
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              child: Row(
                children: [
                  Icon(
                    isFbInitialized ? Icons.cloud_done_rounded : Icons.storage_rounded,
                    size: 16,
                    color: isFbInitialized ? Colors.green[800] : Colors.orange[800],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isFbInitialized
                          ? 'Mostrando transacciones de Firebase Firestore'
                          : 'Mostrando transacciones locales (Offline Sandbox)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFbInitialized ? Colors.green[800] : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<PagoSimulado>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E6AD2)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                            const SizedBox(height: 16),
                            const Text(
                              'Error al cargar el historial',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2C)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _cargarHistorial,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final historial = snapshot.data ?? [];

                  if (historial.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _cargarHistorial(),
                      child: ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 70,
                                  color: Color(0xFFC4C8D3),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Sin Transacciones',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7E8494),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Realiza tu primera simulación de compra para registrarla aquí.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _cargarHistorial(),
                    color: const Color(0xFF5E6AD2),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final pago = historial[index];
                        return _buildHistoryCard(pago);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(PagoSimulado pago) {
    final bool esAprobado = pago.estado == 'APROBADO';
    final Color badgeBgColor = esAprobado ? const Color(0xE8E8F5E9) : const Color(0xFFFFEBEE);
    final Color badgeTxtColor = esAprobado ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    // Formatear la fecha
    final String dia = pago.fecha.day.toString().padLeft(2, '0');
    final String mes = pago.fecha.month.toString().padLeft(2, '0');
    final String anio = pago.fecha.year.toString();
    final String hora = pago.fecha.hour.toString().padLeft(2, '0');
    final String minuto = pago.fecha.minute.toString().padLeft(2, '0');
    final String fechaFormateada = '$dia/$mes/$anio $hora:$minuto';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de Producto y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pago.producto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2C),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pago.estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeTxtColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Fila de Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${pago.total.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E2C),
                  ),
                ),
                Text(
                  fechaFormateada,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.8),
            // Fila de Titular y Tarjeta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TITULAR',
                        style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pago.titular,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A5A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TARJETA',
                      style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '•••• ${pago.ultimos4}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A5A)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
