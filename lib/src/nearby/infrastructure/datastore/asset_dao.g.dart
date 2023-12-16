// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_dao.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssetDaoCollection on Isar {
  IsarCollection<AssetDao> get assetDaos => this.collection();
}

const AssetDaoSchema = CollectionSchema(
  name: r'AssetDao',
  id: -3590883892861413138,
  properties: {
    r'encryptedData': PropertySchema(
      id: 0,
      name: r'encryptedData',
      type: IsarType.string,
    )
  },
  estimateSize: _assetDaoEstimateSize,
  serialize: _assetDaoSerialize,
  deserialize: _assetDaoDeserialize,
  deserializeProp: _assetDaoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _assetDaoGetId,
  getLinks: _assetDaoGetLinks,
  attach: _assetDaoAttach,
  version: '3.1.0+1',
);

int _assetDaoEstimateSize(
  AssetDao object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.encryptedData.length * 3;
  return bytesCount;
}

void _assetDaoSerialize(
  AssetDao object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.encryptedData);
}

AssetDao _assetDaoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AssetDao(
    reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _assetDaoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _assetDaoGetId(AssetDao object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _assetDaoGetLinks(AssetDao object) {
  return [];
}

void _assetDaoAttach(IsarCollection<dynamic> col, Id id, AssetDao object) {
  object.id = id;
}

extension AssetDaoQueryWhereSort on QueryBuilder<AssetDao, AssetDao, QWhere> {
  QueryBuilder<AssetDao, AssetDao, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AssetDaoQueryWhere on QueryBuilder<AssetDao, AssetDao, QWhereClause> {
  QueryBuilder<AssetDao, AssetDao, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AssetDaoQueryFilter
    on QueryBuilder<AssetDao, AssetDao, QFilterCondition> {
  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition>
      encryptedDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition>
      encryptedDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> encryptedDataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition>
      encryptedDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedData',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition>
      encryptedDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedData',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AssetDaoQueryObject
    on QueryBuilder<AssetDao, AssetDao, QFilterCondition> {}

extension AssetDaoQueryLinks
    on QueryBuilder<AssetDao, AssetDao, QFilterCondition> {}

extension AssetDaoQuerySortBy on QueryBuilder<AssetDao, AssetDao, QSortBy> {
  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> sortByEncryptedData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedData', Sort.asc);
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> sortByEncryptedDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedData', Sort.desc);
    });
  }
}

extension AssetDaoQuerySortThenBy
    on QueryBuilder<AssetDao, AssetDao, QSortThenBy> {
  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> thenByEncryptedData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedData', Sort.asc);
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> thenByEncryptedDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedData', Sort.desc);
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AssetDao, AssetDao, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension AssetDaoQueryWhereDistinct
    on QueryBuilder<AssetDao, AssetDao, QDistinct> {
  QueryBuilder<AssetDao, AssetDao, QDistinct> distinctByEncryptedData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedData',
          caseSensitive: caseSensitive);
    });
  }
}

extension AssetDaoQueryProperty
    on QueryBuilder<AssetDao, AssetDao, QQueryProperty> {
  QueryBuilder<AssetDao, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AssetDao, String, QQueryOperations> encryptedDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedData');
    });
  }
}
