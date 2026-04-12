// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseResponseDto<T> {

 bool get success; T? get data; String? get message; Map<String, dynamic>? get meta; Map<String, dynamic>? get error;
/// Create a copy of BaseResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseResponseDtoCopyWith<T, BaseResponseDto<T>> get copyWith => _$BaseResponseDtoCopyWithImpl<T, BaseResponseDto<T>>(this as BaseResponseDto<T>, _$identity);

  /// Serializes this BaseResponseDto to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseResponseDto<T>&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.meta, meta)&&const DeepCollectionEquality().equals(other.error, error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,const DeepCollectionEquality().hash(data),message,const DeepCollectionEquality().hash(meta),const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'BaseResponseDto<$T>(success: $success, data: $data, message: $message, meta: $meta, error: $error)';
}


}

/// @nodoc
abstract mixin class $BaseResponseDtoCopyWith<T,$Res>  {
  factory $BaseResponseDtoCopyWith(BaseResponseDto<T> value, $Res Function(BaseResponseDto<T>) _then) = _$BaseResponseDtoCopyWithImpl;
@useResult
$Res call({
 bool success, T? data, String? message, Map<String, dynamic>? meta, Map<String, dynamic>? error
});




}
/// @nodoc
class _$BaseResponseDtoCopyWithImpl<T,$Res>
    implements $BaseResponseDtoCopyWith<T, $Res> {
  _$BaseResponseDtoCopyWithImpl(this._self, this._then);

  final BaseResponseDto<T> _self;
  final $Res Function(BaseResponseDto<T>) _then;

/// Create a copy of BaseResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? data = freezed,Object? message = freezed,Object? meta = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseResponseDto].
extension BaseResponseDtoPatterns<T> on BaseResponseDto<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseResponseDto<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseResponseDto<T> value)  $default,){
final _that = this;
switch (_that) {
case _BaseResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseResponseDto<T> value)?  $default,){
final _that = this;
switch (_that) {
case _BaseResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  T? data,  String? message,  Map<String, dynamic>? meta,  Map<String, dynamic>? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseResponseDto() when $default != null:
return $default(_that.success,_that.data,_that.message,_that.meta,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  T? data,  String? message,  Map<String, dynamic>? meta,  Map<String, dynamic>? error)  $default,) {final _that = this;
switch (_that) {
case _BaseResponseDto():
return $default(_that.success,_that.data,_that.message,_that.meta,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  T? data,  String? message,  Map<String, dynamic>? meta,  Map<String, dynamic>? error)?  $default,) {final _that = this;
switch (_that) {
case _BaseResponseDto() when $default != null:
return $default(_that.success,_that.data,_that.message,_that.meta,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _BaseResponseDto<T> implements BaseResponseDto<T> {
  const _BaseResponseDto({required this.success, this.data, this.message, final  Map<String, dynamic>? meta, final  Map<String, dynamic>? error}): _meta = meta,_error = error;
  factory _BaseResponseDto.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$BaseResponseDtoFromJson(json,fromJsonT);

@override final  bool success;
@override final  T? data;
@override final  String? message;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _error;
@override Map<String, dynamic>? get error {
  final value = _error;
  if (value == null) return null;
  if (_error is EqualUnmodifiableMapView) return _error;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of BaseResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseResponseDtoCopyWith<T, _BaseResponseDto<T>> get copyWith => __$BaseResponseDtoCopyWithImpl<T, _BaseResponseDto<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$BaseResponseDtoToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseResponseDto<T>&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._meta, _meta)&&const DeepCollectionEquality().equals(other._error, _error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,const DeepCollectionEquality().hash(data),message,const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_error));

@override
String toString() {
  return 'BaseResponseDto<$T>(success: $success, data: $data, message: $message, meta: $meta, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BaseResponseDtoCopyWith<T,$Res> implements $BaseResponseDtoCopyWith<T, $Res> {
  factory _$BaseResponseDtoCopyWith(_BaseResponseDto<T> value, $Res Function(_BaseResponseDto<T>) _then) = __$BaseResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 bool success, T? data, String? message, Map<String, dynamic>? meta, Map<String, dynamic>? error
});




}
/// @nodoc
class __$BaseResponseDtoCopyWithImpl<T,$Res>
    implements _$BaseResponseDtoCopyWith<T, $Res> {
  __$BaseResponseDtoCopyWithImpl(this._self, this._then);

  final _BaseResponseDto<T> _self;
  final $Res Function(_BaseResponseDto<T>) _then;

/// Create a copy of BaseResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? data = freezed,Object? message = freezed,Object? meta = freezed,Object? error = freezed,}) {
  return _then(_BaseResponseDto<T>(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self._error : error // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
