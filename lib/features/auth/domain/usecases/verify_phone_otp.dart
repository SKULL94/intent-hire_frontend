import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtpParams extends Equatable {
  final String phone;
  final String token;
  const VerifyPhoneOtpParams({required this.phone, required this.token});

  @override
  List<Object?> get props => [phone, token];
}

class VerifyPhoneOtp implements UseCase<AuthUser, VerifyPhoneOtpParams> {
  final AuthRepository _repo;

  VerifyPhoneOtp(this._repo);

  @override
  Future<Either<Failure, AuthUser>> call(VerifyPhoneOtpParams params) =>
      _repo.verifyPhoneOtp(phone: params.phone, token: params.token);
}
