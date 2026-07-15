// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SearchProfilesTable extends SearchProfiles
    with TableInfo<$SearchProfilesTable, SearchProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationInseeMeta = const VerificationMeta(
    'locationInsee',
  );
  @override
  late final GeneratedColumn<String> locationInsee = GeneratedColumn<String>(
    'location_insee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationLabelMeta = const VerificationMeta(
    'locationLabel',
  );
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
    'location_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _romeCodesMeta = const VerificationMeta(
    'romeCodes',
  );
  @override
  late final GeneratedColumn<String> romeCodes = GeneratedColumn<String>(
    'rome_codes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radiusKmMeta = const VerificationMeta(
    'radiusKm',
  );
  @override
  late final GeneratedColumn<int> radiusKm = GeneratedColumn<int>(
    'radius_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contractTypesMeta = const VerificationMeta(
    'contractTypes',
  );
  @override
  late final GeneratedColumn<String> contractTypes = GeneratedColumn<String>(
    'contract_types',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seniorityMeta = const VerificationMeta(
    'seniority',
  );
  @override
  late final GeneratedColumn<String> seniority = GeneratedColumn<String>(
    'seniority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mustHaveMeta = const VerificationMeta(
    'mustHave',
  );
  @override
  late final GeneratedColumn<String> mustHave = GeneratedColumn<String>(
    'must_have',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exclusionsMeta = const VerificationMeta(
    'exclusions',
  );
  @override
  late final GeneratedColumn<String> exclusions = GeneratedColumn<String>(
    'exclusions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreThresholdMeta = const VerificationMeta(
    'scoreThreshold',
  );
  @override
  late final GeneratedColumn<int> scoreThreshold = GeneratedColumn<int>(
    'score_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    keywords,
    locationInsee,
    locationLabel,
    latitude,
    longitude,
    romeCodes,
    radiusKm,
    contractTypes,
    seniority,
    mustHave,
    exclusions,
    scoreThreshold,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordsMeta);
    }
    if (data.containsKey('location_insee')) {
      context.handle(
        _locationInseeMeta,
        locationInsee.isAcceptableOrUnknown(
          data['location_insee']!,
          _locationInseeMeta,
        ),
      );
    }
    if (data.containsKey('location_label')) {
      context.handle(
        _locationLabelMeta,
        locationLabel.isAcceptableOrUnknown(
          data['location_label']!,
          _locationLabelMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('rome_codes')) {
      context.handle(
        _romeCodesMeta,
        romeCodes.isAcceptableOrUnknown(data['rome_codes']!, _romeCodesMeta),
      );
    }
    if (data.containsKey('radius_km')) {
      context.handle(
        _radiusKmMeta,
        radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta),
      );
    }
    if (data.containsKey('contract_types')) {
      context.handle(
        _contractTypesMeta,
        contractTypes.isAcceptableOrUnknown(
          data['contract_types']!,
          _contractTypesMeta,
        ),
      );
    }
    if (data.containsKey('seniority')) {
      context.handle(
        _seniorityMeta,
        seniority.isAcceptableOrUnknown(data['seniority']!, _seniorityMeta),
      );
    }
    if (data.containsKey('must_have')) {
      context.handle(
        _mustHaveMeta,
        mustHave.isAcceptableOrUnknown(data['must_have']!, _mustHaveMeta),
      );
    }
    if (data.containsKey('exclusions')) {
      context.handle(
        _exclusionsMeta,
        exclusions.isAcceptableOrUnknown(data['exclusions']!, _exclusionsMeta),
      );
    }
    if (data.containsKey('score_threshold')) {
      context.handle(
        _scoreThresholdMeta,
        scoreThreshold.isAcceptableOrUnknown(
          data['score_threshold']!,
          _scoreThresholdMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      )!,
      locationInsee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_insee'],
      ),
      locationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_label'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      romeCodes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rome_codes'],
      ),
      radiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}radius_km'],
      ),
      contractTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_types'],
      ),
      seniority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seniority'],
      ),
      mustHave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}must_have'],
      ),
      exclusions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclusions'],
      ),
      scoreThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_threshold'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SearchProfilesTable createAlias(String alias) {
    return $SearchProfilesTable(attachedDatabase, alias);
  }
}

class SearchProfile extends DataClass implements Insertable<SearchProfile> {
  final int id;
  final String name;
  final String keywords;
  final String? locationInsee;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final String? romeCodes;
  final int? radiusKm;
  final String? contractTypes;
  final String? seniority;
  final String? mustHave;
  final String? exclusions;
  final int scoreThreshold;
  final bool active;
  final DateTime createdAt;
  const SearchProfile({
    required this.id,
    required this.name,
    required this.keywords,
    this.locationInsee,
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.romeCodes,
    this.radiusKm,
    this.contractTypes,
    this.seniority,
    this.mustHave,
    this.exclusions,
    required this.scoreThreshold,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['keywords'] = Variable<String>(keywords);
    if (!nullToAbsent || locationInsee != null) {
      map['location_insee'] = Variable<String>(locationInsee);
    }
    if (!nullToAbsent || locationLabel != null) {
      map['location_label'] = Variable<String>(locationLabel);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || romeCodes != null) {
      map['rome_codes'] = Variable<String>(romeCodes);
    }
    if (!nullToAbsent || radiusKm != null) {
      map['radius_km'] = Variable<int>(radiusKm);
    }
    if (!nullToAbsent || contractTypes != null) {
      map['contract_types'] = Variable<String>(contractTypes);
    }
    if (!nullToAbsent || seniority != null) {
      map['seniority'] = Variable<String>(seniority);
    }
    if (!nullToAbsent || mustHave != null) {
      map['must_have'] = Variable<String>(mustHave);
    }
    if (!nullToAbsent || exclusions != null) {
      map['exclusions'] = Variable<String>(exclusions);
    }
    map['score_threshold'] = Variable<int>(scoreThreshold);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SearchProfilesCompanion toCompanion(bool nullToAbsent) {
    return SearchProfilesCompanion(
      id: Value(id),
      name: Value(name),
      keywords: Value(keywords),
      locationInsee: locationInsee == null && nullToAbsent
          ? const Value.absent()
          : Value(locationInsee),
      locationLabel: locationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLabel),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      romeCodes: romeCodes == null && nullToAbsent
          ? const Value.absent()
          : Value(romeCodes),
      radiusKm: radiusKm == null && nullToAbsent
          ? const Value.absent()
          : Value(radiusKm),
      contractTypes: contractTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(contractTypes),
      seniority: seniority == null && nullToAbsent
          ? const Value.absent()
          : Value(seniority),
      mustHave: mustHave == null && nullToAbsent
          ? const Value.absent()
          : Value(mustHave),
      exclusions: exclusions == null && nullToAbsent
          ? const Value.absent()
          : Value(exclusions),
      scoreThreshold: Value(scoreThreshold),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory SearchProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      keywords: serializer.fromJson<String>(json['keywords']),
      locationInsee: serializer.fromJson<String?>(json['locationInsee']),
      locationLabel: serializer.fromJson<String?>(json['locationLabel']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      romeCodes: serializer.fromJson<String?>(json['romeCodes']),
      radiusKm: serializer.fromJson<int?>(json['radiusKm']),
      contractTypes: serializer.fromJson<String?>(json['contractTypes']),
      seniority: serializer.fromJson<String?>(json['seniority']),
      mustHave: serializer.fromJson<String?>(json['mustHave']),
      exclusions: serializer.fromJson<String?>(json['exclusions']),
      scoreThreshold: serializer.fromJson<int>(json['scoreThreshold']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'keywords': serializer.toJson<String>(keywords),
      'locationInsee': serializer.toJson<String?>(locationInsee),
      'locationLabel': serializer.toJson<String?>(locationLabel),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'romeCodes': serializer.toJson<String?>(romeCodes),
      'radiusKm': serializer.toJson<int?>(radiusKm),
      'contractTypes': serializer.toJson<String?>(contractTypes),
      'seniority': serializer.toJson<String?>(seniority),
      'mustHave': serializer.toJson<String?>(mustHave),
      'exclusions': serializer.toJson<String?>(exclusions),
      'scoreThreshold': serializer.toJson<int>(scoreThreshold),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SearchProfile copyWith({
    int? id,
    String? name,
    String? keywords,
    Value<String?> locationInsee = const Value.absent(),
    Value<String?> locationLabel = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> romeCodes = const Value.absent(),
    Value<int?> radiusKm = const Value.absent(),
    Value<String?> contractTypes = const Value.absent(),
    Value<String?> seniority = const Value.absent(),
    Value<String?> mustHave = const Value.absent(),
    Value<String?> exclusions = const Value.absent(),
    int? scoreThreshold,
    bool? active,
    DateTime? createdAt,
  }) => SearchProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    keywords: keywords ?? this.keywords,
    locationInsee: locationInsee.present
        ? locationInsee.value
        : this.locationInsee,
    locationLabel: locationLabel.present
        ? locationLabel.value
        : this.locationLabel,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    romeCodes: romeCodes.present ? romeCodes.value : this.romeCodes,
    radiusKm: radiusKm.present ? radiusKm.value : this.radiusKm,
    contractTypes: contractTypes.present
        ? contractTypes.value
        : this.contractTypes,
    seniority: seniority.present ? seniority.value : this.seniority,
    mustHave: mustHave.present ? mustHave.value : this.mustHave,
    exclusions: exclusions.present ? exclusions.value : this.exclusions,
    scoreThreshold: scoreThreshold ?? this.scoreThreshold,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  SearchProfile copyWithCompanion(SearchProfilesCompanion data) {
    return SearchProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      locationInsee: data.locationInsee.present
          ? data.locationInsee.value
          : this.locationInsee,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      romeCodes: data.romeCodes.present ? data.romeCodes.value : this.romeCodes,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
      contractTypes: data.contractTypes.present
          ? data.contractTypes.value
          : this.contractTypes,
      seniority: data.seniority.present ? data.seniority.value : this.seniority,
      mustHave: data.mustHave.present ? data.mustHave.value : this.mustHave,
      exclusions: data.exclusions.present
          ? data.exclusions.value
          : this.exclusions,
      scoreThreshold: data.scoreThreshold.present
          ? data.scoreThreshold.value
          : this.scoreThreshold,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('keywords: $keywords, ')
          ..write('locationInsee: $locationInsee, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('romeCodes: $romeCodes, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('contractTypes: $contractTypes, ')
          ..write('seniority: $seniority, ')
          ..write('mustHave: $mustHave, ')
          ..write('exclusions: $exclusions, ')
          ..write('scoreThreshold: $scoreThreshold, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    keywords,
    locationInsee,
    locationLabel,
    latitude,
    longitude,
    romeCodes,
    radiusKm,
    contractTypes,
    seniority,
    mustHave,
    exclusions,
    scoreThreshold,
    active,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.keywords == this.keywords &&
          other.locationInsee == this.locationInsee &&
          other.locationLabel == this.locationLabel &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.romeCodes == this.romeCodes &&
          other.radiusKm == this.radiusKm &&
          other.contractTypes == this.contractTypes &&
          other.seniority == this.seniority &&
          other.mustHave == this.mustHave &&
          other.exclusions == this.exclusions &&
          other.scoreThreshold == this.scoreThreshold &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class SearchProfilesCompanion extends UpdateCompanion<SearchProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> keywords;
  final Value<String?> locationInsee;
  final Value<String?> locationLabel;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> romeCodes;
  final Value<int?> radiusKm;
  final Value<String?> contractTypes;
  final Value<String?> seniority;
  final Value<String?> mustHave;
  final Value<String?> exclusions;
  final Value<int> scoreThreshold;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const SearchProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.keywords = const Value.absent(),
    this.locationInsee = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.romeCodes = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.contractTypes = const Value.absent(),
    this.seniority = const Value.absent(),
    this.mustHave = const Value.absent(),
    this.exclusions = const Value.absent(),
    this.scoreThreshold = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SearchProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String keywords,
    this.locationInsee = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.romeCodes = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.contractTypes = const Value.absent(),
    this.seniority = const Value.absent(),
    this.mustHave = const Value.absent(),
    this.exclusions = const Value.absent(),
    this.scoreThreshold = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       keywords = Value(keywords);
  static Insertable<SearchProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? keywords,
    Expression<String>? locationInsee,
    Expression<String>? locationLabel,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? romeCodes,
    Expression<int>? radiusKm,
    Expression<String>? contractTypes,
    Expression<String>? seniority,
    Expression<String>? mustHave,
    Expression<String>? exclusions,
    Expression<int>? scoreThreshold,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (keywords != null) 'keywords': keywords,
      if (locationInsee != null) 'location_insee': locationInsee,
      if (locationLabel != null) 'location_label': locationLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (romeCodes != null) 'rome_codes': romeCodes,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (contractTypes != null) 'contract_types': contractTypes,
      if (seniority != null) 'seniority': seniority,
      if (mustHave != null) 'must_have': mustHave,
      if (exclusions != null) 'exclusions': exclusions,
      if (scoreThreshold != null) 'score_threshold': scoreThreshold,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SearchProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? keywords,
    Value<String?>? locationInsee,
    Value<String?>? locationLabel,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? romeCodes,
    Value<int?>? radiusKm,
    Value<String?>? contractTypes,
    Value<String?>? seniority,
    Value<String?>? mustHave,
    Value<String?>? exclusions,
    Value<int>? scoreThreshold,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return SearchProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
      locationInsee: locationInsee ?? this.locationInsee,
      locationLabel: locationLabel ?? this.locationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      romeCodes: romeCodes ?? this.romeCodes,
      radiusKm: radiusKm ?? this.radiusKm,
      contractTypes: contractTypes ?? this.contractTypes,
      seniority: seniority ?? this.seniority,
      mustHave: mustHave ?? this.mustHave,
      exclusions: exclusions ?? this.exclusions,
      scoreThreshold: scoreThreshold ?? this.scoreThreshold,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (locationInsee.present) {
      map['location_insee'] = Variable<String>(locationInsee.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (romeCodes.present) {
      map['rome_codes'] = Variable<String>(romeCodes.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<int>(radiusKm.value);
    }
    if (contractTypes.present) {
      map['contract_types'] = Variable<String>(contractTypes.value);
    }
    if (seniority.present) {
      map['seniority'] = Variable<String>(seniority.value);
    }
    if (mustHave.present) {
      map['must_have'] = Variable<String>(mustHave.value);
    }
    if (exclusions.present) {
      map['exclusions'] = Variable<String>(exclusions.value);
    }
    if (scoreThreshold.present) {
      map['score_threshold'] = Variable<int>(scoreThreshold.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('keywords: $keywords, ')
          ..write('locationInsee: $locationInsee, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('romeCodes: $romeCodes, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('contractTypes: $contractTypes, ')
          ..write('seniority: $seniority, ')
          ..write('mustHave: $mustHave, ')
          ..write('exclusions: $exclusions, ')
          ..write('scoreThreshold: $scoreThreshold, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OffersTable extends Offers with TableInfo<$OffersTable, Offer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OffersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyCanonMeta = const VerificationMeta(
    'companyCanon',
  );
  @override
  late final GeneratedColumn<String> companyCanon = GeneratedColumn<String>(
    'company_canon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contractTypeMeta = const VerificationMeta(
    'contractType',
  );
  @override
  late final GeneratedColumn<String> contractType = GeneratedColumn<String>(
    'contract_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<String> salary = GeneratedColumn<String>(
    'salary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreReasonMeta = const VerificationMeta(
    'scoreReason',
  );
  @override
  late final GeneratedColumn<String> scoreReason = GeneratedColumn<String>(
    'score_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES search_profiles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(OfferStatus.newOffer),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    sourceId,
    hash,
    title,
    company,
    companyCanon,
    location,
    contractType,
    salary,
    description,
    url,
    score,
    scoreReason,
    profileId,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Offer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('company_canon')) {
      context.handle(
        _companyCanonMeta,
        companyCanon.isAcceptableOrUnknown(
          data['company_canon']!,
          _companyCanonMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('contract_type')) {
      context.handle(
        _contractTypeMeta,
        contractType.isAcceptableOrUnknown(
          data['contract_type']!,
          _contractTypeMeta,
        ),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('score_reason')) {
      context.handle(
        _scoreReasonMeta,
        scoreReason.isAcceptableOrUnknown(
          data['score_reason']!,
          _scoreReasonMeta,
        ),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Offer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Offer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      companyCanon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_canon'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      contractType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_type'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salary'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      scoreReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}score_reason'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OffersTable createAlias(String alias) {
    return $OffersTable(attachedDatabase, alias);
  }
}

class Offer extends DataClass implements Insertable<Offer> {
  final int id;

  /// `france_travail`, `lba`, ou `shared` (reçue par partage Android).
  final String source;
  final String? sourceId;
  final String hash;
  final String title;
  final String? company;
  final String? companyCanon;
  final String? location;
  final String? contractType;
  final String? salary;
  final String? description;
  final String? url;
  final int? score;
  final String? scoreReason;
  final int? profileId;
  final String status;
  final DateTime createdAt;
  const Offer({
    required this.id,
    required this.source,
    this.sourceId,
    required this.hash,
    required this.title,
    this.company,
    this.companyCanon,
    this.location,
    this.contractType,
    this.salary,
    this.description,
    this.url,
    this.score,
    this.scoreReason,
    this.profileId,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['hash'] = Variable<String>(hash);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || companyCanon != null) {
      map['company_canon'] = Variable<String>(companyCanon);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || contractType != null) {
      map['contract_type'] = Variable<String>(contractType);
    }
    if (!nullToAbsent || salary != null) {
      map['salary'] = Variable<String>(salary);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || scoreReason != null) {
      map['score_reason'] = Variable<String>(scoreReason);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OffersCompanion toCompanion(bool nullToAbsent) {
    return OffersCompanion(
      id: Value(id),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      hash: Value(hash),
      title: Value(title),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      companyCanon: companyCanon == null && nullToAbsent
          ? const Value.absent()
          : Value(companyCanon),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      contractType: contractType == null && nullToAbsent
          ? const Value.absent()
          : Value(contractType),
      salary: salary == null && nullToAbsent
          ? const Value.absent()
          : Value(salary),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      scoreReason: scoreReason == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreReason),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Offer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Offer(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      hash: serializer.fromJson<String>(json['hash']),
      title: serializer.fromJson<String>(json['title']),
      company: serializer.fromJson<String?>(json['company']),
      companyCanon: serializer.fromJson<String?>(json['companyCanon']),
      location: serializer.fromJson<String?>(json['location']),
      contractType: serializer.fromJson<String?>(json['contractType']),
      salary: serializer.fromJson<String?>(json['salary']),
      description: serializer.fromJson<String?>(json['description']),
      url: serializer.fromJson<String?>(json['url']),
      score: serializer.fromJson<int?>(json['score']),
      scoreReason: serializer.fromJson<String?>(json['scoreReason']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'hash': serializer.toJson<String>(hash),
      'title': serializer.toJson<String>(title),
      'company': serializer.toJson<String?>(company),
      'companyCanon': serializer.toJson<String?>(companyCanon),
      'location': serializer.toJson<String?>(location),
      'contractType': serializer.toJson<String?>(contractType),
      'salary': serializer.toJson<String?>(salary),
      'description': serializer.toJson<String?>(description),
      'url': serializer.toJson<String?>(url),
      'score': serializer.toJson<int?>(score),
      'scoreReason': serializer.toJson<String?>(scoreReason),
      'profileId': serializer.toJson<int?>(profileId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Offer copyWith({
    int? id,
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? hash,
    String? title,
    Value<String?> company = const Value.absent(),
    Value<String?> companyCanon = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> contractType = const Value.absent(),
    Value<String?> salary = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> score = const Value.absent(),
    Value<String?> scoreReason = const Value.absent(),
    Value<int?> profileId = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => Offer(
    id: id ?? this.id,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    hash: hash ?? this.hash,
    title: title ?? this.title,
    company: company.present ? company.value : this.company,
    companyCanon: companyCanon.present ? companyCanon.value : this.companyCanon,
    location: location.present ? location.value : this.location,
    contractType: contractType.present ? contractType.value : this.contractType,
    salary: salary.present ? salary.value : this.salary,
    description: description.present ? description.value : this.description,
    url: url.present ? url.value : this.url,
    score: score.present ? score.value : this.score,
    scoreReason: scoreReason.present ? scoreReason.value : this.scoreReason,
    profileId: profileId.present ? profileId.value : this.profileId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Offer copyWithCompanion(OffersCompanion data) {
    return Offer(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      hash: data.hash.present ? data.hash.value : this.hash,
      title: data.title.present ? data.title.value : this.title,
      company: data.company.present ? data.company.value : this.company,
      companyCanon: data.companyCanon.present
          ? data.companyCanon.value
          : this.companyCanon,
      location: data.location.present ? data.location.value : this.location,
      contractType: data.contractType.present
          ? data.contractType.value
          : this.contractType,
      salary: data.salary.present ? data.salary.value : this.salary,
      description: data.description.present
          ? data.description.value
          : this.description,
      url: data.url.present ? data.url.value : this.url,
      score: data.score.present ? data.score.value : this.score,
      scoreReason: data.scoreReason.present
          ? data.scoreReason.value
          : this.scoreReason,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Offer(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('hash: $hash, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('companyCanon: $companyCanon, ')
          ..write('location: $location, ')
          ..write('contractType: $contractType, ')
          ..write('salary: $salary, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('score: $score, ')
          ..write('scoreReason: $scoreReason, ')
          ..write('profileId: $profileId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    sourceId,
    hash,
    title,
    company,
    companyCanon,
    location,
    contractType,
    salary,
    description,
    url,
    score,
    scoreReason,
    profileId,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Offer &&
          other.id == this.id &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.hash == this.hash &&
          other.title == this.title &&
          other.company == this.company &&
          other.companyCanon == this.companyCanon &&
          other.location == this.location &&
          other.contractType == this.contractType &&
          other.salary == this.salary &&
          other.description == this.description &&
          other.url == this.url &&
          other.score == this.score &&
          other.scoreReason == this.scoreReason &&
          other.profileId == this.profileId &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OffersCompanion extends UpdateCompanion<Offer> {
  final Value<int> id;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> hash;
  final Value<String> title;
  final Value<String?> company;
  final Value<String?> companyCanon;
  final Value<String?> location;
  final Value<String?> contractType;
  final Value<String?> salary;
  final Value<String?> description;
  final Value<String?> url;
  final Value<int?> score;
  final Value<String?> scoreReason;
  final Value<int?> profileId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const OffersCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.hash = const Value.absent(),
    this.title = const Value.absent(),
    this.company = const Value.absent(),
    this.companyCanon = const Value.absent(),
    this.location = const Value.absent(),
    this.contractType = const Value.absent(),
    this.salary = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.score = const Value.absent(),
    this.scoreReason = const Value.absent(),
    this.profileId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OffersCompanion.insert({
    this.id = const Value.absent(),
    required String source,
    this.sourceId = const Value.absent(),
    required String hash,
    required String title,
    this.company = const Value.absent(),
    this.companyCanon = const Value.absent(),
    this.location = const Value.absent(),
    this.contractType = const Value.absent(),
    this.salary = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.score = const Value.absent(),
    this.scoreReason = const Value.absent(),
    this.profileId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : source = Value(source),
       hash = Value(hash),
       title = Value(title);
  static Insertable<Offer> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? hash,
    Expression<String>? title,
    Expression<String>? company,
    Expression<String>? companyCanon,
    Expression<String>? location,
    Expression<String>? contractType,
    Expression<String>? salary,
    Expression<String>? description,
    Expression<String>? url,
    Expression<int>? score,
    Expression<String>? scoreReason,
    Expression<int>? profileId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (hash != null) 'hash': hash,
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (companyCanon != null) 'company_canon': companyCanon,
      if (location != null) 'location': location,
      if (contractType != null) 'contract_type': contractType,
      if (salary != null) 'salary': salary,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (score != null) 'score': score,
      if (scoreReason != null) 'score_reason': scoreReason,
      if (profileId != null) 'profile_id': profileId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OffersCompanion copyWith({
    Value<int>? id,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? hash,
    Value<String>? title,
    Value<String?>? company,
    Value<String?>? companyCanon,
    Value<String?>? location,
    Value<String?>? contractType,
    Value<String?>? salary,
    Value<String?>? description,
    Value<String?>? url,
    Value<int?>? score,
    Value<String?>? scoreReason,
    Value<int?>? profileId,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return OffersCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      hash: hash ?? this.hash,
      title: title ?? this.title,
      company: company ?? this.company,
      companyCanon: companyCanon ?? this.companyCanon,
      location: location ?? this.location,
      contractType: contractType ?? this.contractType,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      url: url ?? this.url,
      score: score ?? this.score,
      scoreReason: scoreReason ?? this.scoreReason,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (companyCanon.present) {
      map['company_canon'] = Variable<String>(companyCanon.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (contractType.present) {
      map['contract_type'] = Variable<String>(contractType.value);
    }
    if (salary.present) {
      map['salary'] = Variable<String>(salary.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (scoreReason.present) {
      map['score_reason'] = Variable<String>(scoreReason.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OffersCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('hash: $hash, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('companyCanon: $companyCanon, ')
          ..write('location: $location, ')
          ..write('contractType: $contractType, ')
          ..write('salary: $salary, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('score: $score, ')
          ..write('scoreReason: $scoreReason, ')
          ..write('profileId: $profileId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiSummaryMeta = const VerificationMeta(
    'aiSummary',
  );
  @override
  late final GeneratedColumn<String> aiSummary = GeneratedColumn<String>(
    'ai_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _applyUrlMeta = const VerificationMeta(
    'applyUrl',
  );
  @override
  late final GeneratedColumn<String> applyUrl = GeneratedColumn<String>(
    'apply_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    website,
    sector,
    description,
    aiSummary,
    applyUrl,
    phone,
    email,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ai_summary')) {
      context.handle(
        _aiSummaryMeta,
        aiSummary.isAcceptableOrUnknown(data['ai_summary']!, _aiSummaryMeta),
      );
    }
    if (data.containsKey('apply_url')) {
      context.handle(
        _applyUrlMeta,
        applyUrl.isAcceptableOrUnknown(data['apply_url']!, _applyUrlMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      aiSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_summary'],
      ),
      applyUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apply_url'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final int id;
  final String name;
  final String? website;
  final String? sector;
  final String? description;

  /// Résumé produit par l'agent, toujours fondé sur une source réelle.
  final String? aiSummary;
  final String? applyUrl;
  final String? phone;
  final String? email;
  final DateTime lastUpdated;
  const Company({
    required this.id,
    required this.name,
    this.website,
    this.sector,
    this.description,
    this.aiSummary,
    this.applyUrl,
    this.phone,
    this.email,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || aiSummary != null) {
      map['ai_summary'] = Variable<String>(aiSummary);
    }
    if (!nullToAbsent || applyUrl != null) {
      map['apply_url'] = Variable<String>(applyUrl);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      aiSummary: aiSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(aiSummary),
      applyUrl: applyUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(applyUrl),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      website: serializer.fromJson<String?>(json['website']),
      sector: serializer.fromJson<String?>(json['sector']),
      description: serializer.fromJson<String?>(json['description']),
      aiSummary: serializer.fromJson<String?>(json['aiSummary']),
      applyUrl: serializer.fromJson<String?>(json['applyUrl']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'website': serializer.toJson<String?>(website),
      'sector': serializer.toJson<String?>(sector),
      'description': serializer.toJson<String?>(description),
      'aiSummary': serializer.toJson<String?>(aiSummary),
      'applyUrl': serializer.toJson<String?>(applyUrl),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    Value<String?> website = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> aiSummary = const Value.absent(),
    Value<String?> applyUrl = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    DateTime? lastUpdated,
  }) => Company(
    id: id ?? this.id,
    name: name ?? this.name,
    website: website.present ? website.value : this.website,
    sector: sector.present ? sector.value : this.sector,
    description: description.present ? description.value : this.description,
    aiSummary: aiSummary.present ? aiSummary.value : this.aiSummary,
    applyUrl: applyUrl.present ? applyUrl.value : this.applyUrl,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      website: data.website.present ? data.website.value : this.website,
      sector: data.sector.present ? data.sector.value : this.sector,
      description: data.description.present
          ? data.description.value
          : this.description,
      aiSummary: data.aiSummary.present ? data.aiSummary.value : this.aiSummary,
      applyUrl: data.applyUrl.present ? data.applyUrl.value : this.applyUrl,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('website: $website, ')
          ..write('sector: $sector, ')
          ..write('description: $description, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('applyUrl: $applyUrl, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    website,
    sector,
    description,
    aiSummary,
    applyUrl,
    phone,
    email,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.name == this.name &&
          other.website == this.website &&
          other.sector == this.sector &&
          other.description == this.description &&
          other.aiSummary == this.aiSummary &&
          other.applyUrl == this.applyUrl &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.lastUpdated == this.lastUpdated);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> website;
  final Value<String?> sector;
  final Value<String?> description;
  final Value<String?> aiSummary;
  final Value<String?> applyUrl;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<DateTime> lastUpdated;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.website = const Value.absent(),
    this.sector = const Value.absent(),
    this.description = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.applyUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  CompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.website = const Value.absent(),
    this.sector = const Value.absent(),
    this.description = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.applyUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Company> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? website,
    Expression<String>? sector,
    Expression<String>? description,
    Expression<String>? aiSummary,
    Expression<String>? applyUrl,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (website != null) 'website': website,
      if (sector != null) 'sector': sector,
      if (description != null) 'description': description,
      if (aiSummary != null) 'ai_summary': aiSummary,
      if (applyUrl != null) 'apply_url': applyUrl,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  CompaniesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? website,
    Value<String?>? sector,
    Value<String?>? description,
    Value<String?>? aiSummary,
    Value<String?>? applyUrl,
    Value<String?>? phone,
    Value<String?>? email,
    Value<DateTime>? lastUpdated,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      website: website ?? this.website,
      sector: sector ?? this.sector,
      description: description ?? this.description,
      aiSummary: aiSummary ?? this.aiSummary,
      applyUrl: applyUrl ?? this.applyUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (aiSummary.present) {
      map['ai_summary'] = Variable<String>(aiSummary.value);
    }
    if (applyUrl.present) {
      map['apply_url'] = Variable<String>(applyUrl.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('website: $website, ')
          ..write('sector: $sector, ')
          ..write('description: $description, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('applyUrl: $applyUrl, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $ApplicationsTable extends Applications
    with TableInfo<$ApplicationsTable, Application> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplicationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _offerIdMeta = const VerificationMeta(
    'offerId',
  );
  @override
  late final GeneratedColumn<int> offerId = GeneratedColumn<int>(
    'offer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES offers (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(ApplicationKind.offer),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(ApplicationStatus.draft),
  );
  static const VerificationMeta _posteMeta = const VerificationMeta('poste');
  @override
  late final GeneratedColumn<String> poste = GeneratedColumn<String>(
    'poste',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entrepriseMeta = const VerificationMeta(
    'entreprise',
  );
  @override
  late final GeneratedColumn<String> entreprise = GeneratedColumn<String>(
    'entreprise',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lienMeta = const VerificationMeta('lien');
  @override
  late final GeneratedColumn<String> lien = GeneratedColumn<String>(
    'lien',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseAtMeta = const VerificationMeta(
    'responseAt',
  );
  @override
  late final GeneratedColumn<DateTime> responseAt = GeneratedColumn<DateTime>(
    'response_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindedAtMeta = const VerificationMeta(
    'remindedAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindedAt = GeneratedColumn<DateTime>(
    'reminded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    offerId,
    companyId,
    kind,
    status,
    poste,
    entreprise,
    lien,
    score,
    appliedAt,
    responseAt,
    remindedAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Application> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('offer_id')) {
      context.handle(
        _offerIdMeta,
        offerId.isAcceptableOrUnknown(data['offer_id']!, _offerIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('poste')) {
      context.handle(
        _posteMeta,
        poste.isAcceptableOrUnknown(data['poste']!, _posteMeta),
      );
    }
    if (data.containsKey('entreprise')) {
      context.handle(
        _entrepriseMeta,
        entreprise.isAcceptableOrUnknown(data['entreprise']!, _entrepriseMeta),
      );
    }
    if (data.containsKey('lien')) {
      context.handle(
        _lienMeta,
        lien.isAcceptableOrUnknown(data['lien']!, _lienMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    if (data.containsKey('response_at')) {
      context.handle(
        _responseAtMeta,
        responseAt.isAcceptableOrUnknown(data['response_at']!, _responseAtMeta),
      );
    }
    if (data.containsKey('reminded_at')) {
      context.handle(
        _remindedAtMeta,
        remindedAt.isAcceptableOrUnknown(data['reminded_at']!, _remindedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Application map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Application(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      offerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offer_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      poste: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poste'],
      ),
      entreprise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entreprise'],
      ),
      lien: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lien'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
      responseAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}response_at'],
      ),
      remindedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminded_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ApplicationsTable createAlias(String alias) {
    return $ApplicationsTable(attachedDatabase, alias);
  }
}

class Application extends DataClass implements Insertable<Application> {
  final int id;
  final int? offerId;
  final int? companyId;
  final String kind;
  final String status;

  /// Copies figées au moment de la candidature : l'offre peut disparaître, la
  /// trace du suivi doit rester lisible.
  final String? poste;
  final String? entreprise;
  final String? lien;
  final int? score;
  final DateTime? appliedAt;
  final DateTime? responseAt;
  final DateTime? remindedAt;
  final String? notes;
  final DateTime createdAt;
  const Application({
    required this.id,
    this.offerId,
    this.companyId,
    required this.kind,
    required this.status,
    this.poste,
    this.entreprise,
    this.lien,
    this.score,
    this.appliedAt,
    this.responseAt,
    this.remindedAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || offerId != null) {
      map['offer_id'] = Variable<int>(offerId);
    }
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<int>(companyId);
    }
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || poste != null) {
      map['poste'] = Variable<String>(poste);
    }
    if (!nullToAbsent || entreprise != null) {
      map['entreprise'] = Variable<String>(entreprise);
    }
    if (!nullToAbsent || lien != null) {
      map['lien'] = Variable<String>(lien);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    if (!nullToAbsent || responseAt != null) {
      map['response_at'] = Variable<DateTime>(responseAt);
    }
    if (!nullToAbsent || remindedAt != null) {
      map['reminded_at'] = Variable<DateTime>(remindedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ApplicationsCompanion toCompanion(bool nullToAbsent) {
    return ApplicationsCompanion(
      id: Value(id),
      offerId: offerId == null && nullToAbsent
          ? const Value.absent()
          : Value(offerId),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      kind: Value(kind),
      status: Value(status),
      poste: poste == null && nullToAbsent
          ? const Value.absent()
          : Value(poste),
      entreprise: entreprise == null && nullToAbsent
          ? const Value.absent()
          : Value(entreprise),
      lien: lien == null && nullToAbsent ? const Value.absent() : Value(lien),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      appliedAt: appliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedAt),
      responseAt: responseAt == null && nullToAbsent
          ? const Value.absent()
          : Value(responseAt),
      remindedAt: remindedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Application.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Application(
      id: serializer.fromJson<int>(json['id']),
      offerId: serializer.fromJson<int?>(json['offerId']),
      companyId: serializer.fromJson<int?>(json['companyId']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      poste: serializer.fromJson<String?>(json['poste']),
      entreprise: serializer.fromJson<String?>(json['entreprise']),
      lien: serializer.fromJson<String?>(json['lien']),
      score: serializer.fromJson<int?>(json['score']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
      responseAt: serializer.fromJson<DateTime?>(json['responseAt']),
      remindedAt: serializer.fromJson<DateTime?>(json['remindedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'offerId': serializer.toJson<int?>(offerId),
      'companyId': serializer.toJson<int?>(companyId),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'poste': serializer.toJson<String?>(poste),
      'entreprise': serializer.toJson<String?>(entreprise),
      'lien': serializer.toJson<String?>(lien),
      'score': serializer.toJson<int?>(score),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
      'responseAt': serializer.toJson<DateTime?>(responseAt),
      'remindedAt': serializer.toJson<DateTime?>(remindedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Application copyWith({
    int? id,
    Value<int?> offerId = const Value.absent(),
    Value<int?> companyId = const Value.absent(),
    String? kind,
    String? status,
    Value<String?> poste = const Value.absent(),
    Value<String?> entreprise = const Value.absent(),
    Value<String?> lien = const Value.absent(),
    Value<int?> score = const Value.absent(),
    Value<DateTime?> appliedAt = const Value.absent(),
    Value<DateTime?> responseAt = const Value.absent(),
    Value<DateTime?> remindedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Application(
    id: id ?? this.id,
    offerId: offerId.present ? offerId.value : this.offerId,
    companyId: companyId.present ? companyId.value : this.companyId,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    poste: poste.present ? poste.value : this.poste,
    entreprise: entreprise.present ? entreprise.value : this.entreprise,
    lien: lien.present ? lien.value : this.lien,
    score: score.present ? score.value : this.score,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
    responseAt: responseAt.present ? responseAt.value : this.responseAt,
    remindedAt: remindedAt.present ? remindedAt.value : this.remindedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Application copyWithCompanion(ApplicationsCompanion data) {
    return Application(
      id: data.id.present ? data.id.value : this.id,
      offerId: data.offerId.present ? data.offerId.value : this.offerId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      poste: data.poste.present ? data.poste.value : this.poste,
      entreprise: data.entreprise.present
          ? data.entreprise.value
          : this.entreprise,
      lien: data.lien.present ? data.lien.value : this.lien,
      score: data.score.present ? data.score.value : this.score,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      responseAt: data.responseAt.present
          ? data.responseAt.value
          : this.responseAt,
      remindedAt: data.remindedAt.present
          ? data.remindedAt.value
          : this.remindedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Application(')
          ..write('id: $id, ')
          ..write('offerId: $offerId, ')
          ..write('companyId: $companyId, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('poste: $poste, ')
          ..write('entreprise: $entreprise, ')
          ..write('lien: $lien, ')
          ..write('score: $score, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('responseAt: $responseAt, ')
          ..write('remindedAt: $remindedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    offerId,
    companyId,
    kind,
    status,
    poste,
    entreprise,
    lien,
    score,
    appliedAt,
    responseAt,
    remindedAt,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Application &&
          other.id == this.id &&
          other.offerId == this.offerId &&
          other.companyId == this.companyId &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.poste == this.poste &&
          other.entreprise == this.entreprise &&
          other.lien == this.lien &&
          other.score == this.score &&
          other.appliedAt == this.appliedAt &&
          other.responseAt == this.responseAt &&
          other.remindedAt == this.remindedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ApplicationsCompanion extends UpdateCompanion<Application> {
  final Value<int> id;
  final Value<int?> offerId;
  final Value<int?> companyId;
  final Value<String> kind;
  final Value<String> status;
  final Value<String?> poste;
  final Value<String?> entreprise;
  final Value<String?> lien;
  final Value<int?> score;
  final Value<DateTime?> appliedAt;
  final Value<DateTime?> responseAt;
  final Value<DateTime?> remindedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ApplicationsCompanion({
    this.id = const Value.absent(),
    this.offerId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.poste = const Value.absent(),
    this.entreprise = const Value.absent(),
    this.lien = const Value.absent(),
    this.score = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.responseAt = const Value.absent(),
    this.remindedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ApplicationsCompanion.insert({
    this.id = const Value.absent(),
    this.offerId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.poste = const Value.absent(),
    this.entreprise = const Value.absent(),
    this.lien = const Value.absent(),
    this.score = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.responseAt = const Value.absent(),
    this.remindedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<Application> custom({
    Expression<int>? id,
    Expression<int>? offerId,
    Expression<int>? companyId,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? poste,
    Expression<String>? entreprise,
    Expression<String>? lien,
    Expression<int>? score,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? responseAt,
    Expression<DateTime>? remindedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (offerId != null) 'offer_id': offerId,
      if (companyId != null) 'company_id': companyId,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (poste != null) 'poste': poste,
      if (entreprise != null) 'entreprise': entreprise,
      if (lien != null) 'lien': lien,
      if (score != null) 'score': score,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (responseAt != null) 'response_at': responseAt,
      if (remindedAt != null) 'reminded_at': remindedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ApplicationsCompanion copyWith({
    Value<int>? id,
    Value<int?>? offerId,
    Value<int?>? companyId,
    Value<String>? kind,
    Value<String>? status,
    Value<String?>? poste,
    Value<String?>? entreprise,
    Value<String?>? lien,
    Value<int?>? score,
    Value<DateTime?>? appliedAt,
    Value<DateTime?>? responseAt,
    Value<DateTime?>? remindedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return ApplicationsCompanion(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      companyId: companyId ?? this.companyId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      poste: poste ?? this.poste,
      entreprise: entreprise ?? this.entreprise,
      lien: lien ?? this.lien,
      score: score ?? this.score,
      appliedAt: appliedAt ?? this.appliedAt,
      responseAt: responseAt ?? this.responseAt,
      remindedAt: remindedAt ?? this.remindedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (offerId.present) {
      map['offer_id'] = Variable<int>(offerId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (poste.present) {
      map['poste'] = Variable<String>(poste.value);
    }
    if (entreprise.present) {
      map['entreprise'] = Variable<String>(entreprise.value);
    }
    if (lien.present) {
      map['lien'] = Variable<String>(lien.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (responseAt.present) {
      map['response_at'] = Variable<DateTime>(responseAt.value);
    }
    if (remindedAt.present) {
      map['reminded_at'] = Variable<DateTime>(remindedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('offerId: $offerId, ')
          ..write('companyId: $companyId, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('poste: $poste, ')
          ..write('entreprise: $entreprise, ')
          ..write('lien: $lien, ')
          ..write('score: $score, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('responseAt: $responseAt, ')
          ..write('remindedAt: $remindedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GeneratedDocumentsTable extends GeneratedDocuments
    with TableInfo<$GeneratedDocumentsTable, GeneratedDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedDocumentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _applicationIdMeta = const VerificationMeta(
    'applicationId',
  );
  @override
  late final GeneratedColumn<int> applicationId = GeneratedColumn<int>(
    'application_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES applications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cvPathMeta = const VerificationMeta('cvPath');
  @override
  late final GeneratedColumn<String> cvPath = GeneratedColumn<String>(
    'cv_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _letterPathMeta = const VerificationMeta(
    'letterPath',
  );
  @override
  late final GeneratedColumn<String> letterPath = GeneratedColumn<String>(
    'letter_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applicationId,
    cvPath,
    letterPath,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeneratedDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('application_id')) {
      context.handle(
        _applicationIdMeta,
        applicationId.isAcceptableOrUnknown(
          data['application_id']!,
          _applicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicationIdMeta);
    }
    if (data.containsKey('cv_path')) {
      context.handle(
        _cvPathMeta,
        cvPath.isAcceptableOrUnknown(data['cv_path']!, _cvPathMeta),
      );
    }
    if (data.containsKey('letter_path')) {
      context.handle(
        _letterPathMeta,
        letterPath.isAcceptableOrUnknown(data['letter_path']!, _letterPathMeta),
      );
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      applicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}application_id'],
      )!,
      cvPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cv_path'],
      ),
      letterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}letter_path'],
      ),
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $GeneratedDocumentsTable createAlias(String alias) {
    return $GeneratedDocumentsTable(attachedDatabase, alias);
  }
}

class GeneratedDocument extends DataClass
    implements Insertable<GeneratedDocument> {
  final int id;
  final int applicationId;
  final String? cvPath;
  final String? letterPath;
  final DateTime generatedAt;
  const GeneratedDocument({
    required this.id,
    required this.applicationId,
    this.cvPath,
    this.letterPath,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['application_id'] = Variable<int>(applicationId);
    if (!nullToAbsent || cvPath != null) {
      map['cv_path'] = Variable<String>(cvPath);
    }
    if (!nullToAbsent || letterPath != null) {
      map['letter_path'] = Variable<String>(letterPath);
    }
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  GeneratedDocumentsCompanion toCompanion(bool nullToAbsent) {
    return GeneratedDocumentsCompanion(
      id: Value(id),
      applicationId: Value(applicationId),
      cvPath: cvPath == null && nullToAbsent
          ? const Value.absent()
          : Value(cvPath),
      letterPath: letterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(letterPath),
      generatedAt: Value(generatedAt),
    );
  }

  factory GeneratedDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedDocument(
      id: serializer.fromJson<int>(json['id']),
      applicationId: serializer.fromJson<int>(json['applicationId']),
      cvPath: serializer.fromJson<String?>(json['cvPath']),
      letterPath: serializer.fromJson<String?>(json['letterPath']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'applicationId': serializer.toJson<int>(applicationId),
      'cvPath': serializer.toJson<String?>(cvPath),
      'letterPath': serializer.toJson<String?>(letterPath),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  GeneratedDocument copyWith({
    int? id,
    int? applicationId,
    Value<String?> cvPath = const Value.absent(),
    Value<String?> letterPath = const Value.absent(),
    DateTime? generatedAt,
  }) => GeneratedDocument(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    cvPath: cvPath.present ? cvPath.value : this.cvPath,
    letterPath: letterPath.present ? letterPath.value : this.letterPath,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  GeneratedDocument copyWithCompanion(GeneratedDocumentsCompanion data) {
    return GeneratedDocument(
      id: data.id.present ? data.id.value : this.id,
      applicationId: data.applicationId.present
          ? data.applicationId.value
          : this.applicationId,
      cvPath: data.cvPath.present ? data.cvPath.value : this.cvPath,
      letterPath: data.letterPath.present
          ? data.letterPath.value
          : this.letterPath,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedDocument(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('cvPath: $cvPath, ')
          ..write('letterPath: $letterPath, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, applicationId, cvPath, letterPath, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedDocument &&
          other.id == this.id &&
          other.applicationId == this.applicationId &&
          other.cvPath == this.cvPath &&
          other.letterPath == this.letterPath &&
          other.generatedAt == this.generatedAt);
}

class GeneratedDocumentsCompanion extends UpdateCompanion<GeneratedDocument> {
  final Value<int> id;
  final Value<int> applicationId;
  final Value<String?> cvPath;
  final Value<String?> letterPath;
  final Value<DateTime> generatedAt;
  const GeneratedDocumentsCompanion({
    this.id = const Value.absent(),
    this.applicationId = const Value.absent(),
    this.cvPath = const Value.absent(),
    this.letterPath = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  GeneratedDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required int applicationId,
    this.cvPath = const Value.absent(),
    this.letterPath = const Value.absent(),
    this.generatedAt = const Value.absent(),
  }) : applicationId = Value(applicationId);
  static Insertable<GeneratedDocument> custom({
    Expression<int>? id,
    Expression<int>? applicationId,
    Expression<String>? cvPath,
    Expression<String>? letterPath,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (cvPath != null) 'cv_path': cvPath,
      if (letterPath != null) 'letter_path': letterPath,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  GeneratedDocumentsCompanion copyWith({
    Value<int>? id,
    Value<int>? applicationId,
    Value<String?>? cvPath,
    Value<String?>? letterPath,
    Value<DateTime>? generatedAt,
  }) {
    return GeneratedDocumentsCompanion(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      cvPath: cvPath ?? this.cvPath,
      letterPath: letterPath ?? this.letterPath,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (applicationId.present) {
      map['application_id'] = Variable<int>(applicationId.value);
    }
    if (cvPath.present) {
      map['cv_path'] = Variable<String>(cvPath.value);
    }
    if (letterPath.present) {
      map['letter_path'] = Variable<String>(letterPath.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('cvPath: $cvPath, ')
          ..write('letterPath: $letterPath, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SearchProfilesTable searchProfiles = $SearchProfilesTable(this);
  late final $OffersTable offers = $OffersTable(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $ApplicationsTable applications = $ApplicationsTable(this);
  late final $GeneratedDocumentsTable generatedDocuments =
      $GeneratedDocumentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    searchProfiles,
    offers,
    companies,
    applications,
    generatedDocuments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'search_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('offers', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'offers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('applications', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('applications', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'applications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('generated_documents', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SearchProfilesTableCreateCompanionBuilder =
    SearchProfilesCompanion Function({
      Value<int> id,
      required String name,
      required String keywords,
      Value<String?> locationInsee,
      Value<String?> locationLabel,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> romeCodes,
      Value<int?> radiusKm,
      Value<String?> contractTypes,
      Value<String?> seniority,
      Value<String?> mustHave,
      Value<String?> exclusions,
      Value<int> scoreThreshold,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$SearchProfilesTableUpdateCompanionBuilder =
    SearchProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> keywords,
      Value<String?> locationInsee,
      Value<String?> locationLabel,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> romeCodes,
      Value<int?> radiusKm,
      Value<String?> contractTypes,
      Value<String?> seniority,
      Value<String?> mustHave,
      Value<String?> exclusions,
      Value<int> scoreThreshold,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$SearchProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $SearchProfilesTable, SearchProfile> {
  $$SearchProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$OffersTable, List<Offer>> _offersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.offers,
    aliasName: 'search_profiles__id__offers__profile_id',
  );

  $$OffersTableProcessedTableManager get offersRefs {
    final manager = $$OffersTableTableManager(
      $_db,
      $_db.offers,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_offersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SearchProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchProfilesTable> {
  $$SearchProfilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationInsee => $composableBuilder(
    column: $table.locationInsee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get romeCodes => $composableBuilder(
    column: $table.romeCodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractTypes => $composableBuilder(
    column: $table.contractTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seniority => $composableBuilder(
    column: $table.seniority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mustHave => $composableBuilder(
    column: $table.mustHave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exclusions => $composableBuilder(
    column: $table.exclusions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreThreshold => $composableBuilder(
    column: $table.scoreThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> offersRefs(
    Expression<bool> Function($$OffersTableFilterComposer f) f,
  ) {
    final $$OffersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.offers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OffersTableFilterComposer(
            $db: $db,
            $table: $db.offers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SearchProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchProfilesTable> {
  $$SearchProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationInsee => $composableBuilder(
    column: $table.locationInsee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get romeCodes => $composableBuilder(
    column: $table.romeCodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractTypes => $composableBuilder(
    column: $table.contractTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seniority => $composableBuilder(
    column: $table.seniority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mustHave => $composableBuilder(
    column: $table.mustHave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exclusions => $composableBuilder(
    column: $table.exclusions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreThreshold => $composableBuilder(
    column: $table.scoreThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchProfilesTable> {
  $$SearchProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get locationInsee => $composableBuilder(
    column: $table.locationInsee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get romeCodes =>
      $composableBuilder(column: $table.romeCodes, builder: (column) => column);

  GeneratedColumn<int> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);

  GeneratedColumn<String> get contractTypes => $composableBuilder(
    column: $table.contractTypes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seniority =>
      $composableBuilder(column: $table.seniority, builder: (column) => column);

  GeneratedColumn<String> get mustHave =>
      $composableBuilder(column: $table.mustHave, builder: (column) => column);

  GeneratedColumn<String> get exclusions => $composableBuilder(
    column: $table.exclusions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreThreshold => $composableBuilder(
    column: $table.scoreThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> offersRefs<T extends Object>(
    Expression<T> Function($$OffersTableAnnotationComposer a) f,
  ) {
    final $$OffersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.offers,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OffersTableAnnotationComposer(
            $db: $db,
            $table: $db.offers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SearchProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchProfilesTable,
          SearchProfile,
          $$SearchProfilesTableFilterComposer,
          $$SearchProfilesTableOrderingComposer,
          $$SearchProfilesTableAnnotationComposer,
          $$SearchProfilesTableCreateCompanionBuilder,
          $$SearchProfilesTableUpdateCompanionBuilder,
          (SearchProfile, $$SearchProfilesTableReferences),
          SearchProfile,
          PrefetchHooks Function({bool offersRefs})
        > {
  $$SearchProfilesTableTableManager(
    _$AppDatabase db,
    $SearchProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String?> locationInsee = const Value.absent(),
                Value<String?> locationLabel = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> romeCodes = const Value.absent(),
                Value<int?> radiusKm = const Value.absent(),
                Value<String?> contractTypes = const Value.absent(),
                Value<String?> seniority = const Value.absent(),
                Value<String?> mustHave = const Value.absent(),
                Value<String?> exclusions = const Value.absent(),
                Value<int> scoreThreshold = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SearchProfilesCompanion(
                id: id,
                name: name,
                keywords: keywords,
                locationInsee: locationInsee,
                locationLabel: locationLabel,
                latitude: latitude,
                longitude: longitude,
                romeCodes: romeCodes,
                radiusKm: radiusKm,
                contractTypes: contractTypes,
                seniority: seniority,
                mustHave: mustHave,
                exclusions: exclusions,
                scoreThreshold: scoreThreshold,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String keywords,
                Value<String?> locationInsee = const Value.absent(),
                Value<String?> locationLabel = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> romeCodes = const Value.absent(),
                Value<int?> radiusKm = const Value.absent(),
                Value<String?> contractTypes = const Value.absent(),
                Value<String?> seniority = const Value.absent(),
                Value<String?> mustHave = const Value.absent(),
                Value<String?> exclusions = const Value.absent(),
                Value<int> scoreThreshold = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SearchProfilesCompanion.insert(
                id: id,
                name: name,
                keywords: keywords,
                locationInsee: locationInsee,
                locationLabel: locationLabel,
                latitude: latitude,
                longitude: longitude,
                romeCodes: romeCodes,
                radiusKm: radiusKm,
                contractTypes: contractTypes,
                seniority: seniority,
                mustHave: mustHave,
                exclusions: exclusions,
                scoreThreshold: scoreThreshold,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SearchProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({offersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (offersRefs) db.offers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (offersRefs)
                    await $_getPrefetchedData<
                      SearchProfile,
                      $SearchProfilesTable,
                      Offer
                    >(
                      currentTable: table,
                      referencedTable: $$SearchProfilesTableReferences
                          ._offersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SearchProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).offersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SearchProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchProfilesTable,
      SearchProfile,
      $$SearchProfilesTableFilterComposer,
      $$SearchProfilesTableOrderingComposer,
      $$SearchProfilesTableAnnotationComposer,
      $$SearchProfilesTableCreateCompanionBuilder,
      $$SearchProfilesTableUpdateCompanionBuilder,
      (SearchProfile, $$SearchProfilesTableReferences),
      SearchProfile,
      PrefetchHooks Function({bool offersRefs})
    >;
typedef $$OffersTableCreateCompanionBuilder =
    OffersCompanion Function({
      Value<int> id,
      required String source,
      Value<String?> sourceId,
      required String hash,
      required String title,
      Value<String?> company,
      Value<String?> companyCanon,
      Value<String?> location,
      Value<String?> contractType,
      Value<String?> salary,
      Value<String?> description,
      Value<String?> url,
      Value<int?> score,
      Value<String?> scoreReason,
      Value<int?> profileId,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$OffersTableUpdateCompanionBuilder =
    OffersCompanion Function({
      Value<int> id,
      Value<String> source,
      Value<String?> sourceId,
      Value<String> hash,
      Value<String> title,
      Value<String?> company,
      Value<String?> companyCanon,
      Value<String?> location,
      Value<String?> contractType,
      Value<String?> salary,
      Value<String?> description,
      Value<String?> url,
      Value<int?> score,
      Value<String?> scoreReason,
      Value<int?> profileId,
      Value<String> status,
      Value<DateTime> createdAt,
    });

final class $$OffersTableReferences
    extends BaseReferences<_$AppDatabase, $OffersTable, Offer> {
  $$OffersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SearchProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.searchProfiles.createAlias('offers__profile_id__search_profiles__id');

  $$SearchProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$SearchProfilesTableTableManager(
      $_db,
      $_db.searchProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ApplicationsTable, List<Application>>
  _applicationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.applications,
    aliasName: 'offers__id__applications__offer_id',
  );

  $$ApplicationsTableProcessedTableManager get applicationsRefs {
    final manager = $$ApplicationsTableTableManager(
      $_db,
      $_db.applications,
    ).filter((f) => f.offerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_applicationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OffersTableFilterComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableFilterComposer({
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCanon => $composableBuilder(
    column: $table.companyCanon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scoreReason => $composableBuilder(
    column: $table.scoreReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SearchProfilesTableFilterComposer get profileId {
    final $$SearchProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.searchProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SearchProfilesTableFilterComposer(
            $db: $db,
            $table: $db.searchProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> applicationsRefs(
    Expression<bool> Function($$ApplicationsTableFilterComposer f) f,
  ) {
    final $$ApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.offerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OffersTableOrderingComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCanon => $composableBuilder(
    column: $table.companyCanon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scoreReason => $composableBuilder(
    column: $table.scoreReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SearchProfilesTableOrderingComposer get profileId {
    final $$SearchProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.searchProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SearchProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.searchProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OffersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OffersTable> {
  $$OffersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get companyCanon => $composableBuilder(
    column: $table.companyCanon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get scoreReason => $composableBuilder(
    column: $table.scoreReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SearchProfilesTableAnnotationComposer get profileId {
    final $$SearchProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.searchProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SearchProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.searchProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> applicationsRefs<T extends Object>(
    Expression<T> Function($$ApplicationsTableAnnotationComposer a) f,
  ) {
    final $$ApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.offerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OffersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OffersTable,
          Offer,
          $$OffersTableFilterComposer,
          $$OffersTableOrderingComposer,
          $$OffersTableAnnotationComposer,
          $$OffersTableCreateCompanionBuilder,
          $$OffersTableUpdateCompanionBuilder,
          (Offer, $$OffersTableReferences),
          Offer,
          PrefetchHooks Function({bool profileId, bool applicationsRefs})
        > {
  $$OffersTableTableManager(_$AppDatabase db, $OffersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OffersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OffersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OffersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> hash = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> companyCanon = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> contractType = const Value.absent(),
                Value<String?> salary = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<String?> scoreReason = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OffersCompanion(
                id: id,
                source: source,
                sourceId: sourceId,
                hash: hash,
                title: title,
                company: company,
                companyCanon: companyCanon,
                location: location,
                contractType: contractType,
                salary: salary,
                description: description,
                url: url,
                score: score,
                scoreReason: scoreReason,
                profileId: profileId,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String source,
                Value<String?> sourceId = const Value.absent(),
                required String hash,
                required String title,
                Value<String?> company = const Value.absent(),
                Value<String?> companyCanon = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> contractType = const Value.absent(),
                Value<String?> salary = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<String?> scoreReason = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OffersCompanion.insert(
                id: id,
                source: source,
                sourceId: sourceId,
                hash: hash,
                title: title,
                company: company,
                companyCanon: companyCanon,
                location: location,
                contractType: contractType,
                salary: salary,
                description: description,
                url: url,
                score: score,
                scoreReason: scoreReason,
                profileId: profileId,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OffersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, applicationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (applicationsRefs) db.applications,
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
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable: $$OffersTableReferences
                                        ._profileIdTable(db),
                                    referencedColumn: $$OffersTableReferences
                                        ._profileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (applicationsRefs)
                        await $_getPrefetchedData<
                          Offer,
                          $OffersTable,
                          Application
                        >(
                          currentTable: table,
                          referencedTable: $$OffersTableReferences
                              ._applicationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OffersTableReferences(
                                db,
                                table,
                                p0,
                              ).applicationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.offerId == item.id,
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

typedef $$OffersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OffersTable,
      Offer,
      $$OffersTableFilterComposer,
      $$OffersTableOrderingComposer,
      $$OffersTableAnnotationComposer,
      $$OffersTableCreateCompanionBuilder,
      $$OffersTableUpdateCompanionBuilder,
      (Offer, $$OffersTableReferences),
      Offer,
      PrefetchHooks Function({bool profileId, bool applicationsRefs})
    >;
typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> website,
      Value<String?> sector,
      Value<String?> description,
      Value<String?> aiSummary,
      Value<String?> applyUrl,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime> lastUpdated,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> website,
      Value<String?> sector,
      Value<String?> description,
      Value<String?> aiSummary,
      Value<String?> applyUrl,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime> lastUpdated,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ApplicationsTable, List<Application>>
  _applicationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.applications,
    aliasName: 'companies__id__applications__company_id',
  );

  $$ApplicationsTableProcessedTableManager get applicationsRefs {
    final manager = $$ApplicationsTableTableManager(
      $_db,
      $_db.applications,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_applicationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiSummary => $composableBuilder(
    column: $table.aiSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applyUrl => $composableBuilder(
    column: $table.applyUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> applicationsRefs(
    Expression<bool> Function($$ApplicationsTableFilterComposer f) f,
  ) {
    final $$ApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiSummary => $composableBuilder(
    column: $table.aiSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applyUrl => $composableBuilder(
    column: $table.applyUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiSummary =>
      $composableBuilder(column: $table.aiSummary, builder: (column) => column);

  GeneratedColumn<String> get applyUrl =>
      $composableBuilder(column: $table.applyUrl, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  Expression<T> applicationsRefs<T extends Object>(
    Expression<T> Function($$ApplicationsTableAnnotationComposer a) f,
  ) {
    final $$ApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({bool applicationsRefs})
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> aiSummary = const Value.absent(),
                Value<String?> applyUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                website: website,
                sector: sector,
                description: description,
                aiSummary: aiSummary,
                applyUrl: applyUrl,
                phone: phone,
                email: email,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> website = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> aiSummary = const Value.absent(),
                Value<String?> applyUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                website: website,
                sector: sector,
                description: description,
                aiSummary: aiSummary,
                applyUrl: applyUrl,
                phone: phone,
                email: email,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (applicationsRefs) db.applications],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (applicationsRefs)
                    await $_getPrefetchedData<
                      Company,
                      $CompaniesTable,
                      Application
                    >(
                      currentTable: table,
                      referencedTable: $$CompaniesTableReferences
                          ._applicationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CompaniesTableReferences(
                            db,
                            table,
                            p0,
                          ).applicationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.companyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({bool applicationsRefs})
    >;
typedef $$ApplicationsTableCreateCompanionBuilder =
    ApplicationsCompanion Function({
      Value<int> id,
      Value<int?> offerId,
      Value<int?> companyId,
      Value<String> kind,
      Value<String> status,
      Value<String?> poste,
      Value<String?> entreprise,
      Value<String?> lien,
      Value<int?> score,
      Value<DateTime?> appliedAt,
      Value<DateTime?> responseAt,
      Value<DateTime?> remindedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$ApplicationsTableUpdateCompanionBuilder =
    ApplicationsCompanion Function({
      Value<int> id,
      Value<int?> offerId,
      Value<int?> companyId,
      Value<String> kind,
      Value<String> status,
      Value<String?> poste,
      Value<String?> entreprise,
      Value<String?> lien,
      Value<int?> score,
      Value<DateTime?> appliedAt,
      Value<DateTime?> responseAt,
      Value<DateTime?> remindedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$ApplicationsTableReferences
    extends BaseReferences<_$AppDatabase, $ApplicationsTable, Application> {
  $$ApplicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OffersTable _offerIdTable(_$AppDatabase db) =>
      db.offers.createAlias('applications__offer_id__offers__id');

  $$OffersTableProcessedTableManager? get offerId {
    final $_column = $_itemColumn<int>('offer_id');
    if ($_column == null) return null;
    final manager = $$OffersTableTableManager(
      $_db,
      $_db.offers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_offerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('applications__company_id__companies__id');

  $$CompaniesTableProcessedTableManager? get companyId {
    final $_column = $_itemColumn<int>('company_id');
    if ($_column == null) return null;
    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GeneratedDocumentsTable, List<GeneratedDocument>>
  _generatedDocumentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.generatedDocuments,
        aliasName: 'applications__id__generated_documents__application_id',
      );

  $$GeneratedDocumentsTableProcessedTableManager get generatedDocumentsRefs {
    final manager = $$GeneratedDocumentsTableTableManager(
      $_db,
      $_db.generatedDocuments,
    ).filter((f) => f.applicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _generatedDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApplicationsTableFilterComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poste => $composableBuilder(
    column: $table.poste,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entreprise => $composableBuilder(
    column: $table.entreprise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lien => $composableBuilder(
    column: $table.lien,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get responseAt => $composableBuilder(
    column: $table.responseAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindedAt => $composableBuilder(
    column: $table.remindedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OffersTableFilterComposer get offerId {
    final $$OffersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offerId,
      referencedTable: $db.offers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OffersTableFilterComposer(
            $db: $db,
            $table: $db.offers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> generatedDocumentsRefs(
    Expression<bool> Function($$GeneratedDocumentsTableFilterComposer f) f,
  ) {
    final $$GeneratedDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.generatedDocuments,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeneratedDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.generatedDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApplicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poste => $composableBuilder(
    column: $table.poste,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entreprise => $composableBuilder(
    column: $table.entreprise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lien => $composableBuilder(
    column: $table.lien,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get responseAt => $composableBuilder(
    column: $table.responseAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindedAt => $composableBuilder(
    column: $table.remindedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OffersTableOrderingComposer get offerId {
    final $$OffersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offerId,
      referencedTable: $db.offers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OffersTableOrderingComposer(
            $db: $db,
            $table: $db.offers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApplicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get poste =>
      $composableBuilder(column: $table.poste, builder: (column) => column);

  GeneratedColumn<String> get entreprise => $composableBuilder(
    column: $table.entreprise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lien =>
      $composableBuilder(column: $table.lien, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get responseAt => $composableBuilder(
    column: $table.responseAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remindedAt => $composableBuilder(
    column: $table.remindedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OffersTableAnnotationComposer get offerId {
    final $$OffersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offerId,
      referencedTable: $db.offers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OffersTableAnnotationComposer(
            $db: $db,
            $table: $db.offers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> generatedDocumentsRefs<T extends Object>(
    Expression<T> Function($$GeneratedDocumentsTableAnnotationComposer a) f,
  ) {
    final $$GeneratedDocumentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.generatedDocuments,
          getReferencedColumn: (t) => t.applicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GeneratedDocumentsTableAnnotationComposer(
                $db: $db,
                $table: $db.generatedDocuments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ApplicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApplicationsTable,
          Application,
          $$ApplicationsTableFilterComposer,
          $$ApplicationsTableOrderingComposer,
          $$ApplicationsTableAnnotationComposer,
          $$ApplicationsTableCreateCompanionBuilder,
          $$ApplicationsTableUpdateCompanionBuilder,
          (Application, $$ApplicationsTableReferences),
          Application,
          PrefetchHooks Function({
            bool offerId,
            bool companyId,
            bool generatedDocumentsRefs,
          })
        > {
  $$ApplicationsTableTableManager(_$AppDatabase db, $ApplicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> offerId = const Value.absent(),
                Value<int?> companyId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> poste = const Value.absent(),
                Value<String?> entreprise = const Value.absent(),
                Value<String?> lien = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<DateTime?> responseAt = const Value.absent(),
                Value<DateTime?> remindedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ApplicationsCompanion(
                id: id,
                offerId: offerId,
                companyId: companyId,
                kind: kind,
                status: status,
                poste: poste,
                entreprise: entreprise,
                lien: lien,
                score: score,
                appliedAt: appliedAt,
                responseAt: responseAt,
                remindedAt: remindedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> offerId = const Value.absent(),
                Value<int?> companyId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> poste = const Value.absent(),
                Value<String?> entreprise = const Value.absent(),
                Value<String?> lien = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<DateTime?> responseAt = const Value.absent(),
                Value<DateTime?> remindedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ApplicationsCompanion.insert(
                id: id,
                offerId: offerId,
                companyId: companyId,
                kind: kind,
                status: status,
                poste: poste,
                entreprise: entreprise,
                lien: lien,
                score: score,
                appliedAt: appliedAt,
                responseAt: responseAt,
                remindedAt: remindedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApplicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                offerId = false,
                companyId = false,
                generatedDocumentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (generatedDocumentsRefs) db.generatedDocuments,
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
                        if (offerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.offerId,
                                    referencedTable:
                                        $$ApplicationsTableReferences
                                            ._offerIdTable(db),
                                    referencedColumn:
                                        $$ApplicationsTableReferences
                                            ._offerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$ApplicationsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$ApplicationsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (generatedDocumentsRefs)
                        await $_getPrefetchedData<
                          Application,
                          $ApplicationsTable,
                          GeneratedDocument
                        >(
                          currentTable: table,
                          referencedTable: $$ApplicationsTableReferences
                              ._generatedDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApplicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).generatedDocumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.applicationId == item.id,
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

typedef $$ApplicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApplicationsTable,
      Application,
      $$ApplicationsTableFilterComposer,
      $$ApplicationsTableOrderingComposer,
      $$ApplicationsTableAnnotationComposer,
      $$ApplicationsTableCreateCompanionBuilder,
      $$ApplicationsTableUpdateCompanionBuilder,
      (Application, $$ApplicationsTableReferences),
      Application,
      PrefetchHooks Function({
        bool offerId,
        bool companyId,
        bool generatedDocumentsRefs,
      })
    >;
typedef $$GeneratedDocumentsTableCreateCompanionBuilder =
    GeneratedDocumentsCompanion Function({
      Value<int> id,
      required int applicationId,
      Value<String?> cvPath,
      Value<String?> letterPath,
      Value<DateTime> generatedAt,
    });
typedef $$GeneratedDocumentsTableUpdateCompanionBuilder =
    GeneratedDocumentsCompanion Function({
      Value<int> id,
      Value<int> applicationId,
      Value<String?> cvPath,
      Value<String?> letterPath,
      Value<DateTime> generatedAt,
    });

final class $$GeneratedDocumentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GeneratedDocumentsTable,
          GeneratedDocument
        > {
  $$GeneratedDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApplicationsTable _applicationIdTable(_$AppDatabase db) => db
      .applications
      .createAlias('generated_documents__application_id__applications__id');

  $$ApplicationsTableProcessedTableManager get applicationId {
    final $_column = $_itemColumn<int>('application_id')!;

    final manager = $$ApplicationsTableTableManager(
      $_db,
      $_db.applications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GeneratedDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratedDocumentsTable> {
  $$GeneratedDocumentsTableFilterComposer({
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

  ColumnFilters<String> get cvPath => $composableBuilder(
    column: $table.cvPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get letterPath => $composableBuilder(
    column: $table.letterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ApplicationsTableFilterComposer get applicationId {
    final $$ApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratedDocumentsTable> {
  $$GeneratedDocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get cvPath => $composableBuilder(
    column: $table.cvPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get letterPath => $composableBuilder(
    column: $table.letterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApplicationsTableOrderingComposer get applicationId {
    final $$ApplicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableOrderingComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratedDocumentsTable> {
  $$GeneratedDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cvPath =>
      $composableBuilder(column: $table.cvPath, builder: (column) => column);

  GeneratedColumn<String> get letterPath => $composableBuilder(
    column: $table.letterPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  $$ApplicationsTableAnnotationComposer get applicationId {
    final $$ApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.applications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.applications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeneratedDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeneratedDocumentsTable,
          GeneratedDocument,
          $$GeneratedDocumentsTableFilterComposer,
          $$GeneratedDocumentsTableOrderingComposer,
          $$GeneratedDocumentsTableAnnotationComposer,
          $$GeneratedDocumentsTableCreateCompanionBuilder,
          $$GeneratedDocumentsTableUpdateCompanionBuilder,
          (GeneratedDocument, $$GeneratedDocumentsTableReferences),
          GeneratedDocument,
          PrefetchHooks Function({bool applicationId})
        > {
  $$GeneratedDocumentsTableTableManager(
    _$AppDatabase db,
    $GeneratedDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratedDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratedDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratedDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> applicationId = const Value.absent(),
                Value<String?> cvPath = const Value.absent(),
                Value<String?> letterPath = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
              }) => GeneratedDocumentsCompanion(
                id: id,
                applicationId: applicationId,
                cvPath: cvPath,
                letterPath: letterPath,
                generatedAt: generatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int applicationId,
                Value<String?> cvPath = const Value.absent(),
                Value<String?> letterPath = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
              }) => GeneratedDocumentsCompanion.insert(
                id: id,
                applicationId: applicationId,
                cvPath: cvPath,
                letterPath: letterPath,
                generatedAt: generatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GeneratedDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationId = false}) {
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
                    if (applicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applicationId,
                                referencedTable:
                                    $$GeneratedDocumentsTableReferences
                                        ._applicationIdTable(db),
                                referencedColumn:
                                    $$GeneratedDocumentsTableReferences
                                        ._applicationIdTable(db)
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

typedef $$GeneratedDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeneratedDocumentsTable,
      GeneratedDocument,
      $$GeneratedDocumentsTableFilterComposer,
      $$GeneratedDocumentsTableOrderingComposer,
      $$GeneratedDocumentsTableAnnotationComposer,
      $$GeneratedDocumentsTableCreateCompanionBuilder,
      $$GeneratedDocumentsTableUpdateCompanionBuilder,
      (GeneratedDocument, $$GeneratedDocumentsTableReferences),
      GeneratedDocument,
      PrefetchHooks Function({bool applicationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SearchProfilesTableTableManager get searchProfiles =>
      $$SearchProfilesTableTableManager(_db, _db.searchProfiles);
  $$OffersTableTableManager get offers =>
      $$OffersTableTableManager(_db, _db.offers);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db, _db.applications);
  $$GeneratedDocumentsTableTableManager get generatedDocuments =>
      $$GeneratedDocumentsTableTableManager(_db, _db.generatedDocuments);
}
