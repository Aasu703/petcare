import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  final double totalEarnings;
  final double monthlyEarnings;
  final int completedAppointments;
  final Map<String, double> dailyEarnings; // 'yyyy-MM-dd' → amount

  const EarningsEntity({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.completedAppointments,
    required this.dailyEarnings,
  });

  @override
  List<Object?> get props => [
    totalEarnings,
    monthlyEarnings,
    completedAppointments,
    dailyEarnings,
  ];
}
