import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';

abstract interface class UsecaseWithParams<SucessType, Params> {
  Future<Either<Failure, SucessType>> createProvider(Params params);
}

abstract interface class UsecaseWithoutParams<SucessType, Params> {
  Future<Either<Failure, SucessType>> createProvider();
}
