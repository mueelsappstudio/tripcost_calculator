import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);
    final history = provider.history;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride History', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text("No history yet", style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final ride = history[index];
          final date = DateTime.fromMillisecondsSinceEpoch(ride.timestamp);

          return Dismissible(
            key: Key(ride.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red.shade100,
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            onDismissed: (_) {
              provider.deleteRide(ride.id);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: ExpansionTile(
                shape: const Border(),
                title: Text(ride.tripName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${provider.currencySymbol} ${ride.result.grandTotal}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                    Text("${ride.result.totalDistance} km", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _row("Fuel Cost", ride.result.totalFuelCost, provider.currencySymbol),
                        _row("Maintenance", ride.result.totalMaintenanceCost + ride.result.totalTyreDepreciation, provider.currencySymbol),
                        _row("Fixed Costs", ride.result.totalFixedCost, provider.currencySymbol),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, int amount, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text("$symbol $amount", style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}