import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/calculator_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/time_input.dart';
import '../widgets/banner_ad_area.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _tripNameCtrl = TextEditingController();
  Key _formKey = UniqueKey();

  // --- NEW FUNCTION: Show Breakdown ---
  void _showBreakdown(BuildContext context, CalculatorProvider provider) {
    final result = provider.result;
    final trip = provider.trip;

    // Calculate Time Cost manually for display since it's grouped in Fixed Cost usually
    final double timeCost = (trip.waitingTime / 60) * trip.hourlyRate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text("Detailed Cost Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const Divider(height: 30),

              _detailRow("Fuel Cost", result.totalFuelCost, provider.currencySymbol, AppColors.primary),
              _detailRow("Tyre & Oil Wear", result.totalMaintenanceCost + result.totalTyreDepreciation, provider.currencySymbol, AppColors.warning),
              const Divider(),
              _detailRow("Time Cost (${trip.waitingTime} min)", timeCost.round(), provider.currencySymbol, AppColors.textSecondary),
              _detailRow("Driver Fee", trip.driverFee.round(), provider.currencySymbol, AppColors.textSecondary),
              _detailRow("Tolls & Parking", (trip.tollTax + trip.parkingFees).round(), provider.currencySymbol, AppColors.textSecondary),
              const Divider(thickness: 1.5),
              _detailRow("GRAND TOTAL", result.grandTotal, provider.currencySymbol, AppColors.textMain, isBold: true),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, int amount, String symbol, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? AppColors.textMain : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("$symbol $amount", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);
    final result = provider.result;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TripCost', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const Text('Smart Trip Calculator', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () {
              provider.reset();
              _tripNameCtrl.clear();
              setState(() { _formKey = UniqueKey(); });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields reset"), duration: Duration(seconds: 1)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Trip Name Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: CustomInput(
                label: "Trip Name",
                placeholder: "e.g., Lahore to Islamabad",
                icon: Icons.label_outline,
                controller: _tripNameCtrl,
              ),
            ),
            const SizedBox(height: 20),

            // Result Card with Donut Chart
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ESTIMATED COST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text("${provider.currencySymbol} ${result.grandTotal}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Per KM", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text("${provider.currencySymbol} ${result.costPerKm}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),

                  // --- NEW BUTTON: View Full Details ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showBreakdown(context, provider),
                      icon: const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                      label: const Text("View Full Details", style: TextStyle(color: AppColors.info, fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              sections: [
                                PieChartSectionData(color: AppColors.primary, value: result.totalFuelCost.toDouble(), radius: 25, showTitle: false),
                                PieChartSectionData(color: AppColors.warning, value: (result.totalMaintenanceCost + result.totalTyreDepreciation).toDouble(), radius: 25, showTitle: false),
                                PieChartSectionData(color: AppColors.info, value: result.totalFixedCost.toDouble(), radius: 25, showTitle: false),
                              ].where((s) => s.value > 0).toList(),
                            )
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Distance", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text("${result.totalDistance} km", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLegendItem("Fuel Cost", result.totalFuelCost, AppColors.primary, Icons.local_gas_station, provider.currencySymbol),
                  const SizedBox(height: 12),
                  _buildLegendItem("Maintenance", (result.totalMaintenanceCost + result.totalTyreDepreciation), AppColors.warning, Icons.build_circle, provider.currencySymbol),
                  const SizedBox(height: 12),
                  _buildLegendItem("Fixed Costs", result.totalFixedCost, AppColors.info, Icons.account_balance_wallet, provider.currencySymbol),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.saveRide(_tripNameCtrl.text);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ride Saved!")));
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text("Save Calculation"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textMain,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            KeyedSubtree(
              key: _formKey,
              child: Column(
                children: [
                  _buildAccordion(
                      "Trip Details",
                      Icons.map,
                      Colors.white,
                      Column(
                        children: [
                          _buildLegSection("LEG 1: OUTBOUND"),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Dist (KM)", keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(distanceAtoB: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: TimeInput(label: "Time", totalMinutes: provider.trip.timeAtoB, onChanged: (v) => provider.updateTrip(timeAtoB: v))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLegSection("LEG 2: RETURN"),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Dist (KM)", keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(distanceBtoA: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: TimeInput(label: "Time", totalMinutes: provider.trip.timeBtoA, onChanged: (v) => provider.updateTrip(timeBtoA: v))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: TimeInput(label: "Wait Time", totalMinutes: provider.trip.waitingTime, icon: Icons.timer, onChanged: (v) => provider.updateTrip(waitingTime: v))),
                              const SizedBox(width: 12),
                              Expanded(child: CustomInput(label: "Hourly Rate", icon: Icons.attach_money, keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(hourlyRate: double.tryParse(v)))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomInput(label: "Driver Fee", keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(driverFee: double.tryParse(v))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Toll Tax", keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(tollTax: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: CustomInput(label: "Parking", keyboardType: TextInputType.number, onChanged: (v) => provider.updateTrip(parkingFees: double.tryParse(v)))),
                            ],
                          ),
                        ],
                      )
                  ),

                  const SizedBox(height: 20),

                  _buildAccordion(
                      "Vehicle Configuration",
                      Icons.settings,
                      Colors.white,
                      Column(
                        children: [
                          const Align(alignment: Alignment.centerLeft, child: Text("FUEL & EFFICIENCY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary))),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Price (Ltr)", keyboardType: TextInputType.number, initialValue: provider.vehicle.fuelPrice.toString(), onChanged: (v) => provider.updateVehicle(fuelPrice: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: CustomInput(label: "Avg (Km/L)", keyboardType: TextInputType.number, initialValue: provider.vehicle.fuelAverage.toString(), onChanged: (v) => provider.updateVehicle(fuelAverage: double.tryParse(v)))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Align(alignment: Alignment.centerLeft, child: Text("MAINTENANCE & WEAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Tyre Set Price", keyboardType: TextInputType.number, initialValue: provider.vehicle.tyrePrice.toString(), onChanged: (v) => provider.updateVehicle(tyrePrice: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: CustomInput(label: "Tyre Life (Km)", keyboardType: TextInputType.number, initialValue: provider.vehicle.tyreLife.toString(), onChanged: (v) => provider.updateVehicle(tyreLife: double.tryParse(v)))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: CustomInput(label: "Oil Cost", keyboardType: TextInputType.number, initialValue: provider.vehicle.oilChangePrice.toString(), onChanged: (v) => provider.updateVehicle(oilChangePrice: double.tryParse(v)))),
                              const SizedBox(width: 12),
                              Expanded(child: CustomInput(label: "Oil Interval", keyboardType: TextInputType.number, initialValue: provider.vehicle.oilChangeLife.toString(), onChanged: (v) => provider.updateVehicle(oilChangeLife: double.tryParse(v)))),
                            ],
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const BannerAdArea(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color, IconData icon, String symbol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain)),
            ],
          ),
          Text("$symbol $value", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildAccordion(String title, IconData icon, Color bgColor, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: title == "Trip Details",
          leading: Icon(icon, color: AppColors.textMain),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
          childrenPadding: const EdgeInsets.all(16),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildLegSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}