// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'account_bloc.dart';

enum AccountStatus { initial, loading, success, failed }

enum LoginStatus { login, loading, notLogin, failed }

class AccountState {
  AccountStatus status;
  Account? account;
  LoginStatus loginStatus;
  String? error;

  AccountState({
    this.status = AccountStatus.initial,
    this.loginStatus = LoginStatus.notLogin,
    this.account,
    this.error,
  });

  AccountState copyWith({
    AccountStatus? status,
    Account? account,
    LoginStatus? loginStatus,
    String? error,
  }) {
    return AccountState(
      status: status ?? this.status,
      account: account ?? this.account,
      loginStatus: loginStatus ?? this.loginStatus,
      error: error ?? this.error,
    );
  }
}
