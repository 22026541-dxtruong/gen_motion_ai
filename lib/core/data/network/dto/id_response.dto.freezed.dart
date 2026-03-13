// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id_response.dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdResponseDto {

 String get id;
/// Create a copy of IdResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdResponseDtoCopyWith<IdResponseDto> get copyWith => _$IdResponseDtoCopyWithImpl<IdResponseDto>(this as IdResponseDto, _$identity);

  /// Serializes this IdResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdResponseDto&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'IdResponseDto(id: $id)';
}


}

/// @nodoc
abstract mixin class $IdResponseDtoCopyWith<$Res>  {
  factory $IdResponseDtoCopyWith(IdResponseDto value, $Res Function(IdResponseDto) _then) = _$IdResponseDtoCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$IdResponseDtoCopyWithImpl<$Res>
    implements $IdResponseDtoCopyWith<$Res> {
  _$IdResponseDtoCopyWithImpl(this._self, this._then);

  final IdResponseDto _self;
  final $Res Function(IdResponseDto) _then;

/// Create a copy of IdResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IdResponseDto].
extension IdResponseDtoPatterns on IdResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _IdResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _IdResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdResponseDto() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id)  $default,) {final _that = this;
switch (_that) {
case _IdResponseDto():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id)?  $default,) {final _that = this;
switch (_that) {
case _IdResponseDto() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdResponseDto implements IdResponseDto {
  const _IdResponseDto({required this.id});
  factory _IdResponseDto.fromJson(Map<String, dynamic> json) => _$IdResponseDtoFromJson(json);

@override final  String id;

/// Create a copy of IdResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdResponseDtoCopyWith<_IdResponseDto> get copyWith => __$IdResponseDtoCopyWithImpl<_IdResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdResponseDto&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'IdResponseDto(id: $id)';
}


}

/// @nodoc
abstract mixin class _$IdResponseDtoCopyWith<$Res> implements $IdResponseDtoCopyWith<$Res> {
  factory _$IdResponseDtoCopyWith(_IdResponseDto value, $Res Function(_IdResponseDto) _then) = __$IdResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$IdResponseDtoCopyWithImpl<$Res>
    implements _$IdResponseDtoCopyWith<$Res> {
  __$IdResponseDtoCopyWithImpl(this._self, this._then);

  final _IdResponseDto _self;
  final $Res Function(_IdResponseDto) _then;

/// Create a copy of IdResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_IdResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
