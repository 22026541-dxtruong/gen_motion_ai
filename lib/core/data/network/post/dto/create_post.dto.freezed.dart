// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post.dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePostDto {

@JsonKey(name: 'asset_version_id') String get assetVersionId; String? get caption;@JsonKey(name: 'is_public') String get isPublic;
/// Create a copy of CreatePostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePostDtoCopyWith<CreatePostDto> get copyWith => _$CreatePostDtoCopyWithImpl<CreatePostDto>(this as CreatePostDto, _$identity);

  /// Serializes this CreatePostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePostDto&&(identical(other.assetVersionId, assetVersionId) || other.assetVersionId == assetVersionId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetVersionId,caption,isPublic);

@override
String toString() {
  return 'CreatePostDto(assetVersionId: $assetVersionId, caption: $caption, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class $CreatePostDtoCopyWith<$Res>  {
  factory $CreatePostDtoCopyWith(CreatePostDto value, $Res Function(CreatePostDto) _then) = _$CreatePostDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'asset_version_id') String assetVersionId, String? caption,@JsonKey(name: 'is_public') String isPublic
});




}
/// @nodoc
class _$CreatePostDtoCopyWithImpl<$Res>
    implements $CreatePostDtoCopyWith<$Res> {
  _$CreatePostDtoCopyWithImpl(this._self, this._then);

  final CreatePostDto _self;
  final $Res Function(CreatePostDto) _then;

/// Create a copy of CreatePostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assetVersionId = null,Object? caption = freezed,Object? isPublic = null,}) {
  return _then(_self.copyWith(
assetVersionId: null == assetVersionId ? _self.assetVersionId : assetVersionId // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePostDto].
extension CreatePostDtoPatterns on CreatePostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePostDto value)  $default,){
final _that = this;
switch (_that) {
case _CreatePostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePostDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'asset_version_id')  String assetVersionId,  String? caption, @JsonKey(name: 'is_public')  String isPublic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePostDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'asset_version_id')  String assetVersionId,  String? caption, @JsonKey(name: 'is_public')  String isPublic)  $default,) {final _that = this;
switch (_that) {
case _CreatePostDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'asset_version_id')  String assetVersionId,  String? caption, @JsonKey(name: 'is_public')  String isPublic)?  $default,) {final _that = this;
switch (_that) {
case _CreatePostDto() when $default != null:
return $default(_that.assetVersionId,_that.caption,_that.isPublic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePostDto implements CreatePostDto {
  const _CreatePostDto({@JsonKey(name: 'asset_version_id') required this.assetVersionId, this.caption, @JsonKey(name: 'is_public') required this.isPublic});
  factory _CreatePostDto.fromJson(Map<String, dynamic> json) => _$CreatePostDtoFromJson(json);

@override@JsonKey(name: 'asset_version_id') final  String assetVersionId;
@override final  String? caption;
@override@JsonKey(name: 'is_public') final  String isPublic;

/// Create a copy of CreatePostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePostDtoCopyWith<_CreatePostDto> get copyWith => __$CreatePostDtoCopyWithImpl<_CreatePostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePostDto&&(identical(other.assetVersionId, assetVersionId) || other.assetVersionId == assetVersionId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assetVersionId,caption,isPublic);

@override
String toString() {
  return 'CreatePostDto(assetVersionId: $assetVersionId, caption: $caption, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class _$CreatePostDtoCopyWith<$Res> implements $CreatePostDtoCopyWith<$Res> {
  factory _$CreatePostDtoCopyWith(_CreatePostDto value, $Res Function(_CreatePostDto) _then) = __$CreatePostDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'asset_version_id') String assetVersionId, String? caption,@JsonKey(name: 'is_public') String isPublic
});




}
/// @nodoc
class __$CreatePostDtoCopyWithImpl<$Res>
    implements _$CreatePostDtoCopyWith<$Res> {
  __$CreatePostDtoCopyWithImpl(this._self, this._then);

  final _CreatePostDto _self;
  final $Res Function(_CreatePostDto) _then;

/// Create a copy of CreatePostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assetVersionId = null,Object? caption = freezed,Object? isPublic = null,}) {
  return _then(_CreatePostDto(
assetVersionId: null == assetVersionId ? _self.assetVersionId : assetVersionId // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
