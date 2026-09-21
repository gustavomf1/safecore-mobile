// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rascunho_normas_dao.dart';

// ignore_for_file: type=lint
mixin _$RascunhoNormasDaoMixin on DatabaseAccessor<AppDatabase> {
  $RascunhosTable get rascunhos => attachedDatabase.rascunhos;
  $RascunhoNormasTable get rascunhoNormas => attachedDatabase.rascunhoNormas;
  RascunhoNormasDaoManager get managers => RascunhoNormasDaoManager(this);
}

class RascunhoNormasDaoManager {
  final _$RascunhoNormasDaoMixin _db;
  RascunhoNormasDaoManager(this._db);
  $$RascunhosTableTableManager get rascunhos =>
      $$RascunhosTableTableManager(_db.attachedDatabase, _db.rascunhos);
  $$RascunhoNormasTableTableManager get rascunhoNormas =>
      $$RascunhoNormasTableTableManager(
          _db.attachedDatabase, _db.rascunhoNormas);
}
