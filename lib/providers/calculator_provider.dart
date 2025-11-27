import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class CalculatorProvider with ChangeNotifier {
  VehicleSpecs _vehicle = VehicleSpecs();
  TripDetails _trip = TripDetails();
  CalculationResult _result = CalculationResult.empty();
  List<SavedRide> _history = [];
  String _currencySymbol = "Rs";
  bool _notificationsEnabled = true;

  VehicleSpecs get vehicle => _vehicle;
  TripDetails get trip => _trip;
  CalculationResult get result => _result;
  List<SavedRide> get history => _history;
  String get currencySymbol => _currencySymbol;
  bool get notificationsEnabled => _notificationsEnabled;

  CalculatorProvider() {
    _loadAllData();
    calculateFare();
  }

  void updateVehicle({
    double? fuelPrice,
    double? fuelAverage,
    double? tyrePrice,
    double? tyreLife,
    double? oilChangePrice,
    double? oilChangeLife,
  }) {
    if (fuelPrice != null) _vehicle.fuelPrice = fuelPrice;
    if (fuelAverage != null) _vehicle.fuelAverage = fuelAverage;
    if (tyrePrice != null) _vehicle.tyrePrice = tyrePrice;
    if (tyreLife != null) _vehicle.tyreLife = tyreLife;
    if (oilChangePrice != null) _vehicle.oilChangePrice = oilChangePrice;
    if (oilChangeLife != null) _vehicle.oilChangeLife = oilChangeLife;

    calculateFare();
    notifyListeners();
  }

  void updateTrip({
    double? distanceAtoB,
    double? distanceBtoA,
    int? timeAtoB,
    int? timeBtoA,
    int? waitingTime,
    double? tollTax,
    double? parkingFees,
    double? driverFee,
    double? hourlyRate,
  }) {
    if (distanceAtoB != null) _trip.distanceAtoB = distanceAtoB;
    if (distanceBtoA != null) _trip.distanceBtoA = distanceBtoA;
    if (timeAtoB != null) _trip.timeAtoB = timeAtoB;
    if (timeBtoA != null) _trip.timeBtoA = timeBtoA;
    if (waitingTime != null) _trip.waitingTime = waitingTime;
    if (tollTax != null) _trip.tollTax = tollTax;
    if (parkingFees != null) _trip.parkingFees = parkingFees;
    if (driverFee != null) _trip.driverFee = driverFee;
    if (hourlyRate != null) _trip.hourlyRate = hourlyRate;

    calculateFare();
    notifyListeners();
  }

  void calculateFare() {
    final totalDistance = _trip.distanceAtoB + _trip.distanceBtoA;
    final totalTime = _trip.timeAtoB + _trip.timeBtoA + _trip.waitingTime;

    // 1. Fuel Cost
    final fuelCost = _vehicle.fuelAverage > 0
        ? (totalDistance / _vehicle.fuelAverage) * _vehicle.fuelPrice
        : 0.0;

    // 2. Tyre Depreciation
    final tyreDep = _vehicle.tyreLife > 0
        ? (totalDistance / _vehicle.tyreLife) * _vehicle.tyrePrice
        : 0.0;

    // 3. Maintenance
    final oilCost = _vehicle.oilChangeLife > 0
        ? (totalDistance / _vehicle.oilChangeLife) * _vehicle.oilChangePrice
        : 0.0;
    final totalMaintenance = oilCost;

    final totalVariable = fuelCost + tyreDep + totalMaintenance;

    // 4. Fixed Costs
    final timeCost = (_trip.waitingTime / 60) * _trip.hourlyRate;
    final totalFixed = _trip.tollTax + _trip.parkingFees + _trip.driverFee + timeCost;

    final grandTotal = totalVariable + totalFixed;

    _result = CalculationResult(
      totalFuelCost: fuelCost.round(),
      totalTyreDepreciation: tyreDep.round(),
      totalMaintenanceCost: totalMaintenance.round(),
      totalDistance: double.parse(totalDistance.toStringAsFixed(1)),
      totalTimeMinutes: totalTime,
      totalVariableCost: totalVariable.round(),
      totalFixedCost: totalFixed.round(),
      grandTotal: grandTotal.round(),
      costPerKm: totalDistance > 0 ? (grandTotal / totalDistance).round() : 0,
    );
  }

  void reset() {
    _trip = TripDetails();
    calculateFare();
    notifyListeners();
  }

  // --- SETTINGS LOGIC ---

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_currency', symbol);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_notifications', value);
  }

  // --- HISTORY LOGIC ---

  Future<void> saveRide(String name) async {
    final ride = SavedRide(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      tripName: name.isEmpty ? "Trip ${DateTime.now().toString()}" : name,
      result: _result,
      details: TripDetails(
          distanceAtoB: _trip.distanceAtoB,
          distanceBtoA: _trip.distanceBtoA,
          driverFee: _trip.driverFee,
          tollTax: _trip.tollTax,
          parkingFees: _trip.parkingFees,
          timeAtoB: _trip.timeAtoB,
          timeBtoA: _trip.timeBtoA,
          waitingTime: _trip.waitingTime
      ),
    );

    _history.insert(0, ride);
    notifyListeners();
    _persistHistory();
  }

  Future<void> deleteRide(String id) async {
    _history.removeWhere((element) => element.id == id);
    notifyListeners();
    _persistHistory();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load History
    final String? storedHistory = prefs.getString('tripcost_history');
    if (storedHistory != null) {
      final List<dynamic> decoded = jsonDecode(storedHistory);
      _history = decoded.map((item) => SavedRide.fromJson(item)).toList();
    }

    // Load Settings
    _currencySymbol = prefs.getString('app_currency') ?? "Rs";
    _notificationsEnabled = prefs.getBool('app_notifications') ?? true;

    notifyListeners();
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString('tripcost_history', encoded);
  }
}