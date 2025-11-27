class VehicleSpecs {
  double fuelPrice;
  double fuelAverage;
  double tyrePrice;
  double tyreLife;
  double oilChangePrice;
  double oilChangeLife;

  VehicleSpecs({
    this.fuelPrice = 270.0,
    this.fuelAverage = 12.0,
    this.tyrePrice = 50000.0,
    this.tyreLife = 30000.0,
    this.oilChangePrice = 10000.0,
    this.oilChangeLife = 5000.0,
  });

  Map<String, dynamic> toJson() => {
    'fuelPrice': fuelPrice,
    'fuelAverage': fuelAverage,
    'tyrePrice': tyrePrice,
    'tyreLife': tyreLife,
    'oilChangePrice': oilChangePrice,
    'oilChangeLife': oilChangeLife,
  };

  factory VehicleSpecs.fromJson(Map<String, dynamic> json) => VehicleSpecs(
    fuelPrice: (json['fuelPrice'] ?? 270.0).toDouble(),
    fuelAverage: (json['fuelAverage'] ?? 12.0).toDouble(),
    tyrePrice: (json['tyrePrice'] ?? 50000.0).toDouble(),
    tyreLife: (json['tyreLife'] ?? 30000.0).toDouble(),
    oilChangePrice: (json['oilChangePrice'] ?? 10000.0).toDouble(),
    oilChangeLife: (json['oilChangeLife'] ?? 5000.0).toDouble(),
  );
}

class TripDetails {
  double distanceAtoB;
  double distanceBtoA;
  int timeAtoB; // minutes
  int timeBtoA; // minutes
  int waitingTime; // minutes
  double tollTax;
  double parkingFees;
  double driverFee;
  double hourlyRate;

  TripDetails({
    this.distanceAtoB = 0,
    this.distanceBtoA = 0,
    this.timeAtoB = 0,
    this.timeBtoA = 0,
    this.waitingTime = 0,
    this.tollTax = 0,
    this.parkingFees = 0,
    this.driverFee = 0,
    this.hourlyRate = 0,
  });

  Map<String, dynamic> toJson() => {
    'distanceAtoB': distanceAtoB,
    'distanceBtoA': distanceBtoA,
    'timeAtoB': timeAtoB,
    'timeBtoA': timeBtoA,
    'waitingTime': waitingTime,
    'tollTax': tollTax,
    'parkingFees': parkingFees,
    'driverFee': driverFee,
    'hourlyRate': hourlyRate,
  };

  factory TripDetails.fromJson(Map<String, dynamic> json) => TripDetails(
    distanceAtoB: (json['distanceAtoB'] ?? 0).toDouble(),
    distanceBtoA: (json['distanceBtoA'] ?? 0).toDouble(),
    timeAtoB: json['timeAtoB'] ?? 0,
    timeBtoA: json['timeBtoA'] ?? 0,
    waitingTime: json['waitingTime'] ?? 0,
    tollTax: (json['tollTax'] ?? 0).toDouble(),
    parkingFees: (json['parkingFees'] ?? 0).toDouble(),
    driverFee: (json['driverFee'] ?? 0).toDouble(),
    hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
  );
}

class CalculationResult {
  final int totalFuelCost;
  final int totalTyreDepreciation;
  final int totalMaintenanceCost;
  final double totalDistance;
  final int totalTimeMinutes;
  final int totalVariableCost;
  final int totalFixedCost;
  final int grandTotal;
  final int costPerKm;

  CalculationResult({
    required this.totalFuelCost,
    required this.totalTyreDepreciation,
    required this.totalMaintenanceCost,
    required this.totalDistance,
    required this.totalTimeMinutes,
    required this.totalVariableCost,
    required this.totalFixedCost,
    required this.grandTotal,
    required this.costPerKm,
  });

  factory CalculationResult.empty() {
    return CalculationResult(
      totalFuelCost: 0,
      totalTyreDepreciation: 0,
      totalMaintenanceCost: 0,
      totalDistance: 0,
      totalTimeMinutes: 0,
      totalVariableCost: 0,
      totalFixedCost: 0,
      grandTotal: 0,
      costPerKm: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalFuelCost': totalFuelCost,
    'totalTyreDepreciation': totalTyreDepreciation,
    'totalMaintenanceCost': totalMaintenanceCost,
    'totalDistance': totalDistance,
    'totalTimeMinutes': totalTimeMinutes,
    'totalVariableCost': totalVariableCost,
    'totalFixedCost': totalFixedCost,
    'grandTotal': grandTotal,
    'costPerKm': costPerKm,
  };

  factory CalculationResult.fromJson(Map<String, dynamic> json) => CalculationResult(
    totalFuelCost: json['totalFuelCost'] ?? 0,
    totalTyreDepreciation: json['totalTyreDepreciation'] ?? 0,
    totalMaintenanceCost: json['totalMaintenanceCost'] ?? 0,
    totalDistance: (json['totalDistance'] ?? 0).toDouble(),
    totalTimeMinutes: json['totalTimeMinutes'] ?? 0,
    totalVariableCost: json['totalVariableCost'] ?? 0,
    totalFixedCost: json['totalFixedCost'] ?? 0,
    grandTotal: json['grandTotal'] ?? 0,
    costPerKm: json['costPerKm'] ?? 0,
  );
}

class SavedRide {
  final String id;
  final int timestamp;
  final String tripName;
  final CalculationResult result;
  final TripDetails details;

  SavedRide({
    required this.id,
    required this.timestamp,
    required this.tripName,
    required this.result,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'tripName': tripName,
    'result': result.toJson(),
    'details': details.toJson(),
  };

  factory SavedRide.fromJson(Map<String, dynamic> json) => SavedRide(
    id: json['id'],
    timestamp: json['timestamp'],
    tripName: json['tripName'],
    result: CalculationResult.fromJson(json['result']),
    details: TripDetails.fromJson(json['details']),
  );
}