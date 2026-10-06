import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtpParams extends Equatable {
  final String phone;
  const SendPhoneOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class SendPhoneOtp implements UseCase<void, SendPhoneOtpParams> {
  final AuthRepository _repo;

  SendPhoneOtp(this._repo);

  @override
  Future<Either<Failure, void>> call(SendPhoneOtpParams params) =>
      _repo.sendPhoneOtp(phone: params.phone);
}
