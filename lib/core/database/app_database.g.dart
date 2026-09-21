// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RascunhosTable extends Rascunhos
    with TableInfo<$RascunhosTable, Rascunho> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RascunhosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _severidadeMeta =
      const VerificationMeta('severidade');
  @override
  late final GeneratedColumn<int> severidade = GeneratedColumn<int>(
      'severidade', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
      'captured_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cidadeMeta = const VerificationMeta('cidade');
  @override
  late final GeneratedColumn<String> cidade = GeneratedColumn<String>(
      'cidade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dadosJsonMeta =
      const VerificationMeta('dadosJson');
  @override
  late final GeneratedColumn<String> dadosJson = GeneratedColumn<String>(
      'dados_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _criadoEmMeta =
      const VerificationMeta('criadoEm');
  @override
  late final GeneratedColumn<int> criadoEm = GeneratedColumn<int>(
      'criado_em', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendente'));
  static const VerificationMeta _erroMensagemMeta =
      const VerificationMeta('erroMensagem');
  @override
  late final GeneratedColumn<String> erroMensagem = GeneratedColumn<String>(
      'erro_mensagem', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        usuarioId,
        tipo,
        titulo,
        descricao,
        severidade,
        latitude,
        longitude,
        capturedAt,
        cidade,
        dadosJson,
        criadoEm,
        status,
        erroMensagem,
        serverId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rascunhos';
  @override
  VerificationContext validateIntegrity(Insertable<Rascunho> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    }
    if (data.containsKey('severidade')) {
      context.handle(
          _severidadeMeta,
          severidade.isAcceptableOrUnknown(
              data['severidade']!, _severidadeMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    if (data.containsKey('cidade')) {
      context.handle(_cidadeMeta,
          cidade.isAcceptableOrUnknown(data['cidade']!, _cidadeMeta));
    }
    if (data.containsKey('dados_json')) {
      context.handle(_dadosJsonMeta,
          dadosJson.isAcceptableOrUnknown(data['dados_json']!, _dadosJsonMeta));
    }
    if (data.containsKey('criado_em')) {
      context.handle(_criadoEmMeta,
          criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta));
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('erro_mensagem')) {
      context.handle(
          _erroMensagemMeta,
          erroMensagem.isAcceptableOrUnknown(
              data['erro_mensagem']!, _erroMensagemMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rascunho map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rascunho(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usuario_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao']),
      severidade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}severidade']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}captured_at']),
      cidade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cidade']),
      dadosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dados_json']),
      criadoEm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}criado_em'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      erroMensagem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}erro_mensagem']),
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
    );
  }

  @override
  $RascunhosTable createAlias(String alias) {
    return $RascunhosTable(attachedDatabase, alias);
  }
}

class Rascunho extends DataClass implements Insertable<Rascunho> {
  final String id;
  final String usuarioId;
  final String tipo;
  final String titulo;
  final String? descricao;
  final int? severidade;
  final double? latitude;
  final double? longitude;
  final int? capturedAt;
  final String? cidade;
  final String? dadosJson;
  final int criadoEm;
  final String status;
  final String? erroMensagem;
  final String? serverId;
  const Rascunho(
      {required this.id,
      required this.usuarioId,
      required this.tipo,
      required this.titulo,
      this.descricao,
      this.severidade,
      this.latitude,
      this.longitude,
      this.capturedAt,
      this.cidade,
      this.dadosJson,
      required this.criadoEm,
      required this.status,
      this.erroMensagem,
      this.serverId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['tipo'] = Variable<String>(tipo);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || descricao != null) {
      map['descricao'] = Variable<String>(descricao);
    }
    if (!nullToAbsent || severidade != null) {
      map['severidade'] = Variable<int>(severidade);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<int>(capturedAt);
    }
    if (!nullToAbsent || cidade != null) {
      map['cidade'] = Variable<String>(cidade);
    }
    if (!nullToAbsent || dadosJson != null) {
      map['dados_json'] = Variable<String>(dadosJson);
    }
    map['criado_em'] = Variable<int>(criadoEm);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || erroMensagem != null) {
      map['erro_mensagem'] = Variable<String>(erroMensagem);
    }
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    return map;
  }

  RascunhosCompanion toCompanion(bool nullToAbsent) {
    return RascunhosCompanion(
      id: Value(id),
      usuarioId: Value(usuarioId),
      tipo: Value(tipo),
      titulo: Value(titulo),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
      severidade: severidade == null && nullToAbsent
          ? const Value.absent()
          : Value(severidade),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      cidade:
          cidade == null && nullToAbsent ? const Value.absent() : Value(cidade),
      dadosJson: dadosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dadosJson),
      criadoEm: Value(criadoEm),
      status: Value(status),
      erroMensagem: erroMensagem == null && nullToAbsent
          ? const Value.absent()
          : Value(erroMensagem),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory Rascunho.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rascunho(
      id: serializer.fromJson<String>(json['id']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      titulo: serializer.fromJson<String>(json['titulo']),
      descricao: serializer.fromJson<String?>(json['descricao']),
      severidade: serializer.fromJson<int?>(json['severidade']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      capturedAt: serializer.fromJson<int?>(json['capturedAt']),
      cidade: serializer.fromJson<String?>(json['cidade']),
      dadosJson: serializer.fromJson<String?>(json['dadosJson']),
      criadoEm: serializer.fromJson<int>(json['criadoEm']),
      status: serializer.fromJson<String>(json['status']),
      erroMensagem: serializer.fromJson<String?>(json['erroMensagem']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'tipo': serializer.toJson<String>(tipo),
      'titulo': serializer.toJson<String>(titulo),
      'descricao': serializer.toJson<String?>(descricao),
      'severidade': serializer.toJson<int?>(severidade),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'capturedAt': serializer.toJson<int?>(capturedAt),
      'cidade': serializer.toJson<String?>(cidade),
      'dadosJson': serializer.toJson<String?>(dadosJson),
      'criadoEm': serializer.toJson<int>(criadoEm),
      'status': serializer.toJson<String>(status),
      'erroMensagem': serializer.toJson<String?>(erroMensagem),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  Rascunho copyWith(
          {String? id,
          String? usuarioId,
          String? tipo,
          String? titulo,
          Value<String?> descricao = const Value.absent(),
          Value<int?> severidade = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<int?> capturedAt = const Value.absent(),
          Value<String?> cidade = const Value.absent(),
          Value<String?> dadosJson = const Value.absent(),
          int? criadoEm,
          String? status,
          Value<String?> erroMensagem = const Value.absent(),
          Value<String?> serverId = const Value.absent()}) =>
      Rascunho(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        tipo: tipo ?? this.tipo,
        titulo: titulo ?? this.titulo,
        descricao: descricao.present ? descricao.value : this.descricao,
        severidade: severidade.present ? severidade.value : this.severidade,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
        cidade: cidade.present ? cidade.value : this.cidade,
        dadosJson: dadosJson.present ? dadosJson.value : this.dadosJson,
        criadoEm: criadoEm ?? this.criadoEm,
        status: status ?? this.status,
        erroMensagem:
            erroMensagem.present ? erroMensagem.value : this.erroMensagem,
        serverId: serverId.present ? serverId.value : this.serverId,
      );
  Rascunho copyWithCompanion(RascunhosCompanion data) {
    return Rascunho(
      id: data.id.present ? data.id.value : this.id,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      severidade:
          data.severidade.present ? data.severidade.value : this.severidade,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      cidade: data.cidade.present ? data.cidade.value : this.cidade,
      dadosJson: data.dadosJson.present ? data.dadosJson.value : this.dadosJson,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      status: data.status.present ? data.status.value : this.status,
      erroMensagem: data.erroMensagem.present
          ? data.erroMensagem.value
          : this.erroMensagem,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rascunho(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('descricao: $descricao, ')
          ..write('severidade: $severidade, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('cidade: $cidade, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('status: $status, ')
          ..write('erroMensagem: $erroMensagem, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      usuarioId,
      tipo,
      titulo,
      descricao,
      severidade,
      latitude,
      longitude,
      capturedAt,
      cidade,
      dadosJson,
      criadoEm,
      status,
      erroMensagem,
      serverId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rascunho &&
          other.id == this.id &&
          other.usuarioId == this.usuarioId &&
          other.tipo == this.tipo &&
          other.titulo == this.titulo &&
          other.descricao == this.descricao &&
          other.severidade == this.severidade &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.capturedAt == this.capturedAt &&
          other.cidade == this.cidade &&
          other.dadosJson == this.dadosJson &&
          other.criadoEm == this.criadoEm &&
          other.status == this.status &&
          other.erroMensagem == this.erroMensagem &&
          other.serverId == this.serverId);
}

class RascunhosCompanion extends UpdateCompanion<Rascunho> {
  final Value<String> id;
  final Value<String> usuarioId;
  final Value<String> tipo;
  final Value<String> titulo;
  final Value<String?> descricao;
  final Value<int?> severidade;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int?> capturedAt;
  final Value<String?> cidade;
  final Value<String?> dadosJson;
  final Value<int> criadoEm;
  final Value<String> status;
  final Value<String?> erroMensagem;
  final Value<String?> serverId;
  final Value<int> rowid;
  const RascunhosCompanion({
    this.id = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.severidade = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.cidade = const Value.absent(),
    this.dadosJson = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.status = const Value.absent(),
    this.erroMensagem = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RascunhosCompanion.insert({
    required String id,
    required String usuarioId,
    required String tipo,
    required String titulo,
    this.descricao = const Value.absent(),
    this.severidade = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.cidade = const Value.absent(),
    this.dadosJson = const Value.absent(),
    required int criadoEm,
    this.status = const Value.absent(),
    this.erroMensagem = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        usuarioId = Value(usuarioId),
        tipo = Value(tipo),
        titulo = Value(titulo),
        criadoEm = Value(criadoEm);
  static Insertable<Rascunho> custom({
    Expression<String>? id,
    Expression<String>? usuarioId,
    Expression<String>? tipo,
    Expression<String>? titulo,
    Expression<String>? descricao,
    Expression<int>? severidade,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? capturedAt,
    Expression<String>? cidade,
    Expression<String>? dadosJson,
    Expression<int>? criadoEm,
    Expression<String>? status,
    Expression<String>? erroMensagem,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (tipo != null) 'tipo': tipo,
      if (titulo != null) 'titulo': titulo,
      if (descricao != null) 'descricao': descricao,
      if (severidade != null) 'severidade': severidade,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (cidade != null) 'cidade': cidade,
      if (dadosJson != null) 'dados_json': dadosJson,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (status != null) 'status': status,
      if (erroMensagem != null) 'erro_mensagem': erroMensagem,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RascunhosCompanion copyWith(
      {Value<String>? id,
      Value<String>? usuarioId,
      Value<String>? tipo,
      Value<String>? titulo,
      Value<String?>? descricao,
      Value<int?>? severidade,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int?>? capturedAt,
      Value<String?>? cidade,
      Value<String?>? dadosJson,
      Value<int>? criadoEm,
      Value<String>? status,
      Value<String?>? erroMensagem,
      Value<String?>? serverId,
      Value<int>? rowid}) {
    return RascunhosCompanion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      severidade: severidade ?? this.severidade,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      cidade: cidade ?? this.cidade,
      dadosJson: dadosJson ?? this.dadosJson,
      criadoEm: criadoEm ?? this.criadoEm,
      status: status ?? this.status,
      erroMensagem: erroMensagem ?? this.erroMensagem,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (severidade.present) {
      map['severidade'] = Variable<int>(severidade.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (cidade.present) {
      map['cidade'] = Variable<String>(cidade.value);
    }
    if (dadosJson.present) {
      map['dados_json'] = Variable<String>(dadosJson.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<int>(criadoEm.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (erroMensagem.present) {
      map['erro_mensagem'] = Variable<String>(erroMensagem.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RascunhosCompanion(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('descricao: $descricao, ')
          ..write('severidade: $severidade, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('cidade: $cidade, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('status: $status, ')
          ..write('erroMensagem: $erroMensagem, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RascunhoNormasTable extends RascunhoNormas
    with TableInfo<$RascunhoNormasTable, RascunhoNorma> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RascunhoNormasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rascunhoIdMeta =
      const VerificationMeta('rascunhoId');
  @override
  late final GeneratedColumn<String> rascunhoId = GeneratedColumn<String>(
      'rascunho_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES rascunhos (id)'));
  static const VerificationMeta _normaIdMeta =
      const VerificationMeta('normaId');
  @override
  late final GeneratedColumn<String> normaId = GeneratedColumn<String>(
      'norma_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clausulaReferenciaMeta =
      const VerificationMeta('clausulaReferencia');
  @override
  late final GeneratedColumn<String> clausulaReferencia =
      GeneratedColumn<String>('clausula_referencia', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _textoEditadoMeta =
      const VerificationMeta('textoEditado');
  @override
  late final GeneratedColumn<String> textoEditado = GeneratedColumn<String>(
      'texto_editado', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendente'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, rascunhoId, normaId, clausulaReferencia, textoEditado, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rascunho_normas';
  @override
  VerificationContext validateIntegrity(Insertable<RascunhoNorma> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rascunho_id')) {
      context.handle(
          _rascunhoIdMeta,
          rascunhoId.isAcceptableOrUnknown(
              data['rascunho_id']!, _rascunhoIdMeta));
    } else if (isInserting) {
      context.missing(_rascunhoIdMeta);
    }
    if (data.containsKey('norma_id')) {
      context.handle(_normaIdMeta,
          normaId.isAcceptableOrUnknown(data['norma_id']!, _normaIdMeta));
    } else if (isInserting) {
      context.missing(_normaIdMeta);
    }
    if (data.containsKey('clausula_referencia')) {
      context.handle(
          _clausulaReferenciaMeta,
          clausulaReferencia.isAcceptableOrUnknown(
              data['clausula_referencia']!, _clausulaReferenciaMeta));
    }
    if (data.containsKey('texto_editado')) {
      context.handle(
          _textoEditadoMeta,
          textoEditado.isAcceptableOrUnknown(
              data['texto_editado']!, _textoEditadoMeta));
    } else if (isInserting) {
      context.missing(_textoEditadoMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RascunhoNorma map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RascunhoNorma(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rascunhoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rascunho_id'])!,
      normaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}norma_id'])!,
      clausulaReferencia: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}clausula_referencia']),
      textoEditado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}texto_editado'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $RascunhoNormasTable createAlias(String alias) {
    return $RascunhoNormasTable(attachedDatabase, alias);
  }
}

class RascunhoNorma extends DataClass implements Insertable<RascunhoNorma> {
  final int id;
  final String rascunhoId;
  final String normaId;
  final String? clausulaReferencia;
  final String textoEditado;
  final String status;
  const RascunhoNorma(
      {required this.id,
      required this.rascunhoId,
      required this.normaId,
      this.clausulaReferencia,
      required this.textoEditado,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rascunho_id'] = Variable<String>(rascunhoId);
    map['norma_id'] = Variable<String>(normaId);
    if (!nullToAbsent || clausulaReferencia != null) {
      map['clausula_referencia'] = Variable<String>(clausulaReferencia);
    }
    map['texto_editado'] = Variable<String>(textoEditado);
    map['status'] = Variable<String>(status);
    return map;
  }

  RascunhoNormasCompanion toCompanion(bool nullToAbsent) {
    return RascunhoNormasCompanion(
      id: Value(id),
      rascunhoId: Value(rascunhoId),
      normaId: Value(normaId),
      clausulaReferencia: clausulaReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(clausulaReferencia),
      textoEditado: Value(textoEditado),
      status: Value(status),
    );
  }

  factory RascunhoNorma.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RascunhoNorma(
      id: serializer.fromJson<int>(json['id']),
      rascunhoId: serializer.fromJson<String>(json['rascunhoId']),
      normaId: serializer.fromJson<String>(json['normaId']),
      clausulaReferencia:
          serializer.fromJson<String?>(json['clausulaReferencia']),
      textoEditado: serializer.fromJson<String>(json['textoEditado']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rascunhoId': serializer.toJson<String>(rascunhoId),
      'normaId': serializer.toJson<String>(normaId),
      'clausulaReferencia': serializer.toJson<String?>(clausulaReferencia),
      'textoEditado': serializer.toJson<String>(textoEditado),
      'status': serializer.toJson<String>(status),
    };
  }

  RascunhoNorma copyWith(
          {int? id,
          String? rascunhoId,
          String? normaId,
          Value<String?> clausulaReferencia = const Value.absent(),
          String? textoEditado,
          String? status}) =>
      RascunhoNorma(
        id: id ?? this.id,
        rascunhoId: rascunhoId ?? this.rascunhoId,
        normaId: normaId ?? this.normaId,
        clausulaReferencia: clausulaReferencia.present
            ? clausulaReferencia.value
            : this.clausulaReferencia,
        textoEditado: textoEditado ?? this.textoEditado,
        status: status ?? this.status,
      );
  RascunhoNorma copyWithCompanion(RascunhoNormasCompanion data) {
    return RascunhoNorma(
      id: data.id.present ? data.id.value : this.id,
      rascunhoId:
          data.rascunhoId.present ? data.rascunhoId.value : this.rascunhoId,
      normaId: data.normaId.present ? data.normaId.value : this.normaId,
      clausulaReferencia: data.clausulaReferencia.present
          ? data.clausulaReferencia.value
          : this.clausulaReferencia,
      textoEditado: data.textoEditado.present
          ? data.textoEditado.value
          : this.textoEditado,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RascunhoNorma(')
          ..write('id: $id, ')
          ..write('rascunhoId: $rascunhoId, ')
          ..write('normaId: $normaId, ')
          ..write('clausulaReferencia: $clausulaReferencia, ')
          ..write('textoEditado: $textoEditado, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rascunhoId, normaId, clausulaReferencia, textoEditado, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RascunhoNorma &&
          other.id == this.id &&
          other.rascunhoId == this.rascunhoId &&
          other.normaId == this.normaId &&
          other.clausulaReferencia == this.clausulaReferencia &&
          other.textoEditado == this.textoEditado &&
          other.status == this.status);
}

class RascunhoNormasCompanion extends UpdateCompanion<RascunhoNorma> {
  final Value<int> id;
  final Value<String> rascunhoId;
  final Value<String> normaId;
  final Value<String?> clausulaReferencia;
  final Value<String> textoEditado;
  final Value<String> status;
  const RascunhoNormasCompanion({
    this.id = const Value.absent(),
    this.rascunhoId = const Value.absent(),
    this.normaId = const Value.absent(),
    this.clausulaReferencia = const Value.absent(),
    this.textoEditado = const Value.absent(),
    this.status = const Value.absent(),
  });
  RascunhoNormasCompanion.insert({
    this.id = const Value.absent(),
    required String rascunhoId,
    required String normaId,
    this.clausulaReferencia = const Value.absent(),
    required String textoEditado,
    this.status = const Value.absent(),
  })  : rascunhoId = Value(rascunhoId),
        normaId = Value(normaId),
        textoEditado = Value(textoEditado);
  static Insertable<RascunhoNorma> custom({
    Expression<int>? id,
    Expression<String>? rascunhoId,
    Expression<String>? normaId,
    Expression<String>? clausulaReferencia,
    Expression<String>? textoEditado,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rascunhoId != null) 'rascunho_id': rascunhoId,
      if (normaId != null) 'norma_id': normaId,
      if (clausulaReferencia != null) 'clausula_referencia': clausulaReferencia,
      if (textoEditado != null) 'texto_editado': textoEditado,
      if (status != null) 'status': status,
    });
  }

  RascunhoNormasCompanion copyWith(
      {Value<int>? id,
      Value<String>? rascunhoId,
      Value<String>? normaId,
      Value<String?>? clausulaReferencia,
      Value<String>? textoEditado,
      Value<String>? status}) {
    return RascunhoNormasCompanion(
      id: id ?? this.id,
      rascunhoId: rascunhoId ?? this.rascunhoId,
      normaId: normaId ?? this.normaId,
      clausulaReferencia: clausulaReferencia ?? this.clausulaReferencia,
      textoEditado: textoEditado ?? this.textoEditado,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rascunhoId.present) {
      map['rascunho_id'] = Variable<String>(rascunhoId.value);
    }
    if (normaId.present) {
      map['norma_id'] = Variable<String>(normaId.value);
    }
    if (clausulaReferencia.present) {
      map['clausula_referencia'] = Variable<String>(clausulaReferencia.value);
    }
    if (textoEditado.present) {
      map['texto_editado'] = Variable<String>(textoEditado.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RascunhoNormasCompanion(')
          ..write('id: $id, ')
          ..write('rascunhoId: $rascunhoId, ')
          ..write('normaId: $normaId, ')
          ..write('clausulaReferencia: $clausulaReferencia, ')
          ..write('textoEditado: $textoEditado, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RascunhoFotosTable extends RascunhoFotos
    with TableInfo<$RascunhoFotosTable, RascunhoFoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RascunhoFotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rascunhoIdMeta =
      const VerificationMeta('rascunhoId');
  @override
  late final GeneratedColumn<String> rascunhoId = GeneratedColumn<String>(
      'rascunho_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES rascunhos (id)'));
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
      'ordem', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendente'));
  static const VerificationMeta _evidenciaServerIdMeta =
      const VerificationMeta('evidenciaServerId');
  @override
  late final GeneratedColumn<String> evidenciaServerId =
      GeneratedColumn<String>('evidencia_server_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _erroMensagemMeta =
      const VerificationMeta('erroMensagem');
  @override
  late final GeneratedColumn<String> erroMensagem = GeneratedColumn<String>(
      'erro_mensagem', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rascunhoId, path, ordem, status, evidenciaServerId, erroMensagem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rascunho_fotos';
  @override
  VerificationContext validateIntegrity(Insertable<RascunhoFoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rascunho_id')) {
      context.handle(
          _rascunhoIdMeta,
          rascunhoId.isAcceptableOrUnknown(
              data['rascunho_id']!, _rascunhoIdMeta));
    } else if (isInserting) {
      context.missing(_rascunhoIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
          _ordemMeta, ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta));
    } else if (isInserting) {
      context.missing(_ordemMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('evidencia_server_id')) {
      context.handle(
          _evidenciaServerIdMeta,
          evidenciaServerId.isAcceptableOrUnknown(
              data['evidencia_server_id']!, _evidenciaServerIdMeta));
    }
    if (data.containsKey('erro_mensagem')) {
      context.handle(
          _erroMensagemMeta,
          erroMensagem.isAcceptableOrUnknown(
              data['erro_mensagem']!, _erroMensagemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RascunhoFoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RascunhoFoto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rascunhoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rascunho_id'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      ordem: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ordem'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      evidenciaServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}evidencia_server_id']),
      erroMensagem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}erro_mensagem']),
    );
  }

  @override
  $RascunhoFotosTable createAlias(String alias) {
    return $RascunhoFotosTable(attachedDatabase, alias);
  }
}

class RascunhoFoto extends DataClass implements Insertable<RascunhoFoto> {
  final int id;
  final String rascunhoId;
  final String path;
  final int ordem;
  final String status;
  final String? evidenciaServerId;
  final String? erroMensagem;
  const RascunhoFoto(
      {required this.id,
      required this.rascunhoId,
      required this.path,
      required this.ordem,
      required this.status,
      this.evidenciaServerId,
      this.erroMensagem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rascunho_id'] = Variable<String>(rascunhoId);
    map['path'] = Variable<String>(path);
    map['ordem'] = Variable<int>(ordem);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || evidenciaServerId != null) {
      map['evidencia_server_id'] = Variable<String>(evidenciaServerId);
    }
    if (!nullToAbsent || erroMensagem != null) {
      map['erro_mensagem'] = Variable<String>(erroMensagem);
    }
    return map;
  }

  RascunhoFotosCompanion toCompanion(bool nullToAbsent) {
    return RascunhoFotosCompanion(
      id: Value(id),
      rascunhoId: Value(rascunhoId),
      path: Value(path),
      ordem: Value(ordem),
      status: Value(status),
      evidenciaServerId: evidenciaServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenciaServerId),
      erroMensagem: erroMensagem == null && nullToAbsent
          ? const Value.absent()
          : Value(erroMensagem),
    );
  }

  factory RascunhoFoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RascunhoFoto(
      id: serializer.fromJson<int>(json['id']),
      rascunhoId: serializer.fromJson<String>(json['rascunhoId']),
      path: serializer.fromJson<String>(json['path']),
      ordem: serializer.fromJson<int>(json['ordem']),
      status: serializer.fromJson<String>(json['status']),
      evidenciaServerId:
          serializer.fromJson<String?>(json['evidenciaServerId']),
      erroMensagem: serializer.fromJson<String?>(json['erroMensagem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rascunhoId': serializer.toJson<String>(rascunhoId),
      'path': serializer.toJson<String>(path),
      'ordem': serializer.toJson<int>(ordem),
      'status': serializer.toJson<String>(status),
      'evidenciaServerId': serializer.toJson<String?>(evidenciaServerId),
      'erroMensagem': serializer.toJson<String?>(erroMensagem),
    };
  }

  RascunhoFoto copyWith(
          {int? id,
          String? rascunhoId,
          String? path,
          int? ordem,
          String? status,
          Value<String?> evidenciaServerId = const Value.absent(),
          Value<String?> erroMensagem = const Value.absent()}) =>
      RascunhoFoto(
        id: id ?? this.id,
        rascunhoId: rascunhoId ?? this.rascunhoId,
        path: path ?? this.path,
        ordem: ordem ?? this.ordem,
        status: status ?? this.status,
        evidenciaServerId: evidenciaServerId.present
            ? evidenciaServerId.value
            : this.evidenciaServerId,
        erroMensagem:
            erroMensagem.present ? erroMensagem.value : this.erroMensagem,
      );
  RascunhoFoto copyWithCompanion(RascunhoFotosCompanion data) {
    return RascunhoFoto(
      id: data.id.present ? data.id.value : this.id,
      rascunhoId:
          data.rascunhoId.present ? data.rascunhoId.value : this.rascunhoId,
      path: data.path.present ? data.path.value : this.path,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      status: data.status.present ? data.status.value : this.status,
      evidenciaServerId: data.evidenciaServerId.present
          ? data.evidenciaServerId.value
          : this.evidenciaServerId,
      erroMensagem: data.erroMensagem.present
          ? data.erroMensagem.value
          : this.erroMensagem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RascunhoFoto(')
          ..write('id: $id, ')
          ..write('rascunhoId: $rascunhoId, ')
          ..write('path: $path, ')
          ..write('ordem: $ordem, ')
          ..write('status: $status, ')
          ..write('evidenciaServerId: $evidenciaServerId, ')
          ..write('erroMensagem: $erroMensagem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rascunhoId, path, ordem, status, evidenciaServerId, erroMensagem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RascunhoFoto &&
          other.id == this.id &&
          other.rascunhoId == this.rascunhoId &&
          other.path == this.path &&
          other.ordem == this.ordem &&
          other.status == this.status &&
          other.evidenciaServerId == this.evidenciaServerId &&
          other.erroMensagem == this.erroMensagem);
}

class RascunhoFotosCompanion extends UpdateCompanion<RascunhoFoto> {
  final Value<int> id;
  final Value<String> rascunhoId;
  final Value<String> path;
  final Value<int> ordem;
  final Value<String> status;
  final Value<String?> evidenciaServerId;
  final Value<String?> erroMensagem;
  const RascunhoFotosCompanion({
    this.id = const Value.absent(),
    this.rascunhoId = const Value.absent(),
    this.path = const Value.absent(),
    this.ordem = const Value.absent(),
    this.status = const Value.absent(),
    this.evidenciaServerId = const Value.absent(),
    this.erroMensagem = const Value.absent(),
  });
  RascunhoFotosCompanion.insert({
    this.id = const Value.absent(),
    required String rascunhoId,
    required String path,
    required int ordem,
    this.status = const Value.absent(),
    this.evidenciaServerId = const Value.absent(),
    this.erroMensagem = const Value.absent(),
  })  : rascunhoId = Value(rascunhoId),
        path = Value(path),
        ordem = Value(ordem);
  static Insertable<RascunhoFoto> custom({
    Expression<int>? id,
    Expression<String>? rascunhoId,
    Expression<String>? path,
    Expression<int>? ordem,
    Expression<String>? status,
    Expression<String>? evidenciaServerId,
    Expression<String>? erroMensagem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rascunhoId != null) 'rascunho_id': rascunhoId,
      if (path != null) 'path': path,
      if (ordem != null) 'ordem': ordem,
      if (status != null) 'status': status,
      if (evidenciaServerId != null) 'evidencia_server_id': evidenciaServerId,
      if (erroMensagem != null) 'erro_mensagem': erroMensagem,
    });
  }

  RascunhoFotosCompanion copyWith(
      {Value<int>? id,
      Value<String>? rascunhoId,
      Value<String>? path,
      Value<int>? ordem,
      Value<String>? status,
      Value<String?>? evidenciaServerId,
      Value<String?>? erroMensagem}) {
    return RascunhoFotosCompanion(
      id: id ?? this.id,
      rascunhoId: rascunhoId ?? this.rascunhoId,
      path: path ?? this.path,
      ordem: ordem ?? this.ordem,
      status: status ?? this.status,
      evidenciaServerId: evidenciaServerId ?? this.evidenciaServerId,
      erroMensagem: erroMensagem ?? this.erroMensagem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rascunhoId.present) {
      map['rascunho_id'] = Variable<String>(rascunhoId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (evidenciaServerId.present) {
      map['evidencia_server_id'] = Variable<String>(evidenciaServerId.value);
    }
    if (erroMensagem.present) {
      map['erro_mensagem'] = Variable<String>(erroMensagem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RascunhoFotosCompanion(')
          ..write('id: $id, ')
          ..write('rascunhoId: $rascunhoId, ')
          ..write('path: $path, ')
          ..write('ordem: $ordem, ')
          ..write('status: $status, ')
          ..write('evidenciaServerId: $evidenciaServerId, ')
          ..write('erroMensagem: $erroMensagem')
          ..write(')'))
        .toString();
  }
}

class $ReferenceCacheTable extends ReferenceCache
    with TableInfo<$ReferenceCacheTable, ReferenceCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
      'chave', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dadosJsonMeta =
      const VerificationMeta('dadosJson');
  @override
  late final GeneratedColumn<String> dadosJson = GeneratedColumn<String>(
      'dados_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _atualizadoEmMeta =
      const VerificationMeta('atualizadoEm');
  @override
  late final GeneratedColumn<int> atualizadoEm = GeneratedColumn<int>(
      'atualizado_em', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [chave, dadosJson, atualizadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_cache';
  @override
  VerificationContext validateIntegrity(Insertable<ReferenceCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
          _chaveMeta, chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta));
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('dados_json')) {
      context.handle(_dadosJsonMeta,
          dadosJson.isAcceptableOrUnknown(data['dados_json']!, _dadosJsonMeta));
    } else if (isInserting) {
      context.missing(_dadosJsonMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
          _atualizadoEmMeta,
          atualizadoEm.isAcceptableOrUnknown(
              data['atualizado_em']!, _atualizadoEmMeta));
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  ReferenceCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceCacheData(
      chave: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chave'])!,
      dadosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dados_json'])!,
      atualizadoEm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}atualizado_em'])!,
    );
  }

  @override
  $ReferenceCacheTable createAlias(String alias) {
    return $ReferenceCacheTable(attachedDatabase, alias);
  }
}

class ReferenceCacheData extends DataClass
    implements Insertable<ReferenceCacheData> {
  final String chave;
  final String dadosJson;
  final int atualizadoEm;
  const ReferenceCacheData(
      {required this.chave,
      required this.dadosJson,
      required this.atualizadoEm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['dados_json'] = Variable<String>(dadosJson);
    map['atualizado_em'] = Variable<int>(atualizadoEm);
    return map;
  }

  ReferenceCacheCompanion toCompanion(bool nullToAbsent) {
    return ReferenceCacheCompanion(
      chave: Value(chave),
      dadosJson: Value(dadosJson),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory ReferenceCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceCacheData(
      chave: serializer.fromJson<String>(json['chave']),
      dadosJson: serializer.fromJson<String>(json['dadosJson']),
      atualizadoEm: serializer.fromJson<int>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'dadosJson': serializer.toJson<String>(dadosJson),
      'atualizadoEm': serializer.toJson<int>(atualizadoEm),
    };
  }

  ReferenceCacheData copyWith(
          {String? chave, String? dadosJson, int? atualizadoEm}) =>
      ReferenceCacheData(
        chave: chave ?? this.chave,
        dadosJson: dadosJson ?? this.dadosJson,
        atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      );
  ReferenceCacheData copyWithCompanion(ReferenceCacheCompanion data) {
    return ReferenceCacheData(
      chave: data.chave.present ? data.chave.value : this.chave,
      dadosJson: data.dadosJson.present ? data.dadosJson.value : this.dadosJson,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceCacheData(')
          ..write('chave: $chave, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, dadosJson, atualizadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceCacheData &&
          other.chave == this.chave &&
          other.dadosJson == this.dadosJson &&
          other.atualizadoEm == this.atualizadoEm);
}

class ReferenceCacheCompanion extends UpdateCompanion<ReferenceCacheData> {
  final Value<String> chave;
  final Value<String> dadosJson;
  final Value<int> atualizadoEm;
  final Value<int> rowid;
  const ReferenceCacheCompanion({
    this.chave = const Value.absent(),
    this.dadosJson = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceCacheCompanion.insert({
    required String chave,
    required String dadosJson,
    required int atualizadoEm,
    this.rowid = const Value.absent(),
  })  : chave = Value(chave),
        dadosJson = Value(dadosJson),
        atualizadoEm = Value(atualizadoEm);
  static Insertable<ReferenceCacheData> custom({
    Expression<String>? chave,
    Expression<String>? dadosJson,
    Expression<int>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (dadosJson != null) 'dados_json': dadosJson,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceCacheCompanion copyWith(
      {Value<String>? chave,
      Value<String>? dadosJson,
      Value<int>? atualizadoEm,
      Value<int>? rowid}) {
    return ReferenceCacheCompanion(
      chave: chave ?? this.chave,
      dadosJson: dadosJson ?? this.dadosJson,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (dadosJson.present) {
      map['dados_json'] = Variable<String>(dadosJson.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<int>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceCacheCompanion(')
          ..write('chave: $chave, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OcorrenciasCacheTable extends OcorrenciasCache
    with TableInfo<$OcorrenciasCacheTable, OcorrenciasCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcorrenciasCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<String> nivel = GeneratedColumn<String>(
      'nivel', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dadosJsonMeta =
      const VerificationMeta('dadosJson');
  @override
  late final GeneratedColumn<String> dadosJson = GeneratedColumn<String>(
      'dados_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usuarioIdMeta =
      const VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
      'usuario_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedEmMeta =
      const VerificationMeta('cachedEm');
  @override
  late final GeneratedColumn<int> cachedEm = GeneratedColumn<int>(
      'cached_em', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tipo, nivel, dadosJson, usuarioId, cachedEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocorrencias_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<OcorrenciasCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nivel')) {
      context.handle(
          _nivelMeta, nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta));
    } else if (isInserting) {
      context.missing(_nivelMeta);
    }
    if (data.containsKey('dados_json')) {
      context.handle(_dadosJsonMeta,
          dadosJson.isAcceptableOrUnknown(data['dados_json']!, _dadosJsonMeta));
    } else if (isInserting) {
      context.missing(_dadosJsonMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(_usuarioIdMeta,
          usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('cached_em')) {
      context.handle(_cachedEmMeta,
          cachedEm.isAcceptableOrUnknown(data['cached_em']!, _cachedEmMeta));
    } else if (isInserting) {
      context.missing(_cachedEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, nivel};
  @override
  OcorrenciasCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcorrenciasCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      nivel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nivel'])!,
      dadosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dados_json'])!,
      usuarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usuario_id'])!,
      cachedEm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cached_em'])!,
    );
  }

  @override
  $OcorrenciasCacheTable createAlias(String alias) {
    return $OcorrenciasCacheTable(attachedDatabase, alias);
  }
}

class OcorrenciasCacheData extends DataClass
    implements Insertable<OcorrenciasCacheData> {
  final String id;
  final String tipo;
  final String nivel;
  final String dadosJson;
  final String usuarioId;
  final int cachedEm;
  const OcorrenciasCacheData(
      {required this.id,
      required this.tipo,
      required this.nivel,
      required this.dadosJson,
      required this.usuarioId,
      required this.cachedEm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tipo'] = Variable<String>(tipo);
    map['nivel'] = Variable<String>(nivel);
    map['dados_json'] = Variable<String>(dadosJson);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['cached_em'] = Variable<int>(cachedEm);
    return map;
  }

  OcorrenciasCacheCompanion toCompanion(bool nullToAbsent) {
    return OcorrenciasCacheCompanion(
      id: Value(id),
      tipo: Value(tipo),
      nivel: Value(nivel),
      dadosJson: Value(dadosJson),
      usuarioId: Value(usuarioId),
      cachedEm: Value(cachedEm),
    );
  }

  factory OcorrenciasCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcorrenciasCacheData(
      id: serializer.fromJson<String>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nivel: serializer.fromJson<String>(json['nivel']),
      dadosJson: serializer.fromJson<String>(json['dadosJson']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      cachedEm: serializer.fromJson<int>(json['cachedEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipo': serializer.toJson<String>(tipo),
      'nivel': serializer.toJson<String>(nivel),
      'dadosJson': serializer.toJson<String>(dadosJson),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'cachedEm': serializer.toJson<int>(cachedEm),
    };
  }

  OcorrenciasCacheData copyWith(
          {String? id,
          String? tipo,
          String? nivel,
          String? dadosJson,
          String? usuarioId,
          int? cachedEm}) =>
      OcorrenciasCacheData(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        nivel: nivel ?? this.nivel,
        dadosJson: dadosJson ?? this.dadosJson,
        usuarioId: usuarioId ?? this.usuarioId,
        cachedEm: cachedEm ?? this.cachedEm,
      );
  OcorrenciasCacheData copyWithCompanion(OcorrenciasCacheCompanion data) {
    return OcorrenciasCacheData(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      dadosJson: data.dadosJson.present ? data.dadosJson.value : this.dadosJson,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      cachedEm: data.cachedEm.present ? data.cachedEm.value : this.cachedEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciasCacheData(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nivel: $nivel, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('cachedEm: $cachedEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tipo, nivel, dadosJson, usuarioId, cachedEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcorrenciasCacheData &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.nivel == this.nivel &&
          other.dadosJson == this.dadosJson &&
          other.usuarioId == this.usuarioId &&
          other.cachedEm == this.cachedEm);
}

class OcorrenciasCacheCompanion extends UpdateCompanion<OcorrenciasCacheData> {
  final Value<String> id;
  final Value<String> tipo;
  final Value<String> nivel;
  final Value<String> dadosJson;
  final Value<String> usuarioId;
  final Value<int> cachedEm;
  final Value<int> rowid;
  const OcorrenciasCacheCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nivel = const Value.absent(),
    this.dadosJson = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.cachedEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OcorrenciasCacheCompanion.insert({
    required String id,
    required String tipo,
    required String nivel,
    required String dadosJson,
    required String usuarioId,
    required int cachedEm,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tipo = Value(tipo),
        nivel = Value(nivel),
        dadosJson = Value(dadosJson),
        usuarioId = Value(usuarioId),
        cachedEm = Value(cachedEm);
  static Insertable<OcorrenciasCacheData> custom({
    Expression<String>? id,
    Expression<String>? tipo,
    Expression<String>? nivel,
    Expression<String>? dadosJson,
    Expression<String>? usuarioId,
    Expression<int>? cachedEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (nivel != null) 'nivel': nivel,
      if (dadosJson != null) 'dados_json': dadosJson,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (cachedEm != null) 'cached_em': cachedEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OcorrenciasCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? tipo,
      Value<String>? nivel,
      Value<String>? dadosJson,
      Value<String>? usuarioId,
      Value<int>? cachedEm,
      Value<int>? rowid}) {
    return OcorrenciasCacheCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      dadosJson: dadosJson ?? this.dadosJson,
      usuarioId: usuarioId ?? this.usuarioId,
      cachedEm: cachedEm ?? this.cachedEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<String>(nivel.value);
    }
    if (dadosJson.present) {
      map['dados_json'] = Variable<String>(dadosJson.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (cachedEm.present) {
      map['cached_em'] = Variable<int>(cachedEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciasCacheCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nivel: $nivel, ')
          ..write('dadosJson: $dadosJson, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('cachedEm: $cachedEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RascunhosTable rascunhos = $RascunhosTable(this);
  late final $RascunhoNormasTable rascunhoNormas = $RascunhoNormasTable(this);
  late final $RascunhoFotosTable rascunhoFotos = $RascunhoFotosTable(this);
  late final $ReferenceCacheTable referenceCache = $ReferenceCacheTable(this);
  late final $OcorrenciasCacheTable ocorrenciasCache =
      $OcorrenciasCacheTable(this);
  late final RascunhosDao rascunhosDao = RascunhosDao(this as AppDatabase);
  late final OcorrenciasCacheDao ocorrenciasCacheDao =
      OcorrenciasCacheDao(this as AppDatabase);
  late final RascunhoNormasDao rascunhoNormasDao =
      RascunhoNormasDao(this as AppDatabase);
  late final RascunhoFotosDao rascunhoFotosDao =
      RascunhoFotosDao(this as AppDatabase);
  late final ReferenceCacheDao referenceCacheDao =
      ReferenceCacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        rascunhos,
        rascunhoNormas,
        rascunhoFotos,
        referenceCache,
        ocorrenciasCache
      ];
}

typedef $$RascunhosTableCreateCompanionBuilder = RascunhosCompanion Function({
  required String id,
  required String usuarioId,
  required String tipo,
  required String titulo,
  Value<String?> descricao,
  Value<int?> severidade,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int?> capturedAt,
  Value<String?> cidade,
  Value<String?> dadosJson,
  required int criadoEm,
  Value<String> status,
  Value<String?> erroMensagem,
  Value<String?> serverId,
  Value<int> rowid,
});
typedef $$RascunhosTableUpdateCompanionBuilder = RascunhosCompanion Function({
  Value<String> id,
  Value<String> usuarioId,
  Value<String> tipo,
  Value<String> titulo,
  Value<String?> descricao,
  Value<int?> severidade,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int?> capturedAt,
  Value<String?> cidade,
  Value<String?> dadosJson,
  Value<int> criadoEm,
  Value<String> status,
  Value<String?> erroMensagem,
  Value<String?> serverId,
  Value<int> rowid,
});

final class $$RascunhosTableReferences
    extends BaseReferences<_$AppDatabase, $RascunhosTable, Rascunho> {
  $$RascunhosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RascunhoNormasTable, List<RascunhoNorma>>
      _rascunhoNormasRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.rascunhoNormas,
              aliasName: $_aliasNameGenerator(
                  db.rascunhos.id, db.rascunhoNormas.rascunhoId));

  $$RascunhoNormasTableProcessedTableManager get rascunhoNormasRefs {
    final manager = $$RascunhoNormasTableTableManager($_db, $_db.rascunhoNormas)
        .filter((f) => f.rascunhoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rascunhoNormasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RascunhoFotosTable, List<RascunhoFoto>>
      _rascunhoFotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.rascunhoFotos,
              aliasName: $_aliasNameGenerator(
                  db.rascunhos.id, db.rascunhoFotos.rascunhoId));

  $$RascunhoFotosTableProcessedTableManager get rascunhoFotosRefs {
    final manager = $$RascunhoFotosTableTableManager($_db, $_db.rascunhoFotos)
        .filter((f) => f.rascunhoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rascunhoFotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RascunhosTableFilterComposer
    extends Composer<_$AppDatabase, $RascunhosTable> {
  $$RascunhosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get severidade => $composableBuilder(
      column: $table.severidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cidade => $composableBuilder(
      column: $table.cidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get criadoEm => $composableBuilder(
      column: $table.criadoEm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  Expression<bool> rascunhoNormasRefs(
      Expression<bool> Function($$RascunhoNormasTableFilterComposer f) f) {
    final $$RascunhoNormasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rascunhoNormas,
        getReferencedColumn: (t) => t.rascunhoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhoNormasTableFilterComposer(
              $db: $db,
              $table: $db.rascunhoNormas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> rascunhoFotosRefs(
      Expression<bool> Function($$RascunhoFotosTableFilterComposer f) f) {
    final $$RascunhoFotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rascunhoFotos,
        getReferencedColumn: (t) => t.rascunhoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhoFotosTableFilterComposer(
              $db: $db,
              $table: $db.rascunhoFotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RascunhosTableOrderingComposer
    extends Composer<_$AppDatabase, $RascunhosTable> {
  $$RascunhosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severidade => $composableBuilder(
      column: $table.severidade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cidade => $composableBuilder(
      column: $table.cidade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get criadoEm => $composableBuilder(
      column: $table.criadoEm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));
}

class $$RascunhosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RascunhosTable> {
  $$RascunhosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get severidade => $composableBuilder(
      column: $table.severidade, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get cidade =>
      $composableBuilder(column: $table.cidade, builder: (column) => column);

  GeneratedColumn<String> get dadosJson =>
      $composableBuilder(column: $table.dadosJson, builder: (column) => column);

  GeneratedColumn<int> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> rascunhoNormasRefs<T extends Object>(
      Expression<T> Function($$RascunhoNormasTableAnnotationComposer a) f) {
    final $$RascunhoNormasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rascunhoNormas,
        getReferencedColumn: (t) => t.rascunhoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhoNormasTableAnnotationComposer(
              $db: $db,
              $table: $db.rascunhoNormas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> rascunhoFotosRefs<T extends Object>(
      Expression<T> Function($$RascunhoFotosTableAnnotationComposer a) f) {
    final $$RascunhoFotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rascunhoFotos,
        getReferencedColumn: (t) => t.rascunhoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhoFotosTableAnnotationComposer(
              $db: $db,
              $table: $db.rascunhoFotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RascunhosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RascunhosTable,
    Rascunho,
    $$RascunhosTableFilterComposer,
    $$RascunhosTableOrderingComposer,
    $$RascunhosTableAnnotationComposer,
    $$RascunhosTableCreateCompanionBuilder,
    $$RascunhosTableUpdateCompanionBuilder,
    (Rascunho, $$RascunhosTableReferences),
    Rascunho,
    PrefetchHooks Function({bool rascunhoNormasRefs, bool rascunhoFotosRefs})> {
  $$RascunhosTableTableManager(_$AppDatabase db, $RascunhosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RascunhosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RascunhosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RascunhosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> usuarioId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> titulo = const Value.absent(),
            Value<String?> descricao = const Value.absent(),
            Value<int?> severidade = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int?> capturedAt = const Value.absent(),
            Value<String?> cidade = const Value.absent(),
            Value<String?> dadosJson = const Value.absent(),
            Value<int> criadoEm = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> erroMensagem = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RascunhosCompanion(
            id: id,
            usuarioId: usuarioId,
            tipo: tipo,
            titulo: titulo,
            descricao: descricao,
            severidade: severidade,
            latitude: latitude,
            longitude: longitude,
            capturedAt: capturedAt,
            cidade: cidade,
            dadosJson: dadosJson,
            criadoEm: criadoEm,
            status: status,
            erroMensagem: erroMensagem,
            serverId: serverId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String usuarioId,
            required String tipo,
            required String titulo,
            Value<String?> descricao = const Value.absent(),
            Value<int?> severidade = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int?> capturedAt = const Value.absent(),
            Value<String?> cidade = const Value.absent(),
            Value<String?> dadosJson = const Value.absent(),
            required int criadoEm,
            Value<String> status = const Value.absent(),
            Value<String?> erroMensagem = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RascunhosCompanion.insert(
            id: id,
            usuarioId: usuarioId,
            tipo: tipo,
            titulo: titulo,
            descricao: descricao,
            severidade: severidade,
            latitude: latitude,
            longitude: longitude,
            capturedAt: capturedAt,
            cidade: cidade,
            dadosJson: dadosJson,
            criadoEm: criadoEm,
            status: status,
            erroMensagem: erroMensagem,
            serverId: serverId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RascunhosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {rascunhoNormasRefs = false, rascunhoFotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rascunhoNormasRefs) db.rascunhoNormas,
                if (rascunhoFotosRefs) db.rascunhoFotos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rascunhoNormasRefs)
                    await $_getPrefetchedData<Rascunho, $RascunhosTable,
                            RascunhoNorma>(
                        currentTable: table,
                        referencedTable: $$RascunhosTableReferences
                            ._rascunhoNormasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RascunhosTableReferences(db, table, p0)
                                .rascunhoNormasRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rascunhoId == item.id),
                        typedResults: items),
                  if (rascunhoFotosRefs)
                    await $_getPrefetchedData<Rascunho, $RascunhosTable,
                            RascunhoFoto>(
                        currentTable: table,
                        referencedTable: $$RascunhosTableReferences
                            ._rascunhoFotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RascunhosTableReferences(db, table, p0)
                                .rascunhoFotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rascunhoId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RascunhosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RascunhosTable,
    Rascunho,
    $$RascunhosTableFilterComposer,
    $$RascunhosTableOrderingComposer,
    $$RascunhosTableAnnotationComposer,
    $$RascunhosTableCreateCompanionBuilder,
    $$RascunhosTableUpdateCompanionBuilder,
    (Rascunho, $$RascunhosTableReferences),
    Rascunho,
    PrefetchHooks Function({bool rascunhoNormasRefs, bool rascunhoFotosRefs})>;
typedef $$RascunhoNormasTableCreateCompanionBuilder = RascunhoNormasCompanion
    Function({
  Value<int> id,
  required String rascunhoId,
  required String normaId,
  Value<String?> clausulaReferencia,
  required String textoEditado,
  Value<String> status,
});
typedef $$RascunhoNormasTableUpdateCompanionBuilder = RascunhoNormasCompanion
    Function({
  Value<int> id,
  Value<String> rascunhoId,
  Value<String> normaId,
  Value<String?> clausulaReferencia,
  Value<String> textoEditado,
  Value<String> status,
});

final class $$RascunhoNormasTableReferences
    extends BaseReferences<_$AppDatabase, $RascunhoNormasTable, RascunhoNorma> {
  $$RascunhoNormasTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RascunhosTable _rascunhoIdTable(_$AppDatabase db) =>
      db.rascunhos.createAlias(
          $_aliasNameGenerator(db.rascunhoNormas.rascunhoId, db.rascunhos.id));

  $$RascunhosTableProcessedTableManager get rascunhoId {
    final $_column = $_itemColumn<String>('rascunho_id')!;

    final manager = $$RascunhosTableTableManager($_db, $_db.rascunhos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rascunhoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RascunhoNormasTableFilterComposer
    extends Composer<_$AppDatabase, $RascunhoNormasTable> {
  $$RascunhoNormasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normaId => $composableBuilder(
      column: $table.normaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clausulaReferencia => $composableBuilder(
      column: $table.clausulaReferencia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textoEditado => $composableBuilder(
      column: $table.textoEditado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$RascunhosTableFilterComposer get rascunhoId {
    final $$RascunhosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableFilterComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoNormasTableOrderingComposer
    extends Composer<_$AppDatabase, $RascunhoNormasTable> {
  $$RascunhoNormasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normaId => $composableBuilder(
      column: $table.normaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clausulaReferencia => $composableBuilder(
      column: $table.clausulaReferencia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textoEditado => $composableBuilder(
      column: $table.textoEditado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$RascunhosTableOrderingComposer get rascunhoId {
    final $$RascunhosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableOrderingComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoNormasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RascunhoNormasTable> {
  $$RascunhoNormasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get normaId =>
      $composableBuilder(column: $table.normaId, builder: (column) => column);

  GeneratedColumn<String> get clausulaReferencia => $composableBuilder(
      column: $table.clausulaReferencia, builder: (column) => column);

  GeneratedColumn<String> get textoEditado => $composableBuilder(
      column: $table.textoEditado, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$RascunhosTableAnnotationComposer get rascunhoId {
    final $$RascunhosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableAnnotationComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoNormasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RascunhoNormasTable,
    RascunhoNorma,
    $$RascunhoNormasTableFilterComposer,
    $$RascunhoNormasTableOrderingComposer,
    $$RascunhoNormasTableAnnotationComposer,
    $$RascunhoNormasTableCreateCompanionBuilder,
    $$RascunhoNormasTableUpdateCompanionBuilder,
    (RascunhoNorma, $$RascunhoNormasTableReferences),
    RascunhoNorma,
    PrefetchHooks Function({bool rascunhoId})> {
  $$RascunhoNormasTableTableManager(
      _$AppDatabase db, $RascunhoNormasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RascunhoNormasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RascunhoNormasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RascunhoNormasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rascunhoId = const Value.absent(),
            Value<String> normaId = const Value.absent(),
            Value<String?> clausulaReferencia = const Value.absent(),
            Value<String> textoEditado = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              RascunhoNormasCompanion(
            id: id,
            rascunhoId: rascunhoId,
            normaId: normaId,
            clausulaReferencia: clausulaReferencia,
            textoEditado: textoEditado,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rascunhoId,
            required String normaId,
            Value<String?> clausulaReferencia = const Value.absent(),
            required String textoEditado,
            Value<String> status = const Value.absent(),
          }) =>
              RascunhoNormasCompanion.insert(
            id: id,
            rascunhoId: rascunhoId,
            normaId: normaId,
            clausulaReferencia: clausulaReferencia,
            textoEditado: textoEditado,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RascunhoNormasTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({rascunhoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rascunhoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rascunhoId,
                    referencedTable:
                        $$RascunhoNormasTableReferences._rascunhoIdTable(db),
                    referencedColumn:
                        $$RascunhoNormasTableReferences._rascunhoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RascunhoNormasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RascunhoNormasTable,
    RascunhoNorma,
    $$RascunhoNormasTableFilterComposer,
    $$RascunhoNormasTableOrderingComposer,
    $$RascunhoNormasTableAnnotationComposer,
    $$RascunhoNormasTableCreateCompanionBuilder,
    $$RascunhoNormasTableUpdateCompanionBuilder,
    (RascunhoNorma, $$RascunhoNormasTableReferences),
    RascunhoNorma,
    PrefetchHooks Function({bool rascunhoId})>;
typedef $$RascunhoFotosTableCreateCompanionBuilder = RascunhoFotosCompanion
    Function({
  Value<int> id,
  required String rascunhoId,
  required String path,
  required int ordem,
  Value<String> status,
  Value<String?> evidenciaServerId,
  Value<String?> erroMensagem,
});
typedef $$RascunhoFotosTableUpdateCompanionBuilder = RascunhoFotosCompanion
    Function({
  Value<int> id,
  Value<String> rascunhoId,
  Value<String> path,
  Value<int> ordem,
  Value<String> status,
  Value<String?> evidenciaServerId,
  Value<String?> erroMensagem,
});

final class $$RascunhoFotosTableReferences
    extends BaseReferences<_$AppDatabase, $RascunhoFotosTable, RascunhoFoto> {
  $$RascunhoFotosTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RascunhosTable _rascunhoIdTable(_$AppDatabase db) =>
      db.rascunhos.createAlias(
          $_aliasNameGenerator(db.rascunhoFotos.rascunhoId, db.rascunhos.id));

  $$RascunhosTableProcessedTableManager get rascunhoId {
    final $_column = $_itemColumn<String>('rascunho_id')!;

    final manager = $$RascunhosTableTableManager($_db, $_db.rascunhos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rascunhoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RascunhoFotosTableFilterComposer
    extends Composer<_$AppDatabase, $RascunhoFotosTable> {
  $$RascunhoFotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ordem => $composableBuilder(
      column: $table.ordem, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get evidenciaServerId => $composableBuilder(
      column: $table.evidenciaServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem, builder: (column) => ColumnFilters(column));

  $$RascunhosTableFilterComposer get rascunhoId {
    final $$RascunhosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableFilterComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoFotosTableOrderingComposer
    extends Composer<_$AppDatabase, $RascunhoFotosTable> {
  $$RascunhoFotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ordem => $composableBuilder(
      column: $table.ordem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get evidenciaServerId => $composableBuilder(
      column: $table.evidenciaServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem,
      builder: (column) => ColumnOrderings(column));

  $$RascunhosTableOrderingComposer get rascunhoId {
    final $$RascunhosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableOrderingComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoFotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RascunhoFotosTable> {
  $$RascunhoFotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get evidenciaServerId => $composableBuilder(
      column: $table.evidenciaServerId, builder: (column) => column);

  GeneratedColumn<String> get erroMensagem => $composableBuilder(
      column: $table.erroMensagem, builder: (column) => column);

  $$RascunhosTableAnnotationComposer get rascunhoId {
    final $$RascunhosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rascunhoId,
        referencedTable: $db.rascunhos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RascunhosTableAnnotationComposer(
              $db: $db,
              $table: $db.rascunhos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RascunhoFotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RascunhoFotosTable,
    RascunhoFoto,
    $$RascunhoFotosTableFilterComposer,
    $$RascunhoFotosTableOrderingComposer,
    $$RascunhoFotosTableAnnotationComposer,
    $$RascunhoFotosTableCreateCompanionBuilder,
    $$RascunhoFotosTableUpdateCompanionBuilder,
    (RascunhoFoto, $$RascunhoFotosTableReferences),
    RascunhoFoto,
    PrefetchHooks Function({bool rascunhoId})> {
  $$RascunhoFotosTableTableManager(_$AppDatabase db, $RascunhoFotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RascunhoFotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RascunhoFotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RascunhoFotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rascunhoId = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> ordem = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> evidenciaServerId = const Value.absent(),
            Value<String?> erroMensagem = const Value.absent(),
          }) =>
              RascunhoFotosCompanion(
            id: id,
            rascunhoId: rascunhoId,
            path: path,
            ordem: ordem,
            status: status,
            evidenciaServerId: evidenciaServerId,
            erroMensagem: erroMensagem,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rascunhoId,
            required String path,
            required int ordem,
            Value<String> status = const Value.absent(),
            Value<String?> evidenciaServerId = const Value.absent(),
            Value<String?> erroMensagem = const Value.absent(),
          }) =>
              RascunhoFotosCompanion.insert(
            id: id,
            rascunhoId: rascunhoId,
            path: path,
            ordem: ordem,
            status: status,
            evidenciaServerId: evidenciaServerId,
            erroMensagem: erroMensagem,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RascunhoFotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({rascunhoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rascunhoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rascunhoId,
                    referencedTable:
                        $$RascunhoFotosTableReferences._rascunhoIdTable(db),
                    referencedColumn:
                        $$RascunhoFotosTableReferences._rascunhoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RascunhoFotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RascunhoFotosTable,
    RascunhoFoto,
    $$RascunhoFotosTableFilterComposer,
    $$RascunhoFotosTableOrderingComposer,
    $$RascunhoFotosTableAnnotationComposer,
    $$RascunhoFotosTableCreateCompanionBuilder,
    $$RascunhoFotosTableUpdateCompanionBuilder,
    (RascunhoFoto, $$RascunhoFotosTableReferences),
    RascunhoFoto,
    PrefetchHooks Function({bool rascunhoId})>;
typedef $$ReferenceCacheTableCreateCompanionBuilder = ReferenceCacheCompanion
    Function({
  required String chave,
  required String dadosJson,
  required int atualizadoEm,
  Value<int> rowid,
});
typedef $$ReferenceCacheTableUpdateCompanionBuilder = ReferenceCacheCompanion
    Function({
  Value<String> chave,
  Value<String> dadosJson,
  Value<int> atualizadoEm,
  Value<int> rowid,
});

class $$ReferenceCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceCacheTable> {
  $$ReferenceCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
      column: $table.chave, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get atualizadoEm => $composableBuilder(
      column: $table.atualizadoEm, builder: (column) => ColumnFilters(column));
}

class $$ReferenceCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceCacheTable> {
  $$ReferenceCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
      column: $table.chave, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get atualizadoEm => $composableBuilder(
      column: $table.atualizadoEm,
      builder: (column) => ColumnOrderings(column));
}

class $$ReferenceCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceCacheTable> {
  $$ReferenceCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get dadosJson =>
      $composableBuilder(column: $table.dadosJson, builder: (column) => column);

  GeneratedColumn<int> get atualizadoEm => $composableBuilder(
      column: $table.atualizadoEm, builder: (column) => column);
}

class $$ReferenceCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReferenceCacheTable,
    ReferenceCacheData,
    $$ReferenceCacheTableFilterComposer,
    $$ReferenceCacheTableOrderingComposer,
    $$ReferenceCacheTableAnnotationComposer,
    $$ReferenceCacheTableCreateCompanionBuilder,
    $$ReferenceCacheTableUpdateCompanionBuilder,
    (
      ReferenceCacheData,
      BaseReferences<_$AppDatabase, $ReferenceCacheTable, ReferenceCacheData>
    ),
    ReferenceCacheData,
    PrefetchHooks Function()> {
  $$ReferenceCacheTableTableManager(
      _$AppDatabase db, $ReferenceCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chave = const Value.absent(),
            Value<String> dadosJson = const Value.absent(),
            Value<int> atualizadoEm = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceCacheCompanion(
            chave: chave,
            dadosJson: dadosJson,
            atualizadoEm: atualizadoEm,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String chave,
            required String dadosJson,
            required int atualizadoEm,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceCacheCompanion.insert(
            chave: chave,
            dadosJson: dadosJson,
            atualizadoEm: atualizadoEm,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferenceCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReferenceCacheTable,
    ReferenceCacheData,
    $$ReferenceCacheTableFilterComposer,
    $$ReferenceCacheTableOrderingComposer,
    $$ReferenceCacheTableAnnotationComposer,
    $$ReferenceCacheTableCreateCompanionBuilder,
    $$ReferenceCacheTableUpdateCompanionBuilder,
    (
      ReferenceCacheData,
      BaseReferences<_$AppDatabase, $ReferenceCacheTable, ReferenceCacheData>
    ),
    ReferenceCacheData,
    PrefetchHooks Function()>;
typedef $$OcorrenciasCacheTableCreateCompanionBuilder
    = OcorrenciasCacheCompanion Function({
  required String id,
  required String tipo,
  required String nivel,
  required String dadosJson,
  required String usuarioId,
  required int cachedEm,
  Value<int> rowid,
});
typedef $$OcorrenciasCacheTableUpdateCompanionBuilder
    = OcorrenciasCacheCompanion Function({
  Value<String> id,
  Value<String> tipo,
  Value<String> nivel,
  Value<String> dadosJson,
  Value<String> usuarioId,
  Value<int> cachedEm,
  Value<int> rowid,
});

class $$OcorrenciasCacheTableFilterComposer
    extends Composer<_$AppDatabase, $OcorrenciasCacheTable> {
  $$OcorrenciasCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nivel => $composableBuilder(
      column: $table.nivel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cachedEm => $composableBuilder(
      column: $table.cachedEm, builder: (column) => ColumnFilters(column));
}

class $$OcorrenciasCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $OcorrenciasCacheTable> {
  $$OcorrenciasCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nivel => $composableBuilder(
      column: $table.nivel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dadosJson => $composableBuilder(
      column: $table.dadosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usuarioId => $composableBuilder(
      column: $table.usuarioId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cachedEm => $composableBuilder(
      column: $table.cachedEm, builder: (column) => ColumnOrderings(column));
}

class $$OcorrenciasCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcorrenciasCacheTable> {
  $$OcorrenciasCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<String> get dadosJson =>
      $composableBuilder(column: $table.dadosJson, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<int> get cachedEm =>
      $composableBuilder(column: $table.cachedEm, builder: (column) => column);
}

class $$OcorrenciasCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OcorrenciasCacheTable,
    OcorrenciasCacheData,
    $$OcorrenciasCacheTableFilterComposer,
    $$OcorrenciasCacheTableOrderingComposer,
    $$OcorrenciasCacheTableAnnotationComposer,
    $$OcorrenciasCacheTableCreateCompanionBuilder,
    $$OcorrenciasCacheTableUpdateCompanionBuilder,
    (
      OcorrenciasCacheData,
      BaseReferences<_$AppDatabase, $OcorrenciasCacheTable,
          OcorrenciasCacheData>
    ),
    OcorrenciasCacheData,
    PrefetchHooks Function()> {
  $$OcorrenciasCacheTableTableManager(
      _$AppDatabase db, $OcorrenciasCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcorrenciasCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OcorrenciasCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcorrenciasCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> nivel = const Value.absent(),
            Value<String> dadosJson = const Value.absent(),
            Value<String> usuarioId = const Value.absent(),
            Value<int> cachedEm = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OcorrenciasCacheCompanion(
            id: id,
            tipo: tipo,
            nivel: nivel,
            dadosJson: dadosJson,
            usuarioId: usuarioId,
            cachedEm: cachedEm,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tipo,
            required String nivel,
            required String dadosJson,
            required String usuarioId,
            required int cachedEm,
            Value<int> rowid = const Value.absent(),
          }) =>
              OcorrenciasCacheCompanion.insert(
            id: id,
            tipo: tipo,
            nivel: nivel,
            dadosJson: dadosJson,
            usuarioId: usuarioId,
            cachedEm: cachedEm,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OcorrenciasCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OcorrenciasCacheTable,
    OcorrenciasCacheData,
    $$OcorrenciasCacheTableFilterComposer,
    $$OcorrenciasCacheTableOrderingComposer,
    $$OcorrenciasCacheTableAnnotationComposer,
    $$OcorrenciasCacheTableCreateCompanionBuilder,
    $$OcorrenciasCacheTableUpdateCompanionBuilder,
    (
      OcorrenciasCacheData,
      BaseReferences<_$AppDatabase, $OcorrenciasCacheTable,
          OcorrenciasCacheData>
    ),
    OcorrenciasCacheData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RascunhosTableTableManager get rascunhos =>
      $$RascunhosTableTableManager(_db, _db.rascunhos);
  $$RascunhoNormasTableTableManager get rascunhoNormas =>
      $$RascunhoNormasTableTableManager(_db, _db.rascunhoNormas);
  $$RascunhoFotosTableTableManager get rascunhoFotos =>
      $$RascunhoFotosTableTableManager(_db, _db.rascunhoFotos);
  $$ReferenceCacheTableTableManager get referenceCache =>
      $$ReferenceCacheTableTableManager(_db, _db.referenceCache);
  $$OcorrenciasCacheTableTableManager get ocorrenciasCache =>
      $$OcorrenciasCacheTableTableManager(_db, _db.ocorrenciasCache);
}
