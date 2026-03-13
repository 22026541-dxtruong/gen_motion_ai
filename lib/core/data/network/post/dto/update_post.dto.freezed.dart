// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_post.dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdatePostDto {

@JsonKey(name: 'asset_version_id') String? get assetVersionId; String? get caption;@JsonKey(name: 'is_public') bool? get isPublic;
/// Create a copy of UpdatePostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePostDtoCopyWith<UpdatePostDto> get copyWith => _$UpdatePostDtoCopyWithImpl<UpdatePostDto>(this as UpdatePostDto, _$identity);

  /// Serializes this UpdatePostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePostDto&&(identical(other.assetVersionId, assetVersionId) || other.assetVersionId == assetVersionId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetVersionId,caption,isPublic);

@override
String toString() {
  return 'UpdatePostDto(assetVersionId: $assetVersionId, caption: $caption, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class $UpdatePostDtoCopyWith<$Res>  {
  factory $UpdatePostDtoCopyWith(UpdatePostDto value, $Res Function(UpdatePostDto) _then) = _$UpdatePostDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'asset_version_id') String? assetVersionId, String? caption,@JsonKey(name: 'is_public') bool? isPublic
});




}
/// @nodoc
class _$UpdatePostDtoCopyWithImpl<$Res>
    implements $UpdatePostDtoCopyWith<$Res> {
  _$UpdatePostDtoCopyWithImpl(this._self, this._then);

  final UpdatePostDto _self;
  final $Res Function(UpdatePostDto) _then;

/// Create a copy of UpdatePostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetVersionId = freezed,Object? caption = freezed,Object? isPublic = freezed,}) {
  return _then(_self.copyWith(
assetVersionId: freezed == assetVersionId ? _self.assetVersionId : assetVersionId // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePostDto].
extension UpdatePostDtoPatterns on UpdatePostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePostDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePostDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'asset_version_id')  String? assetVersionId,  String? caption, @JsonKey(name: 'is_public')  bool? isPublic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePostDto() when $default != null:
return $default(_that.assetVersionId,_that.caption,_that.isPublic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'asset_version_id')  String? assetVersionId,  String? caption, @JsonKey(name: 'is_public')  bool? isPublic)  $default,) {final _that = this;
switch (_that) {
case _UpdatePostDto():
return $default(_that.assetVersionId,_that.caption,_that.isPublic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'asset_version_id')  String? assetVersionId,  String? caption, @JsonKey(name: 'is_public')  bool? isPublic)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePostDto() when $default != null:
return $default(_that.assetVersionId,_that.caption,_that.isPublic);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdatePostDto implements UpdatePostDto {
  const _UpdatePostDto({@JsonKey(name: 'asset_version_id') this.assetVersionId, this.caption, @JsonKey(name: 'is_public') this.isPublic});
  factory _UpdatePostDto.fromJson(Map<String, dynamic> json) => _$UpdatePostDtoFromJson(json);

@override@JsonKey(name: 'asset_version_id') final  String? assetVersionId;
@override final  String? caption;
@override@JsonKey(name: 'is_public') final  bool? isPublic;

/// Create a copy of UpdatePostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePostDtoCopyWith<_UpdatePostDto> get copyWith => __$UpdatePostDtoCopyWithImpl<_UpdatePostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePostDto&&(identical(other.assetVersionId, assetVersionId) || other.assetVersionId == assetVersionId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetVersionId,caption,isPublic);

@override
String toString() {
  return 'UpdatePostDto(assetVersionId: $assetVersionId, caption: $caption, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class _$UpdatePostDtoCopyWith<$Res> implements $UpdatePostDtoCopyWith<$Res> {
  factory _$UpdatePostDtoCopyWith(_UpdatePostDto value, $Res Function(_UpdatePostDto) _then) = __$UpdatePostDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'asset_version_id') String? assetVersionId, String? caption,@JsonKey(name: 'is_public') bool? isPublic
});




}
/// @nodoc
class __$UpdatePostDtoCopyWithImpl<$Res>
    implements _$UpdatePostDtoCopyWith<$Res> {
  __$UpdatePostDtoCopyWithImpl(this._self, this._then);

  final _UpdatePostDto _self;
  final $Res Function(_UpdatePostDto) _then;

/// Create a copy of UpdatePostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetVersionId = freezed,Object? caption = freezed,Object? isPublic = freezed,}) {
  return _then(_UpdatePostDto(
assetVersionId: freezed == assetVersionId ? _self.assetVersionId : assetVersionId // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
