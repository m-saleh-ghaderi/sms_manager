// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _smsIdMeta = const VerificationMeta('smsId');
  @override
  late final GeneratedColumn<int> smsId = GeneratedColumn<int>(
    'sms_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedAddressMeta = const VerificationMeta(
    'normalizedAddress',
  );
  @override
  late final GeneratedColumn<String> normalizedAddress =
      GeneratedColumn<String>(
        'normalized_address',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _simSlotMeta = const VerificationMeta(
    'simSlot',
  );
  @override
  late final GeneratedColumn<int> simSlot = GeneratedColumn<int>(
    'sim_slot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderTypeMeta = const VerificationMeta(
    'senderType',
  );
  @override
  late final GeneratedColumn<String> senderType = GeneratedColumn<String>(
    'sender_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('service'),
  );
  static const VerificationMeta _primaryCategoryMeta = const VerificationMeta(
    'primaryCategory',
  );
  @override
  late final GeneratedColumn<String> primaryCategory = GeneratedColumn<String>(
    'primary_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountRialMeta = const VerificationMeta(
    'amountRial',
  );
  @override
  late final GeneratedColumn<int> amountRial = GeneratedColumn<int>(
    'amount_rial',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<String> txType = GeneratedColumn<String>(
    'tx_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userOverrideMeta = const VerificationMeta(
    'userOverride',
  );
  @override
  late final GeneratedColumn<bool> userOverride = GeneratedColumn<bool>(
    'user_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    smsId,
    address,
    normalizedAddress,
    body,
    date,
    isRead,
    simSlot,
    senderType,
    primaryCategory,
    isStarred,
    isPinned,
    amountRial,
    txType,
    userOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_smsIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('normalized_address')) {
      context.handle(
        _normalizedAddressMeta,
        normalizedAddress.isAcceptableOrUnknown(
          data['normalized_address']!,
          _normalizedAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedAddressMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('sim_slot')) {
      context.handle(
        _simSlotMeta,
        simSlot.isAcceptableOrUnknown(data['sim_slot']!, _simSlotMeta),
      );
    }
    if (data.containsKey('sender_type')) {
      context.handle(
        _senderTypeMeta,
        senderType.isAcceptableOrUnknown(data['sender_type']!, _senderTypeMeta),
      );
    }
    if (data.containsKey('primary_category')) {
      context.handle(
        _primaryCategoryMeta,
        primaryCategory.isAcceptableOrUnknown(
          data['primary_category']!,
          _primaryCategoryMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('amount_rial')) {
      context.handle(
        _amountRialMeta,
        amountRial.isAcceptableOrUnknown(data['amount_rial']!, _amountRialMeta),
      );
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    }
    if (data.containsKey('user_override')) {
      context.handle(
        _userOverrideMeta,
        userOverride.isAcceptableOrUnknown(
          data['user_override']!,
          _userOverrideMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sms_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      normalizedAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_address'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      simSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sim_slot'],
      ),
      senderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_type'],
      )!,
      primaryCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_category'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      amountRial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_rial'],
      ),
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_type'],
      ),
      userOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_override'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;

  /// Unique `_id` from the Android SMS provider.
  final int smsId;

  /// Raw sender address or phone number.
  final String address;

  /// Normalized phone number or alphanumeric service identifier.
  final String normalizedAddress;

  /// Full SMS text content.
  final String body;

  /// Timestamp when the message was received.
  final DateTime date;

  /// Whether the message has been read.
  final bool isRead;

  /// Dual-SIM slot index (`1`, `2`, or `null`).
  final int? simSlot;

  /// Sender classification (`contact`, `personal`, or `service`).
  final String senderType;

  /// Primary category identifier (e.g. `bank`, `otp`, `unknown`).
  final String primaryCategory;

  /// User-marked star flag.
  final bool isStarred;

  /// User-marked pin flag.
  final bool isPinned;

  /// Parsed financial transaction amount in Rials (nullable).
  final int? amountRial;

  /// Parsed transaction type (`credit` or `debit`, nullable).
  final String? txType;

  /// Whether the user manually overrode [primaryCategory].
  final bool userOverride;
  const Message({
    required this.id,
    required this.smsId,
    required this.address,
    required this.normalizedAddress,
    required this.body,
    required this.date,
    required this.isRead,
    this.simSlot,
    required this.senderType,
    required this.primaryCategory,
    required this.isStarred,
    required this.isPinned,
    this.amountRial,
    this.txType,
    required this.userOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sms_id'] = Variable<int>(smsId);
    map['address'] = Variable<String>(address);
    map['normalized_address'] = Variable<String>(normalizedAddress);
    map['body'] = Variable<String>(body);
    map['date'] = Variable<DateTime>(date);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || simSlot != null) {
      map['sim_slot'] = Variable<int>(simSlot);
    }
    map['sender_type'] = Variable<String>(senderType);
    map['primary_category'] = Variable<String>(primaryCategory);
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || amountRial != null) {
      map['amount_rial'] = Variable<int>(amountRial);
    }
    if (!nullToAbsent || txType != null) {
      map['tx_type'] = Variable<String>(txType);
    }
    map['user_override'] = Variable<bool>(userOverride);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      smsId: Value(smsId),
      address: Value(address),
      normalizedAddress: Value(normalizedAddress),
      body: Value(body),
      date: Value(date),
      isRead: Value(isRead),
      simSlot: simSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(simSlot),
      senderType: Value(senderType),
      primaryCategory: Value(primaryCategory),
      isStarred: Value(isStarred),
      isPinned: Value(isPinned),
      amountRial: amountRial == null && nullToAbsent
          ? const Value.absent()
          : Value(amountRial),
      txType: txType == null && nullToAbsent
          ? const Value.absent()
          : Value(txType),
      userOverride: Value(userOverride),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      smsId: serializer.fromJson<int>(json['smsId']),
      address: serializer.fromJson<String>(json['address']),
      normalizedAddress: serializer.fromJson<String>(json['normalizedAddress']),
      body: serializer.fromJson<String>(json['body']),
      date: serializer.fromJson<DateTime>(json['date']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      simSlot: serializer.fromJson<int?>(json['simSlot']),
      senderType: serializer.fromJson<String>(json['senderType']),
      primaryCategory: serializer.fromJson<String>(json['primaryCategory']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      amountRial: serializer.fromJson<int?>(json['amountRial']),
      txType: serializer.fromJson<String?>(json['txType']),
      userOverride: serializer.fromJson<bool>(json['userOverride']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'smsId': serializer.toJson<int>(smsId),
      'address': serializer.toJson<String>(address),
      'normalizedAddress': serializer.toJson<String>(normalizedAddress),
      'body': serializer.toJson<String>(body),
      'date': serializer.toJson<DateTime>(date),
      'isRead': serializer.toJson<bool>(isRead),
      'simSlot': serializer.toJson<int?>(simSlot),
      'senderType': serializer.toJson<String>(senderType),
      'primaryCategory': serializer.toJson<String>(primaryCategory),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isPinned': serializer.toJson<bool>(isPinned),
      'amountRial': serializer.toJson<int?>(amountRial),
      'txType': serializer.toJson<String?>(txType),
      'userOverride': serializer.toJson<bool>(userOverride),
    };
  }

  Message copyWith({
    int? id,
    int? smsId,
    String? address,
    String? normalizedAddress,
    String? body,
    DateTime? date,
    bool? isRead,
    Value<int?> simSlot = const Value.absent(),
    String? senderType,
    String? primaryCategory,
    bool? isStarred,
    bool? isPinned,
    Value<int?> amountRial = const Value.absent(),
    Value<String?> txType = const Value.absent(),
    bool? userOverride,
  }) => Message(
    id: id ?? this.id,
    smsId: smsId ?? this.smsId,
    address: address ?? this.address,
    normalizedAddress: normalizedAddress ?? this.normalizedAddress,
    body: body ?? this.body,
    date: date ?? this.date,
    isRead: isRead ?? this.isRead,
    simSlot: simSlot.present ? simSlot.value : this.simSlot,
    senderType: senderType ?? this.senderType,
    primaryCategory: primaryCategory ?? this.primaryCategory,
    isStarred: isStarred ?? this.isStarred,
    isPinned: isPinned ?? this.isPinned,
    amountRial: amountRial.present ? amountRial.value : this.amountRial,
    txType: txType.present ? txType.value : this.txType,
    userOverride: userOverride ?? this.userOverride,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
      address: data.address.present ? data.address.value : this.address,
      normalizedAddress: data.normalizedAddress.present
          ? data.normalizedAddress.value
          : this.normalizedAddress,
      body: data.body.present ? data.body.value : this.body,
      date: data.date.present ? data.date.value : this.date,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      simSlot: data.simSlot.present ? data.simSlot.value : this.simSlot,
      senderType: data.senderType.present
          ? data.senderType.value
          : this.senderType,
      primaryCategory: data.primaryCategory.present
          ? data.primaryCategory.value
          : this.primaryCategory,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      amountRial: data.amountRial.present
          ? data.amountRial.value
          : this.amountRial,
      txType: data.txType.present ? data.txType.value : this.txType,
      userOverride: data.userOverride.present
          ? data.userOverride.value
          : this.userOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('smsId: $smsId, ')
          ..write('address: $address, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('isRead: $isRead, ')
          ..write('simSlot: $simSlot, ')
          ..write('senderType: $senderType, ')
          ..write('primaryCategory: $primaryCategory, ')
          ..write('isStarred: $isStarred, ')
          ..write('isPinned: $isPinned, ')
          ..write('amountRial: $amountRial, ')
          ..write('txType: $txType, ')
          ..write('userOverride: $userOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    smsId,
    address,
    normalizedAddress,
    body,
    date,
    isRead,
    simSlot,
    senderType,
    primaryCategory,
    isStarred,
    isPinned,
    amountRial,
    txType,
    userOverride,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.smsId == this.smsId &&
          other.address == this.address &&
          other.normalizedAddress == this.normalizedAddress &&
          other.body == this.body &&
          other.date == this.date &&
          other.isRead == this.isRead &&
          other.simSlot == this.simSlot &&
          other.senderType == this.senderType &&
          other.primaryCategory == this.primaryCategory &&
          other.isStarred == this.isStarred &&
          other.isPinned == this.isPinned &&
          other.amountRial == this.amountRial &&
          other.txType == this.txType &&
          other.userOverride == this.userOverride);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> smsId;
  final Value<String> address;
  final Value<String> normalizedAddress;
  final Value<String> body;
  final Value<DateTime> date;
  final Value<bool> isRead;
  final Value<int?> simSlot;
  final Value<String> senderType;
  final Value<String> primaryCategory;
  final Value<bool> isStarred;
  final Value<bool> isPinned;
  final Value<int?> amountRial;
  final Value<String?> txType;
  final Value<bool> userOverride;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.smsId = const Value.absent(),
    this.address = const Value.absent(),
    this.normalizedAddress = const Value.absent(),
    this.body = const Value.absent(),
    this.date = const Value.absent(),
    this.isRead = const Value.absent(),
    this.simSlot = const Value.absent(),
    this.senderType = const Value.absent(),
    this.primaryCategory = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.amountRial = const Value.absent(),
    this.txType = const Value.absent(),
    this.userOverride = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int smsId,
    required String address,
    required String normalizedAddress,
    required String body,
    required DateTime date,
    this.isRead = const Value.absent(),
    this.simSlot = const Value.absent(),
    this.senderType = const Value.absent(),
    this.primaryCategory = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.amountRial = const Value.absent(),
    this.txType = const Value.absent(),
    this.userOverride = const Value.absent(),
  }) : smsId = Value(smsId),
       address = Value(address),
       normalizedAddress = Value(normalizedAddress),
       body = Value(body),
       date = Value(date);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? smsId,
    Expression<String>? address,
    Expression<String>? normalizedAddress,
    Expression<String>? body,
    Expression<DateTime>? date,
    Expression<bool>? isRead,
    Expression<int>? simSlot,
    Expression<String>? senderType,
    Expression<String>? primaryCategory,
    Expression<bool>? isStarred,
    Expression<bool>? isPinned,
    Expression<int>? amountRial,
    Expression<String>? txType,
    Expression<bool>? userOverride,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (smsId != null) 'sms_id': smsId,
      if (address != null) 'address': address,
      if (normalizedAddress != null) 'normalized_address': normalizedAddress,
      if (body != null) 'body': body,
      if (date != null) 'date': date,
      if (isRead != null) 'is_read': isRead,
      if (simSlot != null) 'sim_slot': simSlot,
      if (senderType != null) 'sender_type': senderType,
      if (primaryCategory != null) 'primary_category': primaryCategory,
      if (isStarred != null) 'is_starred': isStarred,
      if (isPinned != null) 'is_pinned': isPinned,
      if (amountRial != null) 'amount_rial': amountRial,
      if (txType != null) 'tx_type': txType,
      if (userOverride != null) 'user_override': userOverride,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? smsId,
    Value<String>? address,
    Value<String>? normalizedAddress,
    Value<String>? body,
    Value<DateTime>? date,
    Value<bool>? isRead,
    Value<int?>? simSlot,
    Value<String>? senderType,
    Value<String>? primaryCategory,
    Value<bool>? isStarred,
    Value<bool>? isPinned,
    Value<int?>? amountRial,
    Value<String?>? txType,
    Value<bool>? userOverride,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      smsId: smsId ?? this.smsId,
      address: address ?? this.address,
      normalizedAddress: normalizedAddress ?? this.normalizedAddress,
      body: body ?? this.body,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      simSlot: simSlot ?? this.simSlot,
      senderType: senderType ?? this.senderType,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      amountRial: amountRial ?? this.amountRial,
      txType: txType ?? this.txType,
      userOverride: userOverride ?? this.userOverride,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (smsId.present) {
      map['sms_id'] = Variable<int>(smsId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (normalizedAddress.present) {
      map['normalized_address'] = Variable<String>(normalizedAddress.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (simSlot.present) {
      map['sim_slot'] = Variable<int>(simSlot.value);
    }
    if (senderType.present) {
      map['sender_type'] = Variable<String>(senderType.value);
    }
    if (primaryCategory.present) {
      map['primary_category'] = Variable<String>(primaryCategory.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (amountRial.present) {
      map['amount_rial'] = Variable<int>(amountRial.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<String>(txType.value);
    }
    if (userOverride.present) {
      map['user_override'] = Variable<bool>(userOverride.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('smsId: $smsId, ')
          ..write('address: $address, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('isRead: $isRead, ')
          ..write('simSlot: $simSlot, ')
          ..write('senderType: $senderType, ')
          ..write('primaryCategory: $primaryCategory, ')
          ..write('isStarred: $isStarred, ')
          ..write('isPinned: $isPinned, ')
          ..write('amountRial: $amountRial, ')
          ..write('txType: $txType, ')
          ..write('userOverride: $userOverride')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final Index idxMessagesCategory = Index(
    'idx_messages_category',
    'CREATE INDEX idx_messages_category ON messages (primary_category)',
  );
  late final Index idxMessagesDate = Index(
    'idx_messages_date',
    'CREATE INDEX idx_messages_date ON messages (date)',
  );
  late final Index idxMessagesSimSlot = Index(
    'idx_messages_sim_slot',
    'CREATE INDEX idx_messages_sim_slot ON messages (sim_slot)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    idxMessagesCategory,
    idxMessagesDate,
    idxMessagesSimSlot,
  ];
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int smsId,
      required String address,
      required String normalizedAddress,
      required String body,
      required DateTime date,
      Value<bool> isRead,
      Value<int?> simSlot,
      Value<String> senderType,
      Value<String> primaryCategory,
      Value<bool> isStarred,
      Value<bool> isPinned,
      Value<int?> amountRial,
      Value<String?> txType,
      Value<bool> userOverride,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> smsId,
      Value<String> address,
      Value<String> normalizedAddress,
      Value<String> body,
      Value<DateTime> date,
      Value<bool> isRead,
      Value<int?> simSlot,
      Value<String> senderType,
      Value<String> primaryCategory,
      Value<bool> isStarred,
      Value<bool> isPinned,
      Value<int?> amountRial,
      Value<String?> txType,
      Value<bool> userOverride,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get simSlot => $composableBuilder(
    column: $table.simSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderType => $composableBuilder(
    column: $table.senderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userOverride => $composableBuilder(
    column: $table.userOverride,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get simSlot => $composableBuilder(
    column: $table.simSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderType => $composableBuilder(
    column: $table.senderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userOverride => $composableBuilder(
    column: $table.userOverride,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get simSlot =>
      $composableBuilder(column: $table.simSlot, builder: (column) => column);

  GeneratedColumn<String> get senderType => $composableBuilder(
    column: $table.senderType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<bool> get userOverride => $composableBuilder(
    column: $table.userOverride,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> smsId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> normalizedAddress = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int?> simSlot = const Value.absent(),
                Value<String> senderType = const Value.absent(),
                Value<String> primaryCategory = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int?> amountRial = const Value.absent(),
                Value<String?> txType = const Value.absent(),
                Value<bool> userOverride = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                smsId: smsId,
                address: address,
                normalizedAddress: normalizedAddress,
                body: body,
                date: date,
                isRead: isRead,
                simSlot: simSlot,
                senderType: senderType,
                primaryCategory: primaryCategory,
                isStarred: isStarred,
                isPinned: isPinned,
                amountRial: amountRial,
                txType: txType,
                userOverride: userOverride,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int smsId,
                required String address,
                required String normalizedAddress,
                required String body,
                required DateTime date,
                Value<bool> isRead = const Value.absent(),
                Value<int?> simSlot = const Value.absent(),
                Value<String> senderType = const Value.absent(),
                Value<String> primaryCategory = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int?> amountRial = const Value.absent(),
                Value<String?> txType = const Value.absent(),
                Value<bool> userOverride = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                smsId: smsId,
                address: address,
                normalizedAddress: normalizedAddress,
                body: body,
                date: date,
                isRead: isRead,
                simSlot: simSlot,
                senderType: senderType,
                primaryCategory: primaryCategory,
                isStarred: isStarred,
                isPinned: isPinned,
                amountRial: amountRial,
                txType: txType,
                userOverride: userOverride,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, Message>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, Message>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
