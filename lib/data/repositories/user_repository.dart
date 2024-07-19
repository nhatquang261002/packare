import '../models/account_model.dart';

abstract class UserRepository {
  Future<Account> updateUserProfile(Account account);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<Account> getUserProfile(String id);
}
