// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cursor_pagination.dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CursorPaginationDto<T> {

 List<T> get data;
/// Create a copy of CursorPaginationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorPaginationDtoCopyWith<T, CursorPaginationDto<T>> get copyWith => _$CursorPaginationDtoCopyWithImpl<T, CursorPaginationDto<T>>(this as CursorPaginationDto<T>, _$identity);

  /// Serializes this CursorPaginationDto to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorPaginationDto<T>&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'CursorPaginationDto<$T>(data: $data)';
}


}

/// @nodoc
abstract mixin class $CursorPaginationDtoCopyWith<T,$Res>  {
  factory $CursorPaginationDtoCopyWith(CursorPaginationDto<T> value, $Res Function(CursorPaginationDto<T>) _then) = _$CursorPaginationDtoCopyWithImpl;
@useResult
$Res call({
 List<T> data
});




}
/// @nodoc
class _$CursorPaginationDtoCopyWithImpl<T,$Res>
    implements $CursorPaginationDtoCopyWith<T, $Res> {
  _$CursorPaginationDtoCopyWithImpl(this._self, this._then);

  final CursorPaginationDto<T> _self;
  final $Res Function(CursorPaginationDto<T>) _then;

/// Create a copy of CursorPaginationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<T>,
  ));
}

}


/// Adds pattern-matching-related methods to [CursorPaginationDto].
extension CursorPaginationDtoPatterns<T> on CursorPaginationDto<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CursorPaginationDto<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CursorPaginationDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CursorPaginationDto<T> value)  $default,){
final _that = this;
switch (_that) {
case _CursorPaginationDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CursorPaginationDto<T> value)?  $default,){
final _that = this;
switch (_that) {
case _CursorPaginationDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CursorPaginationDto() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> data)  $default,) {final _that = this;
switch (_that) {
case _CursorPaginationDto():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> data)?  $default,) {final _that = this;
switch (_that) {
case _CursorPaginationDto() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _CursorPaginationDto<T> implements CursorPaginationDto<T> {
  const _CursorPaginationDto({required final  List<T> data}): _data = data;
  factory _CursorPaginationDto.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$CursorPaginationDtoFromJson(json,fromJsonT);

 final  List<T> _data;
@override List<T> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of CursorPaginationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorPaginationDtoCopyWith<T, _CursorPaginationDto<T>> get copyWith => __$CursorPaginationDtoCopyWithImpl<T, _CursorPaginationDto<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$CursorPaginationDtoToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorPaginationDto<T>&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'CursorPaginationDto<$T>(data: $data)';
}


}

/// @nodoc
abstract mixin class _$CursorPaginationDtoCopyWith<T,$Res> implements $CursorPaginationDtoCopyWith<T, $Res> {
  factory _$CursorPaginationDtoCopyWith(_CursorPaginationDto<T> value, $Res Function(_CursorPaginationDto<T>) _then) = __$CursorPaginationDtoCopyWithImpl;
@override @useResult
$Res call({
 List<T> data
});




}
/// @nodoc
class __$CursorPaginationDtoCopyWithImpl<T,$Res>
    implements _$CursorPaginationDtoCopyWith<T, $Res> {
  __$CursorPaginationDtoCopyWithImpl(this._self, this._then);

  final _CursorPaginationDto<T> _self;
  final $Res Function(_CursorPaginationDto<T>) _then;

/// Create a copy of CursorPaginationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_CursorPaginationDto<T>(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<T>,
  ));
}


}

// dart format on
