// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferenceCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReferenceCacheTable get referenceCache => attachedDatabase.referenceCache;
  ReferenceCacheDaoManager get managers => ReferenceCacheDaoManager(this);
}

class ReferenceCacheDaoManager {
  final _$ReferenceCacheDaoMixin _db;
  ReferenceCacheDaoManager(this._db);
  $$ReferenceCacheTableTableManager get referenceCache =>
      $$ReferenceCacheTableTableManager(
          _db.attachedDatabase, _db.referenceCache);
}
