import 'package:get/get.dart';
import 'package:pr2/common/auth_state.dart';
import 'package:pr2/common/data_base_request.dart';
import 'package:pr2/core/db/data_base_helper.dart';
import 'package:pr2/data/model/user.dart';
import 'package:pr2/domain/entity/role_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:pr2/domain/repository/auth_repositories.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepositoriImpl implements AuthRepositories {
  final _db = DataBaseHelper.instance.dataBase;
  Rx<AuthState> authState = AuthState.bad.obs;
  String table = DataBaseRequest.tableUsers;

  

  @override
  Future<Either<String, RoleEnum>> signIn(String login, String password) async {
    try {
      var user = await _db.query(
        table,
        where: 'login = ?',
        whereArgs: [login],
      );

      if (user.isEmpty) {
        return Left('Такого пользователя нет');
      }

      if (user.first['password'] != password) {
        return Left('Пароль пользователя неверный');
      }

      return Right(RoleEnum.values[(user.first['id_role'] as int) - 1]);
    } on DatabaseException catch (error) {
      return Left(error.result.toString());
    }
  }

  @override
  Future<Either<String, bool>> signUp(String login, String password) async {
    try {
      _db.insert(
        table,
        User(login: login, password: password, idRole: RoleEnum.user).toMap(),
      );
      return Right(true);
    } on DatabaseException catch (error) {
      return Left('Ошибка');
    }
  }
}
