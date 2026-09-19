// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rascunho_fotos_dao.dart';

// ignore_for_file: type=lint
mixin _$RascunhoFotosDaoMixin on DatabaseAccessor<AppDatabase> {
  $RascunhosTable get rascunhos => attachedDatabase.rascunhos;
  $RascunhoFotosTable get rascunhoFotos => attachedDatabase.rascunhoFotos;
  RascunhoFotosDaoManager get managers => RascunhoFotosDaoManager(this);
}

class RascunhoFotosDaoManager {
  final _$RascunhoFotosDaoMixin _db;
  RascunhoFotosDaoManager(this._db);
  $$RascunhosTableTableManager get rascunhos =>
      $$RascunhosTableTableManager(_db.attachedDatabase, _db.rascunhos);
  $$RascunhoFotosTableTableManager get rascunhoFotos =>
      $$RascunhoFotosTableTableManager(_db.attachedDatabase, _db.rascunhoFotos);
}
