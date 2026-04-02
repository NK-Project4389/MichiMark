// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ActionsTable extends Actions with TableInfo<$ActionsTable, Action> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionNameMeta = const VerificationMeta(
    'actionName',
  );
  @override
  late final GeneratedColumn<String> actionName = GeneratedColumn<String>(
    'action_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionName,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Action> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action_name')) {
      context.handle(
        _actionNameMeta,
        actionName.isAcceptableOrUnknown(data['action_name']!, _actionNameMeta),
      );
    } else if (isInserting) {
      context.missing(_actionNameMeta);
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Action map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Action(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_name'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActionsTable createAlias(String alias) {
    return $ActionsTable(attachedDatabase, alias);
  }
}

class Action extends DataClass implements Insertable<Action> {
  final String id;
  final String actionName;
  final bool isVisible;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Action({
    required this.id,
    required this.actionName,
    required this.isVisible,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action_name'] = Variable<String>(actionName);
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActionsCompanion toCompanion(bool nullToAbsent) {
    return ActionsCompanion(
      id: Value(id),
      actionName: Value(actionName),
      isVisible: Value(isVisible),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Action.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Action(
      id: serializer.fromJson<String>(json['id']),
      actionName: serializer.fromJson<String>(json['actionName']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actionName': serializer.toJson<String>(actionName),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Action copyWith({
    String? id,
    String? actionName,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Action(
    id: id ?? this.id,
    actionName: actionName ?? this.actionName,
    isVisible: isVisible ?? this.isVisible,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Action copyWithCompanion(ActionsCompanion data) {
    return Action(
      id: data.id.present ? data.id.value : this.id,
      actionName: data.actionName.present
          ? data.actionName.value
          : this.actionName,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Action(')
          ..write('id: $id, ')
          ..write('actionName: $actionName, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionName, isVisible, isDeleted, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Action &&
          other.id == this.id &&
          other.actionName == this.actionName &&
          other.isVisible == this.isVisible &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ActionsCompanion extends UpdateCompanion<Action> {
  final Value<String> id;
  final Value<String> actionName;
  final Value<bool> isVisible;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActionsCompanion({
    this.id = const Value.absent(),
    this.actionName = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionsCompanion.insert({
    required String id,
    required String actionName,
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       actionName = Value(actionName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Action> custom({
    Expression<String>? id,
    Expression<String>? actionName,
    Expression<bool>? isVisible,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionName != null) 'action_name': actionName,
      if (isVisible != null) 'is_visible': isVisible,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? actionName,
    Value<bool>? isVisible,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActionsCompanion(
      id: id ?? this.id,
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actionName.present) {
      map['action_name'] = Variable<String>(actionName.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionName: $actionName, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberNameMeta = const VerificationMeta(
    'memberName',
  );
  @override
  late final GeneratedColumn<String> memberName = GeneratedColumn<String>(
    'member_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mailAddressMeta = const VerificationMeta(
    'mailAddress',
  );
  @override
  late final GeneratedColumn<String> mailAddress = GeneratedColumn<String>(
    'mail_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memberName,
    mailAddress,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_name')) {
      context.handle(
        _memberNameMeta,
        memberName.isAcceptableOrUnknown(data['member_name']!, _memberNameMeta),
      );
    } else if (isInserting) {
      context.missing(_memberNameMeta);
    }
    if (data.containsKey('mail_address')) {
      context.handle(
        _mailAddressMeta,
        mailAddress.isAcceptableOrUnknown(
          data['mail_address']!,
          _mailAddressMeta,
        ),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memberName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_name'],
      )!,
      mailAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mail_address'],
      ),
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String memberName;
  final String? mailAddress;
  final bool isVisible;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Member({
    required this.id,
    required this.memberName,
    this.mailAddress,
    required this.isVisible,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_name'] = Variable<String>(memberName);
    if (!nullToAbsent || mailAddress != null) {
      map['mail_address'] = Variable<String>(mailAddress);
    }
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      memberName: Value(memberName),
      mailAddress: mailAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(mailAddress),
      isVisible: Value(isVisible),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      memberName: serializer.fromJson<String>(json['memberName']),
      mailAddress: serializer.fromJson<String?>(json['mailAddress']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberName': serializer.toJson<String>(memberName),
      'mailAddress': serializer.toJson<String?>(mailAddress),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Member copyWith({
    String? id,
    String? memberName,
    Value<String?> mailAddress = const Value.absent(),
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Member(
    id: id ?? this.id,
    memberName: memberName ?? this.memberName,
    mailAddress: mailAddress.present ? mailAddress.value : this.mailAddress,
    isVisible: isVisible ?? this.isVisible,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      memberName: data.memberName.present
          ? data.memberName.value
          : this.memberName,
      mailAddress: data.mailAddress.present
          ? data.mailAddress.value
          : this.mailAddress,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('memberName: $memberName, ')
          ..write('mailAddress: $mailAddress, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memberName,
    mailAddress,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.memberName == this.memberName &&
          other.mailAddress == this.mailAddress &&
          other.isVisible == this.isVisible &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String> memberName;
  final Value<String?> mailAddress;
  final Value<bool> isVisible;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.memberName = const Value.absent(),
    this.mailAddress = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String memberName,
    this.mailAddress = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberName = Value(memberName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? memberName,
    Expression<String>? mailAddress,
    Expression<bool>? isVisible,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberName != null) 'member_name': memberName,
      if (mailAddress != null) 'mail_address': mailAddress,
      if (isVisible != null) 'is_visible': isVisible,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? memberName,
    Value<String?>? mailAddress,
    Value<bool>? isVisible,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      memberName: memberName ?? this.memberName,
      mailAddress: mailAddress ?? this.mailAddress,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberName.present) {
      map['member_name'] = Variable<String>(memberName.value);
    }
    if (mailAddress.present) {
      map['mail_address'] = Variable<String>(mailAddress.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('memberName: $memberName, ')
          ..write('mailAddress: $mailAddress, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagNameMeta = const VerificationMeta(
    'tagName',
  );
  @override
  late final GeneratedColumn<String> tagName = GeneratedColumn<String>(
    'tag_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tagName,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tag_name')) {
      context.handle(
        _tagNameMeta,
        tagName.isAcceptableOrUnknown(data['tag_name']!, _tagNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tagNameMeta);
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tagName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_name'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String tagName;
  final bool isVisible;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag({
    required this.id,
    required this.tagName,
    required this.isVisible,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tag_name'] = Variable<String>(tagName);
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      tagName: Value(tagName),
      isVisible: Value(isVisible),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      tagName: serializer.fromJson<String>(json['tagName']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tagName': serializer.toJson<String>(tagName),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? tagName,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    tagName: tagName ?? this.tagName,
    isVisible: isVisible ?? this.isVisible,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      tagName: data.tagName.present ? data.tagName.value : this.tagName,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('tagName: $tagName, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tagName, isVisible, isDeleted, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.tagName == this.tagName &&
          other.isVisible == this.isVisible &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> tagName;
  final Value<bool> isVisible;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.tagName = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String tagName,
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tagName = Value(tagName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? tagName,
    Expression<bool>? isVisible,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagName != null) 'tag_name': tagName,
      if (isVisible != null) 'is_visible': isVisible,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? tagName,
    Value<bool>? isVisible,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tagName.present) {
      map['tag_name'] = Variable<String>(tagName.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('tagName: $tagName, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransportsTable extends Transports
    with TableInfo<$TransportsTable, Transport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transNameMeta = const VerificationMeta(
    'transName',
  );
  @override
  late final GeneratedColumn<String> transName = GeneratedColumn<String>(
    'trans_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kmPerGasMeta = const VerificationMeta(
    'kmPerGas',
  );
  @override
  late final GeneratedColumn<int> kmPerGas = GeneratedColumn<int>(
    'km_per_gas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meterValueMeta = const VerificationMeta(
    'meterValue',
  );
  @override
  late final GeneratedColumn<int> meterValue = GeneratedColumn<int>(
    'meter_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transName,
    kmPerGas,
    meterValue,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trans_name')) {
      context.handle(
        _transNameMeta,
        transName.isAcceptableOrUnknown(data['trans_name']!, _transNameMeta),
      );
    } else if (isInserting) {
      context.missing(_transNameMeta);
    }
    if (data.containsKey('km_per_gas')) {
      context.handle(
        _kmPerGasMeta,
        kmPerGas.isAcceptableOrUnknown(data['km_per_gas']!, _kmPerGasMeta),
      );
    }
    if (data.containsKey('meter_value')) {
      context.handle(
        _meterValueMeta,
        meterValue.isAcceptableOrUnknown(data['meter_value']!, _meterValueMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trans_name'],
      )!,
      kmPerGas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km_per_gas'],
      ),
      meterValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meter_value'],
      ),
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransportsTable createAlias(String alias) {
    return $TransportsTable(attachedDatabase, alias);
  }
}

class Transport extends DataClass implements Insertable<Transport> {
  final String id;
  final String transName;
  final int? kmPerGas;
  final int? meterValue;
  final bool isVisible;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transport({
    required this.id,
    required this.transName,
    this.kmPerGas,
    this.meterValue,
    required this.isVisible,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trans_name'] = Variable<String>(transName);
    if (!nullToAbsent || kmPerGas != null) {
      map['km_per_gas'] = Variable<int>(kmPerGas);
    }
    if (!nullToAbsent || meterValue != null) {
      map['meter_value'] = Variable<int>(meterValue);
    }
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransportsCompanion toCompanion(bool nullToAbsent) {
    return TransportsCompanion(
      id: Value(id),
      transName: Value(transName),
      kmPerGas: kmPerGas == null && nullToAbsent
          ? const Value.absent()
          : Value(kmPerGas),
      meterValue: meterValue == null && nullToAbsent
          ? const Value.absent()
          : Value(meterValue),
      isVisible: Value(isVisible),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transport(
      id: serializer.fromJson<String>(json['id']),
      transName: serializer.fromJson<String>(json['transName']),
      kmPerGas: serializer.fromJson<int?>(json['kmPerGas']),
      meterValue: serializer.fromJson<int?>(json['meterValue']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transName': serializer.toJson<String>(transName),
      'kmPerGas': serializer.toJson<int?>(kmPerGas),
      'meterValue': serializer.toJson<int?>(meterValue),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transport copyWith({
    String? id,
    String? transName,
    Value<int?> kmPerGas = const Value.absent(),
    Value<int?> meterValue = const Value.absent(),
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transport(
    id: id ?? this.id,
    transName: transName ?? this.transName,
    kmPerGas: kmPerGas.present ? kmPerGas.value : this.kmPerGas,
    meterValue: meterValue.present ? meterValue.value : this.meterValue,
    isVisible: isVisible ?? this.isVisible,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transport copyWithCompanion(TransportsCompanion data) {
    return Transport(
      id: data.id.present ? data.id.value : this.id,
      transName: data.transName.present ? data.transName.value : this.transName,
      kmPerGas: data.kmPerGas.present ? data.kmPerGas.value : this.kmPerGas,
      meterValue: data.meterValue.present
          ? data.meterValue.value
          : this.meterValue,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transport(')
          ..write('id: $id, ')
          ..write('transName: $transName, ')
          ..write('kmPerGas: $kmPerGas, ')
          ..write('meterValue: $meterValue, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transName,
    kmPerGas,
    meterValue,
    isVisible,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transport &&
          other.id == this.id &&
          other.transName == this.transName &&
          other.kmPerGas == this.kmPerGas &&
          other.meterValue == this.meterValue &&
          other.isVisible == this.isVisible &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransportsCompanion extends UpdateCompanion<Transport> {
  final Value<String> id;
  final Value<String> transName;
  final Value<int?> kmPerGas;
  final Value<int?> meterValue;
  final Value<bool> isVisible;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TransportsCompanion({
    this.id = const Value.absent(),
    this.transName = const Value.absent(),
    this.kmPerGas = const Value.absent(),
    this.meterValue = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransportsCompanion.insert({
    required String id,
    required String transName,
    this.kmPerGas = const Value.absent(),
    this.meterValue = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transName = Value(transName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transport> custom({
    Expression<String>? id,
    Expression<String>? transName,
    Expression<int>? kmPerGas,
    Expression<int>? meterValue,
    Expression<bool>? isVisible,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transName != null) 'trans_name': transName,
      if (kmPerGas != null) 'km_per_gas': kmPerGas,
      if (meterValue != null) 'meter_value': meterValue,
      if (isVisible != null) 'is_visible': isVisible,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransportsCompanion copyWith({
    Value<String>? id,
    Value<String>? transName,
    Value<int?>? kmPerGas,
    Value<int?>? meterValue,
    Value<bool>? isVisible,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransportsCompanion(
      id: id ?? this.id,
      transName: transName ?? this.transName,
      kmPerGas: kmPerGas ?? this.kmPerGas,
      meterValue: meterValue ?? this.meterValue,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transName.present) {
      map['trans_name'] = Variable<String>(transName.value);
    }
    if (kmPerGas.present) {
      map['km_per_gas'] = Variable<int>(kmPerGas.value);
    }
    if (meterValue.present) {
      map['meter_value'] = Variable<int>(meterValue.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransportsCompanion(')
          ..write('id: $id, ')
          ..write('transName: $transName, ')
          ..write('kmPerGas: $kmPerGas, ')
          ..write('meterValue: $meterValue, ')
          ..write('isVisible: $isVisible, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventNameMeta = const VerificationMeta(
    'eventName',
  );
  @override
  late final GeneratedColumn<String> eventName = GeneratedColumn<String>(
    'event_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transIdMeta = const VerificationMeta(
    'transId',
  );
  @override
  late final GeneratedColumn<String> transId = GeneratedColumn<String>(
    'trans_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transports (id)',
    ),
  );
  static const VerificationMeta _kmPerGasMeta = const VerificationMeta(
    'kmPerGas',
  );
  @override
  late final GeneratedColumn<int> kmPerGas = GeneratedColumn<int>(
    'km_per_gas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePerGasMeta = const VerificationMeta(
    'pricePerGas',
  );
  @override
  late final GeneratedColumn<int> pricePerGas = GeneratedColumn<int>(
    'price_per_gas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payMemberIdMeta = const VerificationMeta(
    'payMemberId',
  );
  @override
  late final GeneratedColumn<String> payMemberId = GeneratedColumn<String>(
    'pay_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventName,
    transId,
    kmPerGas,
    pricePerGas,
    payMemberId,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_name')) {
      context.handle(
        _eventNameMeta,
        eventName.isAcceptableOrUnknown(data['event_name']!, _eventNameMeta),
      );
    } else if (isInserting) {
      context.missing(_eventNameMeta);
    }
    if (data.containsKey('trans_id')) {
      context.handle(
        _transIdMeta,
        transId.isAcceptableOrUnknown(data['trans_id']!, _transIdMeta),
      );
    }
    if (data.containsKey('km_per_gas')) {
      context.handle(
        _kmPerGasMeta,
        kmPerGas.isAcceptableOrUnknown(data['km_per_gas']!, _kmPerGasMeta),
      );
    }
    if (data.containsKey('price_per_gas')) {
      context.handle(
        _pricePerGasMeta,
        pricePerGas.isAcceptableOrUnknown(
          data['price_per_gas']!,
          _pricePerGasMeta,
        ),
      );
    }
    if (data.containsKey('pay_member_id')) {
      context.handle(
        _payMemberIdMeta,
        payMemberId.isAcceptableOrUnknown(
          data['pay_member_id']!,
          _payMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_name'],
      )!,
      transId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trans_id'],
      ),
      kmPerGas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km_per_gas'],
      ),
      pricePerGas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_gas'],
      ),
      payMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pay_member_id'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String eventName;
  final String? transId;
  final int? kmPerGas;
  final int? pricePerGas;
  final String? payMemberId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Event({
    required this.id,
    required this.eventName,
    this.transId,
    this.kmPerGas,
    this.pricePerGas,
    this.payMemberId,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_name'] = Variable<String>(eventName);
    if (!nullToAbsent || transId != null) {
      map['trans_id'] = Variable<String>(transId);
    }
    if (!nullToAbsent || kmPerGas != null) {
      map['km_per_gas'] = Variable<int>(kmPerGas);
    }
    if (!nullToAbsent || pricePerGas != null) {
      map['price_per_gas'] = Variable<int>(pricePerGas);
    }
    if (!nullToAbsent || payMemberId != null) {
      map['pay_member_id'] = Variable<String>(payMemberId);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      eventName: Value(eventName),
      transId: transId == null && nullToAbsent
          ? const Value.absent()
          : Value(transId),
      kmPerGas: kmPerGas == null && nullToAbsent
          ? const Value.absent()
          : Value(kmPerGas),
      pricePerGas: pricePerGas == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerGas),
      payMemberId: payMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(payMemberId),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      eventName: serializer.fromJson<String>(json['eventName']),
      transId: serializer.fromJson<String?>(json['transId']),
      kmPerGas: serializer.fromJson<int?>(json['kmPerGas']),
      pricePerGas: serializer.fromJson<int?>(json['pricePerGas']),
      payMemberId: serializer.fromJson<String?>(json['payMemberId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventName': serializer.toJson<String>(eventName),
      'transId': serializer.toJson<String?>(transId),
      'kmPerGas': serializer.toJson<int?>(kmPerGas),
      'pricePerGas': serializer.toJson<int?>(pricePerGas),
      'payMemberId': serializer.toJson<String?>(payMemberId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Event copyWith({
    String? id,
    String? eventName,
    Value<String?> transId = const Value.absent(),
    Value<int?> kmPerGas = const Value.absent(),
    Value<int?> pricePerGas = const Value.absent(),
    Value<String?> payMemberId = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Event(
    id: id ?? this.id,
    eventName: eventName ?? this.eventName,
    transId: transId.present ? transId.value : this.transId,
    kmPerGas: kmPerGas.present ? kmPerGas.value : this.kmPerGas,
    pricePerGas: pricePerGas.present ? pricePerGas.value : this.pricePerGas,
    payMemberId: payMemberId.present ? payMemberId.value : this.payMemberId,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      eventName: data.eventName.present ? data.eventName.value : this.eventName,
      transId: data.transId.present ? data.transId.value : this.transId,
      kmPerGas: data.kmPerGas.present ? data.kmPerGas.value : this.kmPerGas,
      pricePerGas: data.pricePerGas.present
          ? data.pricePerGas.value
          : this.pricePerGas,
      payMemberId: data.payMemberId.present
          ? data.payMemberId.value
          : this.payMemberId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('eventName: $eventName, ')
          ..write('transId: $transId, ')
          ..write('kmPerGas: $kmPerGas, ')
          ..write('pricePerGas: $pricePerGas, ')
          ..write('payMemberId: $payMemberId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventName,
    transId,
    kmPerGas,
    pricePerGas,
    payMemberId,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.eventName == this.eventName &&
          other.transId == this.transId &&
          other.kmPerGas == this.kmPerGas &&
          other.pricePerGas == this.pricePerGas &&
          other.payMemberId == this.payMemberId &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> eventName;
  final Value<String?> transId;
  final Value<int?> kmPerGas;
  final Value<int?> pricePerGas;
  final Value<String?> payMemberId;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.eventName = const Value.absent(),
    this.transId = const Value.absent(),
    this.kmPerGas = const Value.absent(),
    this.pricePerGas = const Value.absent(),
    this.payMemberId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String eventName,
    this.transId = const Value.absent(),
    this.kmPerGas = const Value.absent(),
    this.pricePerGas = const Value.absent(),
    this.payMemberId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventName = Value(eventName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? eventName,
    Expression<String>? transId,
    Expression<int>? kmPerGas,
    Expression<int>? pricePerGas,
    Expression<String>? payMemberId,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventName != null) 'event_name': eventName,
      if (transId != null) 'trans_id': transId,
      if (kmPerGas != null) 'km_per_gas': kmPerGas,
      if (pricePerGas != null) 'price_per_gas': pricePerGas,
      if (payMemberId != null) 'pay_member_id': payMemberId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventName,
    Value<String?>? transId,
    Value<int?>? kmPerGas,
    Value<int?>? pricePerGas,
    Value<String?>? payMemberId,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      transId: transId ?? this.transId,
      kmPerGas: kmPerGas ?? this.kmPerGas,
      pricePerGas: pricePerGas ?? this.pricePerGas,
      payMemberId: payMemberId ?? this.payMemberId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventName.present) {
      map['event_name'] = Variable<String>(eventName.value);
    }
    if (transId.present) {
      map['trans_id'] = Variable<String>(transId.value);
    }
    if (kmPerGas.present) {
      map['km_per_gas'] = Variable<int>(kmPerGas.value);
    }
    if (pricePerGas.present) {
      map['price_per_gas'] = Variable<int>(pricePerGas.value);
    }
    if (payMemberId.present) {
      map['pay_member_id'] = Variable<String>(payMemberId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('eventName: $eventName, ')
          ..write('transId: $transId, ')
          ..write('kmPerGas: $kmPerGas, ')
          ..write('pricePerGas: $pricePerGas, ')
          ..write('payMemberId: $payMemberId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarkLinksTable extends MarkLinks
    with TableInfo<$MarkLinksTable, MarkLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarkLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _markLinkSeqMeta = const VerificationMeta(
    'markLinkSeq',
  );
  @override
  late final GeneratedColumn<int> markLinkSeq = GeneratedColumn<int>(
    'mark_link_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markLinkTypeMeta = const VerificationMeta(
    'markLinkType',
  );
  @override
  late final GeneratedColumn<String> markLinkType = GeneratedColumn<String>(
    'mark_link_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markLinkDateMeta = const VerificationMeta(
    'markLinkDate',
  );
  @override
  late final GeneratedColumn<DateTime> markLinkDate = GeneratedColumn<DateTime>(
    'mark_link_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markLinkNameMeta = const VerificationMeta(
    'markLinkName',
  );
  @override
  late final GeneratedColumn<String> markLinkName = GeneratedColumn<String>(
    'mark_link_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meterValueMeta = const VerificationMeta(
    'meterValue',
  );
  @override
  late final GeneratedColumn<int> meterValue = GeneratedColumn<int>(
    'meter_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceValueMeta = const VerificationMeta(
    'distanceValue',
  );
  @override
  late final GeneratedColumn<int> distanceValue = GeneratedColumn<int>(
    'distance_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFuelMeta = const VerificationMeta('isFuel');
  @override
  late final GeneratedColumn<bool> isFuel = GeneratedColumn<bool>(
    'is_fuel',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fuel" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pricePerGasMeta = const VerificationMeta(
    'pricePerGas',
  );
  @override
  late final GeneratedColumn<int> pricePerGas = GeneratedColumn<int>(
    'price_per_gas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gasQuantityMeta = const VerificationMeta(
    'gasQuantity',
  );
  @override
  late final GeneratedColumn<int> gasQuantity = GeneratedColumn<int>(
    'gas_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gasPriceMeta = const VerificationMeta(
    'gasPrice',
  );
  @override
  late final GeneratedColumn<int> gasPrice = GeneratedColumn<int>(
    'gas_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    markLinkSeq,
    markLinkType,
    markLinkDate,
    markLinkName,
    meterValue,
    distanceValue,
    memo,
    isFuel,
    pricePerGas,
    gasQuantity,
    gasPrice,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mark_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarkLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('mark_link_seq')) {
      context.handle(
        _markLinkSeqMeta,
        markLinkSeq.isAcceptableOrUnknown(
          data['mark_link_seq']!,
          _markLinkSeqMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markLinkSeqMeta);
    }
    if (data.containsKey('mark_link_type')) {
      context.handle(
        _markLinkTypeMeta,
        markLinkType.isAcceptableOrUnknown(
          data['mark_link_type']!,
          _markLinkTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markLinkTypeMeta);
    }
    if (data.containsKey('mark_link_date')) {
      context.handle(
        _markLinkDateMeta,
        markLinkDate.isAcceptableOrUnknown(
          data['mark_link_date']!,
          _markLinkDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markLinkDateMeta);
    }
    if (data.containsKey('mark_link_name')) {
      context.handle(
        _markLinkNameMeta,
        markLinkName.isAcceptableOrUnknown(
          data['mark_link_name']!,
          _markLinkNameMeta,
        ),
      );
    }
    if (data.containsKey('meter_value')) {
      context.handle(
        _meterValueMeta,
        meterValue.isAcceptableOrUnknown(data['meter_value']!, _meterValueMeta),
      );
    }
    if (data.containsKey('distance_value')) {
      context.handle(
        _distanceValueMeta,
        distanceValue.isAcceptableOrUnknown(
          data['distance_value']!,
          _distanceValueMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('is_fuel')) {
      context.handle(
        _isFuelMeta,
        isFuel.isAcceptableOrUnknown(data['is_fuel']!, _isFuelMeta),
      );
    }
    if (data.containsKey('price_per_gas')) {
      context.handle(
        _pricePerGasMeta,
        pricePerGas.isAcceptableOrUnknown(
          data['price_per_gas']!,
          _pricePerGasMeta,
        ),
      );
    }
    if (data.containsKey('gas_quantity')) {
      context.handle(
        _gasQuantityMeta,
        gasQuantity.isAcceptableOrUnknown(
          data['gas_quantity']!,
          _gasQuantityMeta,
        ),
      );
    }
    if (data.containsKey('gas_price')) {
      context.handle(
        _gasPriceMeta,
        gasPrice.isAcceptableOrUnknown(data['gas_price']!, _gasPriceMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarkLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarkLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      markLinkSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mark_link_seq'],
      )!,
      markLinkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mark_link_type'],
      )!,
      markLinkDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mark_link_date'],
      )!,
      markLinkName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mark_link_name'],
      ),
      meterValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meter_value'],
      ),
      distanceValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_value'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      isFuel: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fuel'],
      )!,
      pricePerGas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_gas'],
      ),
      gasQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gas_quantity'],
      ),
      gasPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gas_price'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MarkLinksTable createAlias(String alias) {
    return $MarkLinksTable(attachedDatabase, alias);
  }
}

class MarkLink extends DataClass implements Insertable<MarkLink> {
  final String id;
  final String eventId;
  final int markLinkSeq;
  final String markLinkType;
  final DateTime markLinkDate;
  final String? markLinkName;
  final int? meterValue;
  final int? distanceValue;
  final String? memo;
  final bool isFuel;
  final int? pricePerGas;
  final int? gasQuantity;
  final int? gasPrice;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MarkLink({
    required this.id,
    required this.eventId,
    required this.markLinkSeq,
    required this.markLinkType,
    required this.markLinkDate,
    this.markLinkName,
    this.meterValue,
    this.distanceValue,
    this.memo,
    required this.isFuel,
    this.pricePerGas,
    this.gasQuantity,
    this.gasPrice,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['mark_link_seq'] = Variable<int>(markLinkSeq);
    map['mark_link_type'] = Variable<String>(markLinkType);
    map['mark_link_date'] = Variable<DateTime>(markLinkDate);
    if (!nullToAbsent || markLinkName != null) {
      map['mark_link_name'] = Variable<String>(markLinkName);
    }
    if (!nullToAbsent || meterValue != null) {
      map['meter_value'] = Variable<int>(meterValue);
    }
    if (!nullToAbsent || distanceValue != null) {
      map['distance_value'] = Variable<int>(distanceValue);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['is_fuel'] = Variable<bool>(isFuel);
    if (!nullToAbsent || pricePerGas != null) {
      map['price_per_gas'] = Variable<int>(pricePerGas);
    }
    if (!nullToAbsent || gasQuantity != null) {
      map['gas_quantity'] = Variable<int>(gasQuantity);
    }
    if (!nullToAbsent || gasPrice != null) {
      map['gas_price'] = Variable<int>(gasPrice);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MarkLinksCompanion toCompanion(bool nullToAbsent) {
    return MarkLinksCompanion(
      id: Value(id),
      eventId: Value(eventId),
      markLinkSeq: Value(markLinkSeq),
      markLinkType: Value(markLinkType),
      markLinkDate: Value(markLinkDate),
      markLinkName: markLinkName == null && nullToAbsent
          ? const Value.absent()
          : Value(markLinkName),
      meterValue: meterValue == null && nullToAbsent
          ? const Value.absent()
          : Value(meterValue),
      distanceValue: distanceValue == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceValue),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      isFuel: Value(isFuel),
      pricePerGas: pricePerGas == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerGas),
      gasQuantity: gasQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(gasQuantity),
      gasPrice: gasPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(gasPrice),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MarkLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarkLink(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      markLinkSeq: serializer.fromJson<int>(json['markLinkSeq']),
      markLinkType: serializer.fromJson<String>(json['markLinkType']),
      markLinkDate: serializer.fromJson<DateTime>(json['markLinkDate']),
      markLinkName: serializer.fromJson<String?>(json['markLinkName']),
      meterValue: serializer.fromJson<int?>(json['meterValue']),
      distanceValue: serializer.fromJson<int?>(json['distanceValue']),
      memo: serializer.fromJson<String?>(json['memo']),
      isFuel: serializer.fromJson<bool>(json['isFuel']),
      pricePerGas: serializer.fromJson<int?>(json['pricePerGas']),
      gasQuantity: serializer.fromJson<int?>(json['gasQuantity']),
      gasPrice: serializer.fromJson<int?>(json['gasPrice']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'markLinkSeq': serializer.toJson<int>(markLinkSeq),
      'markLinkType': serializer.toJson<String>(markLinkType),
      'markLinkDate': serializer.toJson<DateTime>(markLinkDate),
      'markLinkName': serializer.toJson<String?>(markLinkName),
      'meterValue': serializer.toJson<int?>(meterValue),
      'distanceValue': serializer.toJson<int?>(distanceValue),
      'memo': serializer.toJson<String?>(memo),
      'isFuel': serializer.toJson<bool>(isFuel),
      'pricePerGas': serializer.toJson<int?>(pricePerGas),
      'gasQuantity': serializer.toJson<int?>(gasQuantity),
      'gasPrice': serializer.toJson<int?>(gasPrice),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MarkLink copyWith({
    String? id,
    String? eventId,
    int? markLinkSeq,
    String? markLinkType,
    DateTime? markLinkDate,
    Value<String?> markLinkName = const Value.absent(),
    Value<int?> meterValue = const Value.absent(),
    Value<int?> distanceValue = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    bool? isFuel,
    Value<int?> pricePerGas = const Value.absent(),
    Value<int?> gasQuantity = const Value.absent(),
    Value<int?> gasPrice = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MarkLink(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    markLinkSeq: markLinkSeq ?? this.markLinkSeq,
    markLinkType: markLinkType ?? this.markLinkType,
    markLinkDate: markLinkDate ?? this.markLinkDate,
    markLinkName: markLinkName.present ? markLinkName.value : this.markLinkName,
    meterValue: meterValue.present ? meterValue.value : this.meterValue,
    distanceValue: distanceValue.present
        ? distanceValue.value
        : this.distanceValue,
    memo: memo.present ? memo.value : this.memo,
    isFuel: isFuel ?? this.isFuel,
    pricePerGas: pricePerGas.present ? pricePerGas.value : this.pricePerGas,
    gasQuantity: gasQuantity.present ? gasQuantity.value : this.gasQuantity,
    gasPrice: gasPrice.present ? gasPrice.value : this.gasPrice,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MarkLink copyWithCompanion(MarkLinksCompanion data) {
    return MarkLink(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      markLinkSeq: data.markLinkSeq.present
          ? data.markLinkSeq.value
          : this.markLinkSeq,
      markLinkType: data.markLinkType.present
          ? data.markLinkType.value
          : this.markLinkType,
      markLinkDate: data.markLinkDate.present
          ? data.markLinkDate.value
          : this.markLinkDate,
      markLinkName: data.markLinkName.present
          ? data.markLinkName.value
          : this.markLinkName,
      meterValue: data.meterValue.present
          ? data.meterValue.value
          : this.meterValue,
      distanceValue: data.distanceValue.present
          ? data.distanceValue.value
          : this.distanceValue,
      memo: data.memo.present ? data.memo.value : this.memo,
      isFuel: data.isFuel.present ? data.isFuel.value : this.isFuel,
      pricePerGas: data.pricePerGas.present
          ? data.pricePerGas.value
          : this.pricePerGas,
      gasQuantity: data.gasQuantity.present
          ? data.gasQuantity.value
          : this.gasQuantity,
      gasPrice: data.gasPrice.present ? data.gasPrice.value : this.gasPrice,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarkLink(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('markLinkSeq: $markLinkSeq, ')
          ..write('markLinkType: $markLinkType, ')
          ..write('markLinkDate: $markLinkDate, ')
          ..write('markLinkName: $markLinkName, ')
          ..write('meterValue: $meterValue, ')
          ..write('distanceValue: $distanceValue, ')
          ..write('memo: $memo, ')
          ..write('isFuel: $isFuel, ')
          ..write('pricePerGas: $pricePerGas, ')
          ..write('gasQuantity: $gasQuantity, ')
          ..write('gasPrice: $gasPrice, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    markLinkSeq,
    markLinkType,
    markLinkDate,
    markLinkName,
    meterValue,
    distanceValue,
    memo,
    isFuel,
    pricePerGas,
    gasQuantity,
    gasPrice,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkLink &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.markLinkSeq == this.markLinkSeq &&
          other.markLinkType == this.markLinkType &&
          other.markLinkDate == this.markLinkDate &&
          other.markLinkName == this.markLinkName &&
          other.meterValue == this.meterValue &&
          other.distanceValue == this.distanceValue &&
          other.memo == this.memo &&
          other.isFuel == this.isFuel &&
          other.pricePerGas == this.pricePerGas &&
          other.gasQuantity == this.gasQuantity &&
          other.gasPrice == this.gasPrice &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MarkLinksCompanion extends UpdateCompanion<MarkLink> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<int> markLinkSeq;
  final Value<String> markLinkType;
  final Value<DateTime> markLinkDate;
  final Value<String?> markLinkName;
  final Value<int?> meterValue;
  final Value<int?> distanceValue;
  final Value<String?> memo;
  final Value<bool> isFuel;
  final Value<int?> pricePerGas;
  final Value<int?> gasQuantity;
  final Value<int?> gasPrice;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MarkLinksCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.markLinkSeq = const Value.absent(),
    this.markLinkType = const Value.absent(),
    this.markLinkDate = const Value.absent(),
    this.markLinkName = const Value.absent(),
    this.meterValue = const Value.absent(),
    this.distanceValue = const Value.absent(),
    this.memo = const Value.absent(),
    this.isFuel = const Value.absent(),
    this.pricePerGas = const Value.absent(),
    this.gasQuantity = const Value.absent(),
    this.gasPrice = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarkLinksCompanion.insert({
    required String id,
    required String eventId,
    required int markLinkSeq,
    required String markLinkType,
    required DateTime markLinkDate,
    this.markLinkName = const Value.absent(),
    this.meterValue = const Value.absent(),
    this.distanceValue = const Value.absent(),
    this.memo = const Value.absent(),
    this.isFuel = const Value.absent(),
    this.pricePerGas = const Value.absent(),
    this.gasQuantity = const Value.absent(),
    this.gasPrice = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       markLinkSeq = Value(markLinkSeq),
       markLinkType = Value(markLinkType),
       markLinkDate = Value(markLinkDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MarkLink> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<int>? markLinkSeq,
    Expression<String>? markLinkType,
    Expression<DateTime>? markLinkDate,
    Expression<String>? markLinkName,
    Expression<int>? meterValue,
    Expression<int>? distanceValue,
    Expression<String>? memo,
    Expression<bool>? isFuel,
    Expression<int>? pricePerGas,
    Expression<int>? gasQuantity,
    Expression<int>? gasPrice,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (markLinkSeq != null) 'mark_link_seq': markLinkSeq,
      if (markLinkType != null) 'mark_link_type': markLinkType,
      if (markLinkDate != null) 'mark_link_date': markLinkDate,
      if (markLinkName != null) 'mark_link_name': markLinkName,
      if (meterValue != null) 'meter_value': meterValue,
      if (distanceValue != null) 'distance_value': distanceValue,
      if (memo != null) 'memo': memo,
      if (isFuel != null) 'is_fuel': isFuel,
      if (pricePerGas != null) 'price_per_gas': pricePerGas,
      if (gasQuantity != null) 'gas_quantity': gasQuantity,
      if (gasPrice != null) 'gas_price': gasPrice,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarkLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<int>? markLinkSeq,
    Value<String>? markLinkType,
    Value<DateTime>? markLinkDate,
    Value<String?>? markLinkName,
    Value<int?>? meterValue,
    Value<int?>? distanceValue,
    Value<String?>? memo,
    Value<bool>? isFuel,
    Value<int?>? pricePerGas,
    Value<int?>? gasQuantity,
    Value<int?>? gasPrice,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MarkLinksCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      markLinkSeq: markLinkSeq ?? this.markLinkSeq,
      markLinkType: markLinkType ?? this.markLinkType,
      markLinkDate: markLinkDate ?? this.markLinkDate,
      markLinkName: markLinkName ?? this.markLinkName,
      meterValue: meterValue ?? this.meterValue,
      distanceValue: distanceValue ?? this.distanceValue,
      memo: memo ?? this.memo,
      isFuel: isFuel ?? this.isFuel,
      pricePerGas: pricePerGas ?? this.pricePerGas,
      gasQuantity: gasQuantity ?? this.gasQuantity,
      gasPrice: gasPrice ?? this.gasPrice,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (markLinkSeq.present) {
      map['mark_link_seq'] = Variable<int>(markLinkSeq.value);
    }
    if (markLinkType.present) {
      map['mark_link_type'] = Variable<String>(markLinkType.value);
    }
    if (markLinkDate.present) {
      map['mark_link_date'] = Variable<DateTime>(markLinkDate.value);
    }
    if (markLinkName.present) {
      map['mark_link_name'] = Variable<String>(markLinkName.value);
    }
    if (meterValue.present) {
      map['meter_value'] = Variable<int>(meterValue.value);
    }
    if (distanceValue.present) {
      map['distance_value'] = Variable<int>(distanceValue.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (isFuel.present) {
      map['is_fuel'] = Variable<bool>(isFuel.value);
    }
    if (pricePerGas.present) {
      map['price_per_gas'] = Variable<int>(pricePerGas.value);
    }
    if (gasQuantity.present) {
      map['gas_quantity'] = Variable<int>(gasQuantity.value);
    }
    if (gasPrice.present) {
      map['gas_price'] = Variable<int>(gasPrice.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarkLinksCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('markLinkSeq: $markLinkSeq, ')
          ..write('markLinkType: $markLinkType, ')
          ..write('markLinkDate: $markLinkDate, ')
          ..write('markLinkName: $markLinkName, ')
          ..write('meterValue: $meterValue, ')
          ..write('distanceValue: $distanceValue, ')
          ..write('memo: $memo, ')
          ..write('isFuel: $isFuel, ')
          ..write('pricePerGas: $pricePerGas, ')
          ..write('gasQuantity: $gasQuantity, ')
          ..write('gasPrice: $gasPrice, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _paymentSeqMeta = const VerificationMeta(
    'paymentSeq',
  );
  @override
  late final GeneratedColumn<int> paymentSeq = GeneratedColumn<int>(
    'payment_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentAmountMeta = const VerificationMeta(
    'paymentAmount',
  );
  @override
  late final GeneratedColumn<int> paymentAmount = GeneratedColumn<int>(
    'payment_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMemberIdMeta = const VerificationMeta(
    'paymentMemberId',
  );
  @override
  late final GeneratedColumn<String> paymentMemberId = GeneratedColumn<String>(
    'payment_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _paymentMemoMeta = const VerificationMeta(
    'paymentMemo',
  );
  @override
  late final GeneratedColumn<String> paymentMemo = GeneratedColumn<String>(
    'payment_memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    paymentSeq,
    paymentAmount,
    paymentMemberId,
    paymentMemo,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('payment_seq')) {
      context.handle(
        _paymentSeqMeta,
        paymentSeq.isAcceptableOrUnknown(data['payment_seq']!, _paymentSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentSeqMeta);
    }
    if (data.containsKey('payment_amount')) {
      context.handle(
        _paymentAmountMeta,
        paymentAmount.isAcceptableOrUnknown(
          data['payment_amount']!,
          _paymentAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentAmountMeta);
    }
    if (data.containsKey('payment_member_id')) {
      context.handle(
        _paymentMemberIdMeta,
        paymentMemberId.isAcceptableOrUnknown(
          data['payment_member_id']!,
          _paymentMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMemberIdMeta);
    }
    if (data.containsKey('payment_memo')) {
      context.handle(
        _paymentMemoMeta,
        paymentMemo.isAcceptableOrUnknown(
          data['payment_memo']!,
          _paymentMemoMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      paymentSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_seq'],
      )!,
      paymentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_amount'],
      )!,
      paymentMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_member_id'],
      )!,
      paymentMemo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_memo'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String eventId;
  final int paymentSeq;
  final int paymentAmount;
  final String paymentMemberId;
  final String? paymentMemo;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Payment({
    required this.id,
    required this.eventId,
    required this.paymentSeq,
    required this.paymentAmount,
    required this.paymentMemberId,
    this.paymentMemo,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['payment_seq'] = Variable<int>(paymentSeq);
    map['payment_amount'] = Variable<int>(paymentAmount);
    map['payment_member_id'] = Variable<String>(paymentMemberId);
    if (!nullToAbsent || paymentMemo != null) {
      map['payment_memo'] = Variable<String>(paymentMemo);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      paymentSeq: Value(paymentSeq),
      paymentAmount: Value(paymentAmount),
      paymentMemberId: Value(paymentMemberId),
      paymentMemo: paymentMemo == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMemo),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      paymentSeq: serializer.fromJson<int>(json['paymentSeq']),
      paymentAmount: serializer.fromJson<int>(json['paymentAmount']),
      paymentMemberId: serializer.fromJson<String>(json['paymentMemberId']),
      paymentMemo: serializer.fromJson<String?>(json['paymentMemo']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'paymentSeq': serializer.toJson<int>(paymentSeq),
      'paymentAmount': serializer.toJson<int>(paymentAmount),
      'paymentMemberId': serializer.toJson<String>(paymentMemberId),
      'paymentMemo': serializer.toJson<String?>(paymentMemo),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? eventId,
    int? paymentSeq,
    int? paymentAmount,
    String? paymentMemberId,
    Value<String?> paymentMemo = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Payment(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    paymentSeq: paymentSeq ?? this.paymentSeq,
    paymentAmount: paymentAmount ?? this.paymentAmount,
    paymentMemberId: paymentMemberId ?? this.paymentMemberId,
    paymentMemo: paymentMemo.present ? paymentMemo.value : this.paymentMemo,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      paymentSeq: data.paymentSeq.present
          ? data.paymentSeq.value
          : this.paymentSeq,
      paymentAmount: data.paymentAmount.present
          ? data.paymentAmount.value
          : this.paymentAmount,
      paymentMemberId: data.paymentMemberId.present
          ? data.paymentMemberId.value
          : this.paymentMemberId,
      paymentMemo: data.paymentMemo.present
          ? data.paymentMemo.value
          : this.paymentMemo,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('paymentSeq: $paymentSeq, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentMemberId: $paymentMemberId, ')
          ..write('paymentMemo: $paymentMemo, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    paymentSeq,
    paymentAmount,
    paymentMemberId,
    paymentMemo,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.paymentSeq == this.paymentSeq &&
          other.paymentAmount == this.paymentAmount &&
          other.paymentMemberId == this.paymentMemberId &&
          other.paymentMemo == this.paymentMemo &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<int> paymentSeq;
  final Value<int> paymentAmount;
  final Value<String> paymentMemberId;
  final Value<String?> paymentMemo;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.paymentSeq = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentMemberId = const Value.absent(),
    this.paymentMemo = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String eventId,
    required int paymentSeq,
    required int paymentAmount,
    required String paymentMemberId,
    this.paymentMemo = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       paymentSeq = Value(paymentSeq),
       paymentAmount = Value(paymentAmount),
       paymentMemberId = Value(paymentMemberId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<int>? paymentSeq,
    Expression<int>? paymentAmount,
    Expression<String>? paymentMemberId,
    Expression<String>? paymentMemo,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (paymentSeq != null) 'payment_seq': paymentSeq,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentMemberId != null) 'payment_member_id': paymentMemberId,
      if (paymentMemo != null) 'payment_memo': paymentMemo,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<int>? paymentSeq,
    Value<int>? paymentAmount,
    Value<String>? paymentMemberId,
    Value<String?>? paymentMemo,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      paymentSeq: paymentSeq ?? this.paymentSeq,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMemberId: paymentMemberId ?? this.paymentMemberId,
      paymentMemo: paymentMemo ?? this.paymentMemo,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (paymentSeq.present) {
      map['payment_seq'] = Variable<int>(paymentSeq.value);
    }
    if (paymentAmount.present) {
      map['payment_amount'] = Variable<int>(paymentAmount.value);
    }
    if (paymentMemberId.present) {
      map['payment_member_id'] = Variable<String>(paymentMemberId.value);
    }
    if (paymentMemo.present) {
      map['payment_memo'] = Variable<String>(paymentMemo.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('paymentSeq: $paymentSeq, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentMemberId: $paymentMemberId, ')
          ..write('paymentMemo: $paymentMemo, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventMembersTable extends EventMembers
    with TableInfo<$EventMembersTable, EventMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, memberId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, memberId};
  @override
  EventMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventMember(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
    );
  }

  @override
  $EventMembersTable createAlias(String alias) {
    return $EventMembersTable(attachedDatabase, alias);
  }
}

class EventMember extends DataClass implements Insertable<EventMember> {
  final String eventId;
  final String memberId;
  const EventMember({required this.eventId, required this.memberId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['member_id'] = Variable<String>(memberId);
    return map;
  }

  EventMembersCompanion toCompanion(bool nullToAbsent) {
    return EventMembersCompanion(
      eventId: Value(eventId),
      memberId: Value(memberId),
    );
  }

  factory EventMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventMember(
      eventId: serializer.fromJson<String>(json['eventId']),
      memberId: serializer.fromJson<String>(json['memberId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'memberId': serializer.toJson<String>(memberId),
    };
  }

  EventMember copyWith({String? eventId, String? memberId}) => EventMember(
    eventId: eventId ?? this.eventId,
    memberId: memberId ?? this.memberId,
  );
  EventMember copyWithCompanion(EventMembersCompanion data) {
    return EventMember(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventMember(')
          ..write('eventId: $eventId, ')
          ..write('memberId: $memberId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, memberId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventMember &&
          other.eventId == this.eventId &&
          other.memberId == this.memberId);
}

class EventMembersCompanion extends UpdateCompanion<EventMember> {
  final Value<String> eventId;
  final Value<String> memberId;
  final Value<int> rowid;
  const EventMembersCompanion({
    this.eventId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventMembersCompanion.insert({
    required String eventId,
    required String memberId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       memberId = Value(memberId);
  static Insertable<EventMember> custom({
    Expression<String>? eventId,
    Expression<String>? memberId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (memberId != null) 'member_id': memberId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventMembersCompanion copyWith({
    Value<String>? eventId,
    Value<String>? memberId,
    Value<int>? rowid,
  }) {
    return EventMembersCompanion(
      eventId: eventId ?? this.eventId,
      memberId: memberId ?? this.memberId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventMembersCompanion(')
          ..write('eventId: $eventId, ')
          ..write('memberId: $memberId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventTagsTable extends EventTags
    with TableInfo<$EventTagsTable, EventTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, tagId};
  @override
  EventTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTag(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EventTagsTable createAlias(String alias) {
    return $EventTagsTable(attachedDatabase, alias);
  }
}

class EventTag extends DataClass implements Insertable<EventTag> {
  final String eventId;
  final String tagId;
  const EventTag({required this.eventId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EventTagsCompanion toCompanion(bool nullToAbsent) {
    return EventTagsCompanion(eventId: Value(eventId), tagId: Value(tagId));
  }

  factory EventTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTag(
      eventId: serializer.fromJson<String>(json['eventId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EventTag copyWith({String? eventId, String? tagId}) =>
      EventTag(eventId: eventId ?? this.eventId, tagId: tagId ?? this.tagId);
  EventTag copyWithCompanion(EventTagsCompanion data) {
    return EventTag(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTag(')
          ..write('eventId: $eventId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTag &&
          other.eventId == this.eventId &&
          other.tagId == this.tagId);
}

class EventTagsCompanion extends UpdateCompanion<EventTag> {
  final Value<String> eventId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EventTagsCompanion({
    this.eventId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventTagsCompanion.insert({
    required String eventId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       tagId = Value(tagId);
  static Insertable<EventTag> custom({
    Expression<String>? eventId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventTagsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return EventTagsCompanion(
      eventId: eventId ?? this.eventId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventTagsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarkLinkMembersTable extends MarkLinkMembers
    with TableInfo<$MarkLinkMembersTable, MarkLinkMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarkLinkMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _markLinkIdMeta = const VerificationMeta(
    'markLinkId',
  );
  @override
  late final GeneratedColumn<String> markLinkId = GeneratedColumn<String>(
    'mark_link_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mark_links (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [markLinkId, memberId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mark_link_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarkLinkMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mark_link_id')) {
      context.handle(
        _markLinkIdMeta,
        markLinkId.isAcceptableOrUnknown(
          data['mark_link_id']!,
          _markLinkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markLinkIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {markLinkId, memberId};
  @override
  MarkLinkMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarkLinkMember(
      markLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mark_link_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
    );
  }

  @override
  $MarkLinkMembersTable createAlias(String alias) {
    return $MarkLinkMembersTable(attachedDatabase, alias);
  }
}

class MarkLinkMember extends DataClass implements Insertable<MarkLinkMember> {
  final String markLinkId;
  final String memberId;
  const MarkLinkMember({required this.markLinkId, required this.memberId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mark_link_id'] = Variable<String>(markLinkId);
    map['member_id'] = Variable<String>(memberId);
    return map;
  }

  MarkLinkMembersCompanion toCompanion(bool nullToAbsent) {
    return MarkLinkMembersCompanion(
      markLinkId: Value(markLinkId),
      memberId: Value(memberId),
    );
  }

  factory MarkLinkMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarkLinkMember(
      markLinkId: serializer.fromJson<String>(json['markLinkId']),
      memberId: serializer.fromJson<String>(json['memberId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'markLinkId': serializer.toJson<String>(markLinkId),
      'memberId': serializer.toJson<String>(memberId),
    };
  }

  MarkLinkMember copyWith({String? markLinkId, String? memberId}) =>
      MarkLinkMember(
        markLinkId: markLinkId ?? this.markLinkId,
        memberId: memberId ?? this.memberId,
      );
  MarkLinkMember copyWithCompanion(MarkLinkMembersCompanion data) {
    return MarkLinkMember(
      markLinkId: data.markLinkId.present
          ? data.markLinkId.value
          : this.markLinkId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarkLinkMember(')
          ..write('markLinkId: $markLinkId, ')
          ..write('memberId: $memberId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(markLinkId, memberId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkLinkMember &&
          other.markLinkId == this.markLinkId &&
          other.memberId == this.memberId);
}

class MarkLinkMembersCompanion extends UpdateCompanion<MarkLinkMember> {
  final Value<String> markLinkId;
  final Value<String> memberId;
  final Value<int> rowid;
  const MarkLinkMembersCompanion({
    this.markLinkId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarkLinkMembersCompanion.insert({
    required String markLinkId,
    required String memberId,
    this.rowid = const Value.absent(),
  }) : markLinkId = Value(markLinkId),
       memberId = Value(memberId);
  static Insertable<MarkLinkMember> custom({
    Expression<String>? markLinkId,
    Expression<String>? memberId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (markLinkId != null) 'mark_link_id': markLinkId,
      if (memberId != null) 'member_id': memberId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarkLinkMembersCompanion copyWith({
    Value<String>? markLinkId,
    Value<String>? memberId,
    Value<int>? rowid,
  }) {
    return MarkLinkMembersCompanion(
      markLinkId: markLinkId ?? this.markLinkId,
      memberId: memberId ?? this.memberId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (markLinkId.present) {
      map['mark_link_id'] = Variable<String>(markLinkId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarkLinkMembersCompanion(')
          ..write('markLinkId: $markLinkId, ')
          ..write('memberId: $memberId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarkLinkActionsTable extends MarkLinkActions
    with TableInfo<$MarkLinkActionsTable, MarkLinkAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarkLinkActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _markLinkIdMeta = const VerificationMeta(
    'markLinkId',
  );
  @override
  late final GeneratedColumn<String> markLinkId = GeneratedColumn<String>(
    'mark_link_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mark_links (id)',
    ),
  );
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES actions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [markLinkId, actionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mark_link_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarkLinkAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mark_link_id')) {
      context.handle(
        _markLinkIdMeta,
        markLinkId.isAcceptableOrUnknown(
          data['mark_link_id']!,
          _markLinkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markLinkIdMeta);
    }
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {markLinkId, actionId};
  @override
  MarkLinkAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarkLinkAction(
      markLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mark_link_id'],
      )!,
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
    );
  }

  @override
  $MarkLinkActionsTable createAlias(String alias) {
    return $MarkLinkActionsTable(attachedDatabase, alias);
  }
}

class MarkLinkAction extends DataClass implements Insertable<MarkLinkAction> {
  final String markLinkId;
  final String actionId;
  const MarkLinkAction({required this.markLinkId, required this.actionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mark_link_id'] = Variable<String>(markLinkId);
    map['action_id'] = Variable<String>(actionId);
    return map;
  }

  MarkLinkActionsCompanion toCompanion(bool nullToAbsent) {
    return MarkLinkActionsCompanion(
      markLinkId: Value(markLinkId),
      actionId: Value(actionId),
    );
  }

  factory MarkLinkAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarkLinkAction(
      markLinkId: serializer.fromJson<String>(json['markLinkId']),
      actionId: serializer.fromJson<String>(json['actionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'markLinkId': serializer.toJson<String>(markLinkId),
      'actionId': serializer.toJson<String>(actionId),
    };
  }

  MarkLinkAction copyWith({String? markLinkId, String? actionId}) =>
      MarkLinkAction(
        markLinkId: markLinkId ?? this.markLinkId,
        actionId: actionId ?? this.actionId,
      );
  MarkLinkAction copyWithCompanion(MarkLinkActionsCompanion data) {
    return MarkLinkAction(
      markLinkId: data.markLinkId.present
          ? data.markLinkId.value
          : this.markLinkId,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarkLinkAction(')
          ..write('markLinkId: $markLinkId, ')
          ..write('actionId: $actionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(markLinkId, actionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkLinkAction &&
          other.markLinkId == this.markLinkId &&
          other.actionId == this.actionId);
}

class MarkLinkActionsCompanion extends UpdateCompanion<MarkLinkAction> {
  final Value<String> markLinkId;
  final Value<String> actionId;
  final Value<int> rowid;
  const MarkLinkActionsCompanion({
    this.markLinkId = const Value.absent(),
    this.actionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarkLinkActionsCompanion.insert({
    required String markLinkId,
    required String actionId,
    this.rowid = const Value.absent(),
  }) : markLinkId = Value(markLinkId),
       actionId = Value(actionId);
  static Insertable<MarkLinkAction> custom({
    Expression<String>? markLinkId,
    Expression<String>? actionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (markLinkId != null) 'mark_link_id': markLinkId,
      if (actionId != null) 'action_id': actionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarkLinkActionsCompanion copyWith({
    Value<String>? markLinkId,
    Value<String>? actionId,
    Value<int>? rowid,
  }) {
    return MarkLinkActionsCompanion(
      markLinkId: markLinkId ?? this.markLinkId,
      actionId: actionId ?? this.actionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (markLinkId.present) {
      map['mark_link_id'] = Variable<String>(markLinkId.value);
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarkLinkActionsCompanion(')
          ..write('markLinkId: $markLinkId, ')
          ..write('actionId: $actionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentSplitMembersTable extends PaymentSplitMembers
    with TableInfo<$PaymentSplitMembersTable, PaymentSplitMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentSplitMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payments (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [paymentId, memberId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_split_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentSplitMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {paymentId, memberId};
  @override
  PaymentSplitMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentSplitMember(
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
    );
  }

  @override
  $PaymentSplitMembersTable createAlias(String alias) {
    return $PaymentSplitMembersTable(attachedDatabase, alias);
  }
}

class PaymentSplitMember extends DataClass
    implements Insertable<PaymentSplitMember> {
  final String paymentId;
  final String memberId;
  const PaymentSplitMember({required this.paymentId, required this.memberId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payment_id'] = Variable<String>(paymentId);
    map['member_id'] = Variable<String>(memberId);
    return map;
  }

  PaymentSplitMembersCompanion toCompanion(bool nullToAbsent) {
    return PaymentSplitMembersCompanion(
      paymentId: Value(paymentId),
      memberId: Value(memberId),
    );
  }

  factory PaymentSplitMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentSplitMember(
      paymentId: serializer.fromJson<String>(json['paymentId']),
      memberId: serializer.fromJson<String>(json['memberId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paymentId': serializer.toJson<String>(paymentId),
      'memberId': serializer.toJson<String>(memberId),
    };
  }

  PaymentSplitMember copyWith({String? paymentId, String? memberId}) =>
      PaymentSplitMember(
        paymentId: paymentId ?? this.paymentId,
        memberId: memberId ?? this.memberId,
      );
  PaymentSplitMember copyWithCompanion(PaymentSplitMembersCompanion data) {
    return PaymentSplitMember(
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentSplitMember(')
          ..write('paymentId: $paymentId, ')
          ..write('memberId: $memberId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(paymentId, memberId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentSplitMember &&
          other.paymentId == this.paymentId &&
          other.memberId == this.memberId);
}

class PaymentSplitMembersCompanion extends UpdateCompanion<PaymentSplitMember> {
  final Value<String> paymentId;
  final Value<String> memberId;
  final Value<int> rowid;
  const PaymentSplitMembersCompanion({
    this.paymentId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentSplitMembersCompanion.insert({
    required String paymentId,
    required String memberId,
    this.rowid = const Value.absent(),
  }) : paymentId = Value(paymentId),
       memberId = Value(memberId);
  static Insertable<PaymentSplitMember> custom({
    Expression<String>? paymentId,
    Expression<String>? memberId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (paymentId != null) 'payment_id': paymentId,
      if (memberId != null) 'member_id': memberId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentSplitMembersCompanion copyWith({
    Value<String>? paymentId,
    Value<String>? memberId,
    Value<int>? rowid,
  }) {
    return PaymentSplitMembersCompanion(
      paymentId: paymentId ?? this.paymentId,
      memberId: memberId ?? this.memberId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentSplitMembersCompanion(')
          ..write('paymentId: $paymentId, ')
          ..write('memberId: $memberId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActionsTable actions = $ActionsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransportsTable transports = $TransportsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MarkLinksTable markLinks = $MarkLinksTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $EventMembersTable eventMembers = $EventMembersTable(this);
  late final $EventTagsTable eventTags = $EventTagsTable(this);
  late final $MarkLinkMembersTable markLinkMembers = $MarkLinkMembersTable(
    this,
  );
  late final $MarkLinkActionsTable markLinkActions = $MarkLinkActionsTable(
    this,
  );
  late final $PaymentSplitMembersTable paymentSplitMembers =
      $PaymentSplitMembersTable(this);
  late final MasterDao masterDao = MasterDao(this as AppDatabase);
  late final EventDao eventDao = EventDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    actions,
    members,
    tags,
    transports,
    events,
    markLinks,
    payments,
    eventMembers,
    eventTags,
    markLinkMembers,
    markLinkActions,
    paymentSplitMembers,
  ];
}

typedef $$ActionsTableCreateCompanionBuilder =
    ActionsCompanion Function({
      required String id,
      required String actionName,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActionsTableUpdateCompanionBuilder =
    ActionsCompanion Function({
      Value<String> id,
      Value<String> actionName,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ActionsTableReferences
    extends BaseReferences<_$AppDatabase, $ActionsTable, Action> {
  $$ActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MarkLinkActionsTable, List<MarkLinkAction>>
  _markLinkActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.markLinkActions,
    aliasName: $_aliasNameGenerator(db.actions.id, db.markLinkActions.actionId),
  );

  $$MarkLinkActionsTableProcessedTableManager get markLinkActionsRefs {
    final manager = $$MarkLinkActionsTableTableManager(
      $_db,
      $_db.markLinkActions,
    ).filter((f) => f.actionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _markLinkActionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActionsTableFilterComposer
    extends Composer<_$AppDatabase, $ActionsTable> {
  $$ActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> markLinkActionsRefs(
    Expression<bool> Function($$MarkLinkActionsTableFilterComposer f) f,
  ) {
    final $$MarkLinkActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkActions,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkActionsTableFilterComposer(
            $db: $db,
            $table: $db.markLinkActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionsTable> {
  $$ActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionsTable> {
  $$ActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> markLinkActionsRefs<T extends Object>(
    Expression<T> Function($$MarkLinkActionsTableAnnotationComposer a) f,
  ) {
    final $$MarkLinkActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkActions,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinkActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionsTable,
          Action,
          $$ActionsTableFilterComposer,
          $$ActionsTableOrderingComposer,
          $$ActionsTableAnnotationComposer,
          $$ActionsTableCreateCompanionBuilder,
          $$ActionsTableUpdateCompanionBuilder,
          (Action, $$ActionsTableReferences),
          Action,
          PrefetchHooks Function({bool markLinkActionsRefs})
        > {
  $$ActionsTableTableManager(_$AppDatabase db, $ActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> actionName = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion(
                id: id,
                actionName: actionName,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String actionName,
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion.insert(
                id: id,
                actionName: actionName,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({markLinkActionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (markLinkActionsRefs) db.markLinkActions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (markLinkActionsRefs)
                    await $_getPrefetchedData<
                      Action,
                      $ActionsTable,
                      MarkLinkAction
                    >(
                      currentTable: table,
                      referencedTable: $$ActionsTableReferences
                          ._markLinkActionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ActionsTableReferences(
                        db,
                        table,
                        p0,
                      ).markLinkActionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.actionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionsTable,
      Action,
      $$ActionsTableFilterComposer,
      $$ActionsTableOrderingComposer,
      $$ActionsTableAnnotationComposer,
      $$ActionsTableCreateCompanionBuilder,
      $$ActionsTableUpdateCompanionBuilder,
      (Action, $$ActionsTableReferences),
      Action,
      PrefetchHooks Function({bool markLinkActionsRefs})
    >;
typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      required String id,
      required String memberName,
      Value<String?> mailAddress,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<String> id,
      Value<String> memberName,
      Value<String?> mailAddress,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, Member> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.members.id, db.events.payMemberId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.payMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.members.id, db.payments.paymentMemberId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments).filter(
      (f) => f.paymentMemberId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventMembersTable, List<EventMember>>
  _eventMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventMembers,
    aliasName: $_aliasNameGenerator(db.members.id, db.eventMembers.memberId),
  );

  $$EventMembersTableProcessedTableManager get eventMembersRefs {
    final manager = $$EventMembersTableTableManager(
      $_db,
      $_db.eventMembers,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MarkLinkMembersTable, List<MarkLinkMember>>
  _markLinkMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.markLinkMembers,
    aliasName: $_aliasNameGenerator(db.members.id, db.markLinkMembers.memberId),
  );

  $$MarkLinkMembersTableProcessedTableManager get markLinkMembersRefs {
    final manager = $$MarkLinkMembersTableTableManager(
      $_db,
      $_db.markLinkMembers,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _markLinkMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PaymentSplitMembersTable,
    List<PaymentSplitMember>
  >
  _paymentSplitMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentSplitMembers,
        aliasName: $_aliasNameGenerator(
          db.members.id,
          db.paymentSplitMembers.memberId,
        ),
      );

  $$PaymentSplitMembersTableProcessedTableManager get paymentSplitMembersRefs {
    final manager = $$PaymentSplitMembersTableTableManager(
      $_db,
      $_db.paymentSplitMembers,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentSplitMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberName => $composableBuilder(
    column: $table.memberName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mailAddress => $composableBuilder(
    column: $table.mailAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.payMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.paymentMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventMembersRefs(
    Expression<bool> Function($$EventMembersTableFilterComposer f) f,
  ) {
    final $$EventMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventMembers,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventMembersTableFilterComposer(
            $db: $db,
            $table: $db.eventMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> markLinkMembersRefs(
    Expression<bool> Function($$MarkLinkMembersTableFilterComposer f) f,
  ) {
    final $$MarkLinkMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkMembers,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkMembersTableFilterComposer(
            $db: $db,
            $table: $db.markLinkMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentSplitMembersRefs(
    Expression<bool> Function($$PaymentSplitMembersTableFilterComposer f) f,
  ) {
    final $$PaymentSplitMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentSplitMembers,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSplitMembersTableFilterComposer(
            $db: $db,
            $table: $db.paymentSplitMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberName => $composableBuilder(
    column: $table.memberName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mailAddress => $composableBuilder(
    column: $table.mailAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberName => $composableBuilder(
    column: $table.memberName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mailAddress => $composableBuilder(
    column: $table.mailAddress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.payMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.paymentMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventMembersRefs<T extends Object>(
    Expression<T> Function($$EventMembersTableAnnotationComposer a) f,
  ) {
    final $$EventMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventMembers,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.eventMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> markLinkMembersRefs<T extends Object>(
    Expression<T> Function($$MarkLinkMembersTableAnnotationComposer a) f,
  ) {
    final $$MarkLinkMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkMembers,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinkMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentSplitMembersRefs<T extends Object>(
    Expression<T> Function($$PaymentSplitMembersTableAnnotationComposer a) f,
  ) {
    final $$PaymentSplitMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentSplitMembers,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentSplitMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentSplitMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, $$MembersTableReferences),
          Member,
          PrefetchHooks Function({
            bool eventsRefs,
            bool paymentsRefs,
            bool eventMembersRefs,
            bool markLinkMembersRefs,
            bool paymentSplitMembersRefs,
          })
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memberName = const Value.absent(),
                Value<String?> mailAddress = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                memberName: memberName,
                mailAddress: mailAddress,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memberName,
                Value<String?> mailAddress = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                memberName: memberName,
                mailAddress: mailAddress,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventsRefs = false,
                paymentsRefs = false,
                eventMembersRefs = false,
                markLinkMembersRefs = false,
                paymentSplitMembersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (eventsRefs) db.events,
                    if (paymentsRefs) db.payments,
                    if (eventMembersRefs) db.eventMembers,
                    if (markLinkMembersRefs) db.markLinkMembers,
                    if (paymentSplitMembersRefs) db.paymentSplitMembers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (eventsRefs)
                        await $_getPrefetchedData<Member, $MembersTable, Event>(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.payMemberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          Member,
                          $MembersTable,
                          Payment
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentMemberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventMembersRefs)
                        await $_getPrefetchedData<
                          Member,
                          $MembersTable,
                          EventMember
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._eventMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).eventMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (markLinkMembersRefs)
                        await $_getPrefetchedData<
                          Member,
                          $MembersTable,
                          MarkLinkMember
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._markLinkMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).markLinkMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentSplitMembersRefs)
                        await $_getPrefetchedData<
                          Member,
                          $MembersTable,
                          PaymentSplitMember
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._paymentSplitMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentSplitMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, $$MembersTableReferences),
      Member,
      PrefetchHooks Function({
        bool eventsRefs,
        bool paymentsRefs,
        bool eventMembersRefs,
        bool markLinkMembersRefs,
        bool paymentSplitMembersRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String tagName,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> tagName,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EventTagsTable, List<EventTag>>
  _eventTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.eventTags.tagId),
  );

  $$EventTagsTableProcessedTableManager get eventTagsRefs {
    final manager = $$EventTagsTableTableManager(
      $_db,
      $_db.eventTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eventTagsRefs(
    Expression<bool> Function($$EventTagsTableFilterComposer f) f,
  ) {
    final $$EventTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableFilterComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tagName =>
      $composableBuilder(column: $table.tagName, builder: (column) => column);

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> eventTagsRefs<T extends Object>(
    Expression<T> Function($$EventTagsTableAnnotationComposer a) f,
  ) {
    final $$EventTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool eventTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tagName = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                tagName: tagName,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tagName,
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                tagName: tagName,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({eventTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eventTagsRefs) db.eventTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, EventTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._eventTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).eventTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool eventTagsRefs})
    >;
typedef $$TransportsTableCreateCompanionBuilder =
    TransportsCompanion Function({
      required String id,
      required String transName,
      Value<int?> kmPerGas,
      Value<int?> meterValue,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TransportsTableUpdateCompanionBuilder =
    TransportsCompanion Function({
      Value<String> id,
      Value<String> transName,
      Value<int?> kmPerGas,
      Value<int?> meterValue,
      Value<bool> isVisible,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TransportsTableReferences
    extends BaseReferences<_$AppDatabase, $TransportsTable, Transport> {
  $$TransportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.transports.id, db.events.transId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.transId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransportsTableFilterComposer
    extends Composer<_$AppDatabase, $TransportsTable> {
  $$TransportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transName => $composableBuilder(
    column: $table.transName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kmPerGas => $composableBuilder(
    column: $table.kmPerGas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.transId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransportsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransportsTable> {
  $$TransportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transName => $composableBuilder(
    column: $table.transName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kmPerGas => $composableBuilder(
    column: $table.kmPerGas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransportsTable> {
  $$TransportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transName =>
      $composableBuilder(column: $table.transName, builder: (column) => column);

  GeneratedColumn<int> get kmPerGas =>
      $composableBuilder(column: $table.kmPerGas, builder: (column) => column);

  GeneratedColumn<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.transId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransportsTable,
          Transport,
          $$TransportsTableFilterComposer,
          $$TransportsTableOrderingComposer,
          $$TransportsTableAnnotationComposer,
          $$TransportsTableCreateCompanionBuilder,
          $$TransportsTableUpdateCompanionBuilder,
          (Transport, $$TransportsTableReferences),
          Transport,
          PrefetchHooks Function({bool eventsRefs})
        > {
  $$TransportsTableTableManager(_$AppDatabase db, $TransportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transName = const Value.absent(),
                Value<int?> kmPerGas = const Value.absent(),
                Value<int?> meterValue = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransportsCompanion(
                id: id,
                transName: transName,
                kmPerGas: kmPerGas,
                meterValue: meterValue,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transName,
                Value<int?> kmPerGas = const Value.absent(),
                Value<int?> meterValue = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TransportsCompanion.insert(
                id: id,
                transName: transName,
                kmPerGas: kmPerGas,
                meterValue: meterValue,
                isVisible: isVisible,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eventsRefs) db.events],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventsRefs)
                    await $_getPrefetchedData<
                      Transport,
                      $TransportsTable,
                      Event
                    >(
                      currentTable: table,
                      referencedTable: $$TransportsTableReferences
                          ._eventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TransportsTableReferences(db, table, p0).eventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.transId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TransportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransportsTable,
      Transport,
      $$TransportsTableFilterComposer,
      $$TransportsTableOrderingComposer,
      $$TransportsTableAnnotationComposer,
      $$TransportsTableCreateCompanionBuilder,
      $$TransportsTableUpdateCompanionBuilder,
      (Transport, $$TransportsTableReferences),
      Transport,
      PrefetchHooks Function({bool eventsRefs})
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String eventName,
      Value<String?> transId,
      Value<int?> kmPerGas,
      Value<int?> pricePerGas,
      Value<String?> payMemberId,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> eventName,
      Value<String?> transId,
      Value<int?> kmPerGas,
      Value<int?> pricePerGas,
      Value<String?> payMemberId,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransportsTable _transIdTable(_$AppDatabase db) => db.transports
      .createAlias($_aliasNameGenerator(db.events.transId, db.transports.id));

  $$TransportsTableProcessedTableManager? get transId {
    final $_column = $_itemColumn<String>('trans_id');
    if ($_column == null) return null;
    final manager = $$TransportsTableTableManager(
      $_db,
      $_db.transports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _payMemberIdTable(_$AppDatabase db) => db.members
      .createAlias($_aliasNameGenerator(db.events.payMemberId, db.members.id));

  $$MembersTableProcessedTableManager? get payMemberId {
    final $_column = $_itemColumn<String>('pay_member_id');
    if ($_column == null) return null;
    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MarkLinksTable, List<MarkLink>>
  _markLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.markLinks,
    aliasName: $_aliasNameGenerator(db.events.id, db.markLinks.eventId),
  );

  $$MarkLinksTableProcessedTableManager get markLinksRefs {
    final manager = $$MarkLinksTableTableManager(
      $_db,
      $_db.markLinks,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_markLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.events.id, db.payments.eventId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventMembersTable, List<EventMember>>
  _eventMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventMembers,
    aliasName: $_aliasNameGenerator(db.events.id, db.eventMembers.eventId),
  );

  $$EventMembersTableProcessedTableManager get eventMembersRefs {
    final manager = $$EventMembersTableTableManager(
      $_db,
      $_db.eventMembers,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventTagsTable, List<EventTag>>
  _eventTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventTags,
    aliasName: $_aliasNameGenerator(db.events.id, db.eventTags.eventId),
  );

  $$EventTagsTableProcessedTableManager get eventTagsRefs {
    final manager = $$EventTagsTableTableManager(
      $_db,
      $_db.eventTags,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kmPerGas => $composableBuilder(
    column: $table.kmPerGas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransportsTableFilterComposer get transId {
    final $$TransportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transId,
      referencedTable: $db.transports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportsTableFilterComposer(
            $db: $db,
            $table: $db.transports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get payMemberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> markLinksRefs(
    Expression<bool> Function($$MarkLinksTableFilterComposer f) f,
  ) {
    final $$MarkLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableFilterComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventMembersRefs(
    Expression<bool> Function($$EventMembersTableFilterComposer f) f,
  ) {
    final $$EventMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventMembers,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventMembersTableFilterComposer(
            $db: $db,
            $table: $db.eventMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventTagsRefs(
    Expression<bool> Function($$EventTagsTableFilterComposer f) f,
  ) {
    final $$EventTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableFilterComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kmPerGas => $composableBuilder(
    column: $table.kmPerGas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransportsTableOrderingComposer get transId {
    final $$TransportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transId,
      referencedTable: $db.transports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportsTableOrderingComposer(
            $db: $db,
            $table: $db.transports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get payMemberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventName =>
      $composableBuilder(column: $table.eventName, builder: (column) => column);

  GeneratedColumn<int> get kmPerGas =>
      $composableBuilder(column: $table.kmPerGas, builder: (column) => column);

  GeneratedColumn<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TransportsTableAnnotationComposer get transId {
    final $$TransportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transId,
      referencedTable: $db.transports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportsTableAnnotationComposer(
            $db: $db,
            $table: $db.transports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get payMemberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> markLinksRefs<T extends Object>(
    Expression<T> Function($$MarkLinksTableAnnotationComposer a) f,
  ) {
    final $$MarkLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventMembersRefs<T extends Object>(
    Expression<T> Function($$EventMembersTableAnnotationComposer a) f,
  ) {
    final $$EventMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventMembers,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.eventMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventTagsRefs<T extends Object>(
    Expression<T> Function($$EventTagsTableAnnotationComposer a) f,
  ) {
    final $$EventTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({
            bool transId,
            bool payMemberId,
            bool markLinksRefs,
            bool paymentsRefs,
            bool eventMembersRefs,
            bool eventTagsRefs,
          })
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventName = const Value.absent(),
                Value<String?> transId = const Value.absent(),
                Value<int?> kmPerGas = const Value.absent(),
                Value<int?> pricePerGas = const Value.absent(),
                Value<String?> payMemberId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                eventName: eventName,
                transId: transId,
                kmPerGas: kmPerGas,
                pricePerGas: pricePerGas,
                payMemberId: payMemberId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventName,
                Value<String?> transId = const Value.absent(),
                Value<int?> kmPerGas = const Value.absent(),
                Value<int?> pricePerGas = const Value.absent(),
                Value<String?> payMemberId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                eventName: eventName,
                transId: transId,
                kmPerGas: kmPerGas,
                pricePerGas: pricePerGas,
                payMemberId: payMemberId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transId = false,
                payMemberId = false,
                markLinksRefs = false,
                paymentsRefs = false,
                eventMembersRefs = false,
                eventTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (markLinksRefs) db.markLinks,
                    if (paymentsRefs) db.payments,
                    if (eventMembersRefs) db.eventMembers,
                    if (eventTagsRefs) db.eventTags,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (transId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transId,
                                    referencedTable: $$EventsTableReferences
                                        ._transIdTable(db),
                                    referencedColumn: $$EventsTableReferences
                                        ._transIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (payMemberId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.payMemberId,
                                    referencedTable: $$EventsTableReferences
                                        ._payMemberIdTable(db),
                                    referencedColumn: $$EventsTableReferences
                                        ._payMemberIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (markLinksRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          MarkLink
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._markLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).markLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<Event, $EventsTable, Payment>(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventMembersRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          EventMember
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventTagsRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          EventTag
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({
        bool transId,
        bool payMemberId,
        bool markLinksRefs,
        bool paymentsRefs,
        bool eventMembersRefs,
        bool eventTagsRefs,
      })
    >;
typedef $$MarkLinksTableCreateCompanionBuilder =
    MarkLinksCompanion Function({
      required String id,
      required String eventId,
      required int markLinkSeq,
      required String markLinkType,
      required DateTime markLinkDate,
      Value<String?> markLinkName,
      Value<int?> meterValue,
      Value<int?> distanceValue,
      Value<String?> memo,
      Value<bool> isFuel,
      Value<int?> pricePerGas,
      Value<int?> gasQuantity,
      Value<int?> gasPrice,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MarkLinksTableUpdateCompanionBuilder =
    MarkLinksCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<int> markLinkSeq,
      Value<String> markLinkType,
      Value<DateTime> markLinkDate,
      Value<String?> markLinkName,
      Value<int?> meterValue,
      Value<int?> distanceValue,
      Value<String?> memo,
      Value<bool> isFuel,
      Value<int?> pricePerGas,
      Value<int?> gasQuantity,
      Value<int?> gasPrice,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MarkLinksTableReferences
    extends BaseReferences<_$AppDatabase, $MarkLinksTable, MarkLink> {
  $$MarkLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.markLinks.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MarkLinkMembersTable, List<MarkLinkMember>>
  _markLinkMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.markLinkMembers,
    aliasName: $_aliasNameGenerator(
      db.markLinks.id,
      db.markLinkMembers.markLinkId,
    ),
  );

  $$MarkLinkMembersTableProcessedTableManager get markLinkMembersRefs {
    final manager = $$MarkLinkMembersTableTableManager(
      $_db,
      $_db.markLinkMembers,
    ).filter((f) => f.markLinkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _markLinkMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MarkLinkActionsTable, List<MarkLinkAction>>
  _markLinkActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.markLinkActions,
    aliasName: $_aliasNameGenerator(
      db.markLinks.id,
      db.markLinkActions.markLinkId,
    ),
  );

  $$MarkLinkActionsTableProcessedTableManager get markLinkActionsRefs {
    final manager = $$MarkLinkActionsTableTableManager(
      $_db,
      $_db.markLinkActions,
    ).filter((f) => f.markLinkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _markLinkActionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MarkLinksTableFilterComposer
    extends Composer<_$AppDatabase, $MarkLinksTable> {
  $$MarkLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get markLinkSeq => $composableBuilder(
    column: $table.markLinkSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markLinkType => $composableBuilder(
    column: $table.markLinkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get markLinkDate => $composableBuilder(
    column: $table.markLinkDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markLinkName => $composableBuilder(
    column: $table.markLinkName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceValue => $composableBuilder(
    column: $table.distanceValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFuel => $composableBuilder(
    column: $table.isFuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gasQuantity => $composableBuilder(
    column: $table.gasQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gasPrice => $composableBuilder(
    column: $table.gasPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> markLinkMembersRefs(
    Expression<bool> Function($$MarkLinkMembersTableFilterComposer f) f,
  ) {
    final $$MarkLinkMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkMembers,
      getReferencedColumn: (t) => t.markLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkMembersTableFilterComposer(
            $db: $db,
            $table: $db.markLinkMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> markLinkActionsRefs(
    Expression<bool> Function($$MarkLinkActionsTableFilterComposer f) f,
  ) {
    final $$MarkLinkActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkActions,
      getReferencedColumn: (t) => t.markLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkActionsTableFilterComposer(
            $db: $db,
            $table: $db.markLinkActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MarkLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $MarkLinksTable> {
  $$MarkLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get markLinkSeq => $composableBuilder(
    column: $table.markLinkSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markLinkType => $composableBuilder(
    column: $table.markLinkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get markLinkDate => $composableBuilder(
    column: $table.markLinkDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markLinkName => $composableBuilder(
    column: $table.markLinkName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceValue => $composableBuilder(
    column: $table.distanceValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFuel => $composableBuilder(
    column: $table.isFuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gasQuantity => $composableBuilder(
    column: $table.gasQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gasPrice => $composableBuilder(
    column: $table.gasPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarkLinksTable> {
  $$MarkLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get markLinkSeq => $composableBuilder(
    column: $table.markLinkSeq,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markLinkType => $composableBuilder(
    column: $table.markLinkType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get markLinkDate => $composableBuilder(
    column: $table.markLinkDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markLinkName => $composableBuilder(
    column: $table.markLinkName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get meterValue => $composableBuilder(
    column: $table.meterValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceValue => $composableBuilder(
    column: $table.distanceValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get isFuel =>
      $composableBuilder(column: $table.isFuel, builder: (column) => column);

  GeneratedColumn<int> get pricePerGas => $composableBuilder(
    column: $table.pricePerGas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gasQuantity => $composableBuilder(
    column: $table.gasQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gasPrice =>
      $composableBuilder(column: $table.gasPrice, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> markLinkMembersRefs<T extends Object>(
    Expression<T> Function($$MarkLinkMembersTableAnnotationComposer a) f,
  ) {
    final $$MarkLinkMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkMembers,
      getReferencedColumn: (t) => t.markLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinkMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> markLinkActionsRefs<T extends Object>(
    Expression<T> Function($$MarkLinkActionsTableAnnotationComposer a) f,
  ) {
    final $$MarkLinkActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markLinkActions,
      getReferencedColumn: (t) => t.markLinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinkActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinkActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MarkLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarkLinksTable,
          MarkLink,
          $$MarkLinksTableFilterComposer,
          $$MarkLinksTableOrderingComposer,
          $$MarkLinksTableAnnotationComposer,
          $$MarkLinksTableCreateCompanionBuilder,
          $$MarkLinksTableUpdateCompanionBuilder,
          (MarkLink, $$MarkLinksTableReferences),
          MarkLink,
          PrefetchHooks Function({
            bool eventId,
            bool markLinkMembersRefs,
            bool markLinkActionsRefs,
          })
        > {
  $$MarkLinksTableTableManager(_$AppDatabase db, $MarkLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarkLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarkLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarkLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> markLinkSeq = const Value.absent(),
                Value<String> markLinkType = const Value.absent(),
                Value<DateTime> markLinkDate = const Value.absent(),
                Value<String?> markLinkName = const Value.absent(),
                Value<int?> meterValue = const Value.absent(),
                Value<int?> distanceValue = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<bool> isFuel = const Value.absent(),
                Value<int?> pricePerGas = const Value.absent(),
                Value<int?> gasQuantity = const Value.absent(),
                Value<int?> gasPrice = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarkLinksCompanion(
                id: id,
                eventId: eventId,
                markLinkSeq: markLinkSeq,
                markLinkType: markLinkType,
                markLinkDate: markLinkDate,
                markLinkName: markLinkName,
                meterValue: meterValue,
                distanceValue: distanceValue,
                memo: memo,
                isFuel: isFuel,
                pricePerGas: pricePerGas,
                gasQuantity: gasQuantity,
                gasPrice: gasPrice,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required int markLinkSeq,
                required String markLinkType,
                required DateTime markLinkDate,
                Value<String?> markLinkName = const Value.absent(),
                Value<int?> meterValue = const Value.absent(),
                Value<int?> distanceValue = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<bool> isFuel = const Value.absent(),
                Value<int?> pricePerGas = const Value.absent(),
                Value<int?> gasQuantity = const Value.absent(),
                Value<int?> gasPrice = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MarkLinksCompanion.insert(
                id: id,
                eventId: eventId,
                markLinkSeq: markLinkSeq,
                markLinkType: markLinkType,
                markLinkDate: markLinkDate,
                markLinkName: markLinkName,
                meterValue: meterValue,
                distanceValue: distanceValue,
                memo: memo,
                isFuel: isFuel,
                pricePerGas: pricePerGas,
                gasQuantity: gasQuantity,
                gasPrice: gasPrice,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MarkLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventId = false,
                markLinkMembersRefs = false,
                markLinkActionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (markLinkMembersRefs) db.markLinkMembers,
                    if (markLinkActionsRefs) db.markLinkActions,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable: $$MarkLinksTableReferences
                                        ._eventIdTable(db),
                                    referencedColumn: $$MarkLinksTableReferences
                                        ._eventIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (markLinkMembersRefs)
                        await $_getPrefetchedData<
                          MarkLink,
                          $MarkLinksTable,
                          MarkLinkMember
                        >(
                          currentTable: table,
                          referencedTable: $$MarkLinksTableReferences
                              ._markLinkMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MarkLinksTableReferences(
                                db,
                                table,
                                p0,
                              ).markLinkMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.markLinkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (markLinkActionsRefs)
                        await $_getPrefetchedData<
                          MarkLink,
                          $MarkLinksTable,
                          MarkLinkAction
                        >(
                          currentTable: table,
                          referencedTable: $$MarkLinksTableReferences
                              ._markLinkActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MarkLinksTableReferences(
                                db,
                                table,
                                p0,
                              ).markLinkActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.markLinkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MarkLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarkLinksTable,
      MarkLink,
      $$MarkLinksTableFilterComposer,
      $$MarkLinksTableOrderingComposer,
      $$MarkLinksTableAnnotationComposer,
      $$MarkLinksTableCreateCompanionBuilder,
      $$MarkLinksTableUpdateCompanionBuilder,
      (MarkLink, $$MarkLinksTableReferences),
      MarkLink,
      PrefetchHooks Function({
        bool eventId,
        bool markLinkMembersRefs,
        bool markLinkActionsRefs,
      })
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String eventId,
      required int paymentSeq,
      required int paymentAmount,
      required String paymentMemberId,
      Value<String?> paymentMemo,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<int> paymentSeq,
      Value<int> paymentAmount,
      Value<String> paymentMemberId,
      Value<String?> paymentMemo,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.payments.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _paymentMemberIdTable(_$AppDatabase db) =>
      db.members.createAlias(
        $_aliasNameGenerator(db.payments.paymentMemberId, db.members.id),
      );

  $$MembersTableProcessedTableManager get paymentMemberId {
    final $_column = $_itemColumn<String>('payment_member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PaymentSplitMembersTable,
    List<PaymentSplitMember>
  >
  _paymentSplitMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentSplitMembers,
        aliasName: $_aliasNameGenerator(
          db.payments.id,
          db.paymentSplitMembers.paymentId,
        ),
      );

  $$PaymentSplitMembersTableProcessedTableManager get paymentSplitMembersRefs {
    final manager = $$PaymentSplitMembersTableTableManager(
      $_db,
      $_db.paymentSplitMembers,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentSplitMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentSeq => $composableBuilder(
    column: $table.paymentSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMemo => $composableBuilder(
    column: $table.paymentMemo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get paymentMemberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentSplitMembersRefs(
    Expression<bool> Function($$PaymentSplitMembersTableFilterComposer f) f,
  ) {
    final $$PaymentSplitMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentSplitMembers,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSplitMembersTableFilterComposer(
            $db: $db,
            $table: $db.paymentSplitMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentSeq => $composableBuilder(
    column: $table.paymentSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMemo => $composableBuilder(
    column: $table.paymentMemo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get paymentMemberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get paymentSeq => $composableBuilder(
    column: $table.paymentSeq,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMemo => $composableBuilder(
    column: $table.paymentMemo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get paymentMemberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentSplitMembersRefs<T extends Object>(
    Expression<T> Function($$PaymentSplitMembersTableAnnotationComposer a) f,
  ) {
    final $$PaymentSplitMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentSplitMembers,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentSplitMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentSplitMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({
            bool eventId,
            bool paymentMemberId,
            bool paymentSplitMembersRefs,
          })
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> paymentSeq = const Value.absent(),
                Value<int> paymentAmount = const Value.absent(),
                Value<String> paymentMemberId = const Value.absent(),
                Value<String?> paymentMemo = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                eventId: eventId,
                paymentSeq: paymentSeq,
                paymentAmount: paymentAmount,
                paymentMemberId: paymentMemberId,
                paymentMemo: paymentMemo,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required int paymentSeq,
                required int paymentAmount,
                required String paymentMemberId,
                Value<String?> paymentMemo = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                eventId: eventId,
                paymentSeq: paymentSeq,
                paymentAmount: paymentAmount,
                paymentMemberId: paymentMemberId,
                paymentMemo: paymentMemo,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventId = false,
                paymentMemberId = false,
                paymentSplitMembersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentSplitMembersRefs) db.paymentSplitMembers,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable: $$PaymentsTableReferences
                                        ._eventIdTable(db),
                                    referencedColumn: $$PaymentsTableReferences
                                        ._eventIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (paymentMemberId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paymentMemberId,
                                    referencedTable: $$PaymentsTableReferences
                                        ._paymentMemberIdTable(db),
                                    referencedColumn: $$PaymentsTableReferences
                                        ._paymentMemberIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentSplitMembersRefs)
                        await $_getPrefetchedData<
                          Payment,
                          $PaymentsTable,
                          PaymentSplitMember
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentsTableReferences
                              ._paymentSplitMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentSplitMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({
        bool eventId,
        bool paymentMemberId,
        bool paymentSplitMembersRefs,
      })
    >;
typedef $$EventMembersTableCreateCompanionBuilder =
    EventMembersCompanion Function({
      required String eventId,
      required String memberId,
      Value<int> rowid,
    });
typedef $$EventMembersTableUpdateCompanionBuilder =
    EventMembersCompanion Function({
      Value<String> eventId,
      Value<String> memberId,
      Value<int> rowid,
    });

final class $$EventMembersTableReferences
    extends BaseReferences<_$AppDatabase, $EventMembersTable, EventMember> {
  $$EventMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.eventMembers.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias(
        $_aliasNameGenerator(db.eventMembers.memberId, db.members.id),
      );

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventMembersTableFilterComposer
    extends Composer<_$AppDatabase, $EventMembersTable> {
  $$EventMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $EventMembersTable> {
  $$EventMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventMembersTable> {
  $$EventMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventMembersTable,
          EventMember,
          $$EventMembersTableFilterComposer,
          $$EventMembersTableOrderingComposer,
          $$EventMembersTableAnnotationComposer,
          $$EventMembersTableCreateCompanionBuilder,
          $$EventMembersTableUpdateCompanionBuilder,
          (EventMember, $$EventMembersTableReferences),
          EventMember,
          PrefetchHooks Function({bool eventId, bool memberId})
        > {
  $$EventMembersTableTableManager(_$AppDatabase db, $EventMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventMembersCompanion(
                eventId: eventId,
                memberId: memberId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String memberId,
                Value<int> rowid = const Value.absent(),
              }) => EventMembersCompanion.insert(
                eventId: eventId,
                memberId: memberId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, memberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventMembersTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$EventMembersTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (memberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memberId,
                                referencedTable: $$EventMembersTableReferences
                                    ._memberIdTable(db),
                                referencedColumn: $$EventMembersTableReferences
                                    ._memberIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventMembersTable,
      EventMember,
      $$EventMembersTableFilterComposer,
      $$EventMembersTableOrderingComposer,
      $$EventMembersTableAnnotationComposer,
      $$EventMembersTableCreateCompanionBuilder,
      $$EventMembersTableUpdateCompanionBuilder,
      (EventMember, $$EventMembersTableReferences),
      EventMember,
      PrefetchHooks Function({bool eventId, bool memberId})
    >;
typedef $$EventTagsTableCreateCompanionBuilder =
    EventTagsCompanion Function({
      required String eventId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$EventTagsTableUpdateCompanionBuilder =
    EventTagsCompanion Function({
      Value<String> eventId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$EventTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EventTagsTable, EventTag> {
  $$EventTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.eventTags.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.eventTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventTagsTable,
          EventTag,
          $$EventTagsTableFilterComposer,
          $$EventTagsTableOrderingComposer,
          $$EventTagsTableAnnotationComposer,
          $$EventTagsTableCreateCompanionBuilder,
          $$EventTagsTableUpdateCompanionBuilder,
          (EventTag, $$EventTagsTableReferences),
          EventTag,
          PrefetchHooks Function({bool eventId, bool tagId})
        > {
  $$EventTagsTableTableManager(_$AppDatabase db, $EventTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventTagsCompanion(
                eventId: eventId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => EventTagsCompanion.insert(
                eventId: eventId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventTagsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$EventTagsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EventTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EventTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventTagsTable,
      EventTag,
      $$EventTagsTableFilterComposer,
      $$EventTagsTableOrderingComposer,
      $$EventTagsTableAnnotationComposer,
      $$EventTagsTableCreateCompanionBuilder,
      $$EventTagsTableUpdateCompanionBuilder,
      (EventTag, $$EventTagsTableReferences),
      EventTag,
      PrefetchHooks Function({bool eventId, bool tagId})
    >;
typedef $$MarkLinkMembersTableCreateCompanionBuilder =
    MarkLinkMembersCompanion Function({
      required String markLinkId,
      required String memberId,
      Value<int> rowid,
    });
typedef $$MarkLinkMembersTableUpdateCompanionBuilder =
    MarkLinkMembersCompanion Function({
      Value<String> markLinkId,
      Value<String> memberId,
      Value<int> rowid,
    });

final class $$MarkLinkMembersTableReferences
    extends
        BaseReferences<_$AppDatabase, $MarkLinkMembersTable, MarkLinkMember> {
  $$MarkLinkMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MarkLinksTable _markLinkIdTable(_$AppDatabase db) =>
      db.markLinks.createAlias(
        $_aliasNameGenerator(db.markLinkMembers.markLinkId, db.markLinks.id),
      );

  $$MarkLinksTableProcessedTableManager get markLinkId {
    final $_column = $_itemColumn<String>('mark_link_id')!;

    final manager = $$MarkLinksTableTableManager(
      $_db,
      $_db.markLinks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_markLinkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias(
        $_aliasNameGenerator(db.markLinkMembers.memberId, db.members.id),
      );

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MarkLinkMembersTableFilterComposer
    extends Composer<_$AppDatabase, $MarkLinkMembersTable> {
  $$MarkLinkMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableFilterComposer get markLinkId {
    final $$MarkLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableFilterComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MarkLinkMembersTable> {
  $$MarkLinkMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableOrderingComposer get markLinkId {
    final $$MarkLinksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableOrderingComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarkLinkMembersTable> {
  $$MarkLinkMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableAnnotationComposer get markLinkId {
    final $$MarkLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarkLinkMembersTable,
          MarkLinkMember,
          $$MarkLinkMembersTableFilterComposer,
          $$MarkLinkMembersTableOrderingComposer,
          $$MarkLinkMembersTableAnnotationComposer,
          $$MarkLinkMembersTableCreateCompanionBuilder,
          $$MarkLinkMembersTableUpdateCompanionBuilder,
          (MarkLinkMember, $$MarkLinkMembersTableReferences),
          MarkLinkMember,
          PrefetchHooks Function({bool markLinkId, bool memberId})
        > {
  $$MarkLinkMembersTableTableManager(
    _$AppDatabase db,
    $MarkLinkMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarkLinkMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarkLinkMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarkLinkMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> markLinkId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarkLinkMembersCompanion(
                markLinkId: markLinkId,
                memberId: memberId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String markLinkId,
                required String memberId,
                Value<int> rowid = const Value.absent(),
              }) => MarkLinkMembersCompanion.insert(
                markLinkId: markLinkId,
                memberId: memberId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MarkLinkMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({markLinkId = false, memberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (markLinkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.markLinkId,
                                referencedTable:
                                    $$MarkLinkMembersTableReferences
                                        ._markLinkIdTable(db),
                                referencedColumn:
                                    $$MarkLinkMembersTableReferences
                                        ._markLinkIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (memberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memberId,
                                referencedTable:
                                    $$MarkLinkMembersTableReferences
                                        ._memberIdTable(db),
                                referencedColumn:
                                    $$MarkLinkMembersTableReferences
                                        ._memberIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MarkLinkMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarkLinkMembersTable,
      MarkLinkMember,
      $$MarkLinkMembersTableFilterComposer,
      $$MarkLinkMembersTableOrderingComposer,
      $$MarkLinkMembersTableAnnotationComposer,
      $$MarkLinkMembersTableCreateCompanionBuilder,
      $$MarkLinkMembersTableUpdateCompanionBuilder,
      (MarkLinkMember, $$MarkLinkMembersTableReferences),
      MarkLinkMember,
      PrefetchHooks Function({bool markLinkId, bool memberId})
    >;
typedef $$MarkLinkActionsTableCreateCompanionBuilder =
    MarkLinkActionsCompanion Function({
      required String markLinkId,
      required String actionId,
      Value<int> rowid,
    });
typedef $$MarkLinkActionsTableUpdateCompanionBuilder =
    MarkLinkActionsCompanion Function({
      Value<String> markLinkId,
      Value<String> actionId,
      Value<int> rowid,
    });

final class $$MarkLinkActionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MarkLinkActionsTable, MarkLinkAction> {
  $$MarkLinkActionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MarkLinksTable _markLinkIdTable(_$AppDatabase db) =>
      db.markLinks.createAlias(
        $_aliasNameGenerator(db.markLinkActions.markLinkId, db.markLinks.id),
      );

  $$MarkLinksTableProcessedTableManager get markLinkId {
    final $_column = $_itemColumn<String>('mark_link_id')!;

    final manager = $$MarkLinksTableTableManager(
      $_db,
      $_db.markLinks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_markLinkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActionsTable _actionIdTable(_$AppDatabase db) =>
      db.actions.createAlias(
        $_aliasNameGenerator(db.markLinkActions.actionId, db.actions.id),
      );

  $$ActionsTableProcessedTableManager get actionId {
    final $_column = $_itemColumn<String>('action_id')!;

    final manager = $$ActionsTableTableManager(
      $_db,
      $_db.actions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MarkLinkActionsTableFilterComposer
    extends Composer<_$AppDatabase, $MarkLinkActionsTable> {
  $$MarkLinkActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableFilterComposer get markLinkId {
    final $$MarkLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableFilterComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActionsTableFilterComposer get actionId {
    final $$ActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableFilterComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarkLinkActionsTable> {
  $$MarkLinkActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableOrderingComposer get markLinkId {
    final $$MarkLinksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableOrderingComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActionsTableOrderingComposer get actionId {
    final $$ActionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableOrderingComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarkLinkActionsTable> {
  $$MarkLinkActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MarkLinksTableAnnotationComposer get markLinkId {
    final $$MarkLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markLinkId,
      referencedTable: $db.markLinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.markLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActionsTableAnnotationComposer get actionId {
    final $$ActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkLinkActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarkLinkActionsTable,
          MarkLinkAction,
          $$MarkLinkActionsTableFilterComposer,
          $$MarkLinkActionsTableOrderingComposer,
          $$MarkLinkActionsTableAnnotationComposer,
          $$MarkLinkActionsTableCreateCompanionBuilder,
          $$MarkLinkActionsTableUpdateCompanionBuilder,
          (MarkLinkAction, $$MarkLinkActionsTableReferences),
          MarkLinkAction,
          PrefetchHooks Function({bool markLinkId, bool actionId})
        > {
  $$MarkLinkActionsTableTableManager(
    _$AppDatabase db,
    $MarkLinkActionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarkLinkActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarkLinkActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarkLinkActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> markLinkId = const Value.absent(),
                Value<String> actionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarkLinkActionsCompanion(
                markLinkId: markLinkId,
                actionId: actionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String markLinkId,
                required String actionId,
                Value<int> rowid = const Value.absent(),
              }) => MarkLinkActionsCompanion.insert(
                markLinkId: markLinkId,
                actionId: actionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MarkLinkActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({markLinkId = false, actionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (markLinkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.markLinkId,
                                referencedTable:
                                    $$MarkLinkActionsTableReferences
                                        ._markLinkIdTable(db),
                                referencedColumn:
                                    $$MarkLinkActionsTableReferences
                                        ._markLinkIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (actionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.actionId,
                                referencedTable:
                                    $$MarkLinkActionsTableReferences
                                        ._actionIdTable(db),
                                referencedColumn:
                                    $$MarkLinkActionsTableReferences
                                        ._actionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MarkLinkActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarkLinkActionsTable,
      MarkLinkAction,
      $$MarkLinkActionsTableFilterComposer,
      $$MarkLinkActionsTableOrderingComposer,
      $$MarkLinkActionsTableAnnotationComposer,
      $$MarkLinkActionsTableCreateCompanionBuilder,
      $$MarkLinkActionsTableUpdateCompanionBuilder,
      (MarkLinkAction, $$MarkLinkActionsTableReferences),
      MarkLinkAction,
      PrefetchHooks Function({bool markLinkId, bool actionId})
    >;
typedef $$PaymentSplitMembersTableCreateCompanionBuilder =
    PaymentSplitMembersCompanion Function({
      required String paymentId,
      required String memberId,
      Value<int> rowid,
    });
typedef $$PaymentSplitMembersTableUpdateCompanionBuilder =
    PaymentSplitMembersCompanion Function({
      Value<String> paymentId,
      Value<String> memberId,
      Value<int> rowid,
    });

final class $$PaymentSplitMembersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentSplitMembersTable,
          PaymentSplitMember
        > {
  $$PaymentSplitMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias(
        $_aliasNameGenerator(db.paymentSplitMembers.paymentId, db.payments.id),
      );

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias(
        $_aliasNameGenerator(db.paymentSplitMembers.memberId, db.members.id),
      );

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentSplitMembersTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentSplitMembersTable> {
  $$PaymentSplitMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentSplitMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentSplitMembersTable> {
  $$PaymentSplitMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentSplitMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentSplitMembersTable> {
  $$PaymentSplitMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentSplitMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentSplitMembersTable,
          PaymentSplitMember,
          $$PaymentSplitMembersTableFilterComposer,
          $$PaymentSplitMembersTableOrderingComposer,
          $$PaymentSplitMembersTableAnnotationComposer,
          $$PaymentSplitMembersTableCreateCompanionBuilder,
          $$PaymentSplitMembersTableUpdateCompanionBuilder,
          (PaymentSplitMember, $$PaymentSplitMembersTableReferences),
          PaymentSplitMember,
          PrefetchHooks Function({bool paymentId, bool memberId})
        > {
  $$PaymentSplitMembersTableTableManager(
    _$AppDatabase db,
    $PaymentSplitMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentSplitMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentSplitMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PaymentSplitMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> paymentId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentSplitMembersCompanion(
                paymentId: paymentId,
                memberId: memberId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String paymentId,
                required String memberId,
                Value<int> rowid = const Value.absent(),
              }) => PaymentSplitMembersCompanion.insert(
                paymentId: paymentId,
                memberId: memberId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentSplitMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false, memberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (paymentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.paymentId,
                                referencedTable:
                                    $$PaymentSplitMembersTableReferences
                                        ._paymentIdTable(db),
                                referencedColumn:
                                    $$PaymentSplitMembersTableReferences
                                        ._paymentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (memberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memberId,
                                referencedTable:
                                    $$PaymentSplitMembersTableReferences
                                        ._memberIdTable(db),
                                referencedColumn:
                                    $$PaymentSplitMembersTableReferences
                                        ._memberIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentSplitMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentSplitMembersTable,
      PaymentSplitMember,
      $$PaymentSplitMembersTableFilterComposer,
      $$PaymentSplitMembersTableOrderingComposer,
      $$PaymentSplitMembersTableAnnotationComposer,
      $$PaymentSplitMembersTableCreateCompanionBuilder,
      $$PaymentSplitMembersTableUpdateCompanionBuilder,
      (PaymentSplitMember, $$PaymentSplitMembersTableReferences),
      PaymentSplitMember,
      PrefetchHooks Function({bool paymentId, bool memberId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db, _db.actions);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransportsTableTableManager get transports =>
      $$TransportsTableTableManager(_db, _db.transports);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MarkLinksTableTableManager get markLinks =>
      $$MarkLinksTableTableManager(_db, _db.markLinks);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$EventMembersTableTableManager get eventMembers =>
      $$EventMembersTableTableManager(_db, _db.eventMembers);
  $$EventTagsTableTableManager get eventTags =>
      $$EventTagsTableTableManager(_db, _db.eventTags);
  $$MarkLinkMembersTableTableManager get markLinkMembers =>
      $$MarkLinkMembersTableTableManager(_db, _db.markLinkMembers);
  $$MarkLinkActionsTableTableManager get markLinkActions =>
      $$MarkLinkActionsTableTableManager(_db, _db.markLinkActions);
  $$PaymentSplitMembersTableTableManager get paymentSplitMembers =>
      $$PaymentSplitMembersTableTableManager(_db, _db.paymentSplitMembers);
}
