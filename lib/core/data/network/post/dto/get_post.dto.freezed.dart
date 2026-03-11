// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_post.dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetPostDto {

 String get id; String? get caption;@JsonKey(name: 'view_count') int get viewCount;@JsonKey(name: 'comment_count') int get commentCount;@JsonKey(name: 'like_count') int get likeCount;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'is_liked') bool get isLiked;@JsonKey(name: 'is_followed') bool get isFollowed; PostUserDto get user;@JsonKey(name: 'asset_version') PostAssetVersionDto get assetVersion;
/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetPostDtoCopyWith<GetPostDto> get copyWith => _$GetPostDtoCopyWithImpl<GetPostDto>(this as GetPostDto, _$identity);

  /// Serializes this GetPostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isFollowed, isFollowed) || other.isFollowed == isFollowed)&&(identical(other.user, user) || other.user == user)&&(identical(other.assetVersion, assetVersion) || other.assetVersion == assetVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caption,viewCount,commentCount,likeCount,createdAt,isLiked,isFollowed,user,assetVersion);

@override
String toString() {
  return 'GetPostDto(id: $id, caption: $caption, viewCount: $viewCount, commentCount: $commentCount, likeCount: $likeCount, createdAt: $createdAt, isLiked: $isLiked, isFollowed: $isFollowed, user: $user, assetVersion: $assetVersion)';
}


}

/// @nodoc
abstract mixin class $GetPostDtoCopyWith<$Res>  {
  factory $GetPostDtoCopyWith(GetPostDto value, $Res Function(GetPostDto) _then) = _$GetPostDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? caption,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'like_count') int likeCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_followed') bool isFollowed, PostUserDto user,@JsonKey(name: 'asset_version') PostAssetVersionDto assetVersion
});


$PostUserDtoCopyWith<$Res> get user;$PostAssetVersionDtoCopyWith<$Res> get assetVersion;

}
/// @nodoc
class _$GetPostDtoCopyWithImpl<$Res>
    implements $GetPostDtoCopyWith<$Res> {
  _$GetPostDtoCopyWithImpl(this._self, this._then);

  final GetPostDto _self;
  final $Res Function(GetPostDto) _then;

/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? caption = freezed,Object? viewCount = null,Object? commentCount = null,Object? likeCount = null,Object? createdAt = null,Object? isLiked = null,Object? isFollowed = null,Object? user = null,Object? assetVersion = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isFollowed: null == isFollowed ? _self.isFollowed : isFollowed // ignore: cast_nullable_to_non_nullable
as bool,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as PostUserDto,assetVersion: null == assetVersion ? _self.assetVersion : assetVersion // ignore: cast_nullable_to_non_nullable
as PostAssetVersionDto,
  ));
}
/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostUserDtoCopyWith<$Res> get user {
  
  return $PostUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAssetVersionDtoCopyWith<$Res> get assetVersion {
  
  return $PostAssetVersionDtoCopyWith<$Res>(_self.assetVersion, (value) {
    return _then(_self.copyWith(assetVersion: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetPostDto].
extension GetPostDtoPatterns on GetPostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetPostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetPostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetPostDto value)  $default,){
final _that = this;
switch (_that) {
case _GetPostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetPostDto value)?  $default,){
final _that = this;
switch (_that) {
case _GetPostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? caption, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_followed')  bool isFollowed,  PostUserDto user, @JsonKey(name: 'asset_version')  PostAssetVersionDto assetVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetPostDto() when $default != null:
return $default(_that.id,_that.caption,_that.viewCount,_that.commentCount,_that.likeCount,_that.createdAt,_that.isLiked,_that.isFollowed,_that.user,_that.assetVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? caption, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_followed')  bool isFollowed,  PostUserDto user, @JsonKey(name: 'asset_version')  PostAssetVersionDto assetVersion)  $default,) {final _that = this;
switch (_that) {
case _GetPostDto():
return $default(_that.id,_that.caption,_that.viewCount,_that.commentCount,_that.likeCount,_that.createdAt,_that.isLiked,_that.isFollowed,_that.user,_that.assetVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? caption, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_followed')  bool isFollowed,  PostUserDto user, @JsonKey(name: 'asset_version')  PostAssetVersionDto assetVersion)?  $default,) {final _that = this;
switch (_that) {
case _GetPostDto() when $default != null:
return $default(_that.id,_that.caption,_that.viewCount,_that.commentCount,_that.likeCount,_that.createdAt,_that.isLiked,_that.isFollowed,_that.user,_that.assetVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetPostDto implements GetPostDto {
  const _GetPostDto({required this.id, this.caption, @JsonKey(name: 'view_count') required this.viewCount, @JsonKey(name: 'comment_count') required this.commentCount, @JsonKey(name: 'like_count') required this.likeCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'is_liked') required this.isLiked, @JsonKey(name: 'is_followed') required this.isFollowed, required this.user, @JsonKey(name: 'asset_version') required this.assetVersion});
  factory _GetPostDto.fromJson(Map<String, dynamic> json) => _$GetPostDtoFromJson(json);

@override final  String id;
@override final  String? caption;
@override@JsonKey(name: 'view_count') final  int viewCount;
@override@JsonKey(name: 'comment_count') final  int commentCount;
@override@JsonKey(name: 'like_count') final  int likeCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'is_liked') final  bool isLiked;
@override@JsonKey(name: 'is_followed') final  bool isFollowed;
@override final  PostUserDto user;
@override@JsonKey(name: 'asset_version') final  PostAssetVersionDto assetVersion;

/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPostDtoCopyWith<_GetPostDto> get copyWith => __$GetPostDtoCopyWithImpl<_GetPostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetPostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isFollowed, isFollowed) || other.isFollowed == isFollowed)&&(identical(other.user, user) || other.user == user)&&(identical(other.assetVersion, assetVersion) || other.assetVersion == assetVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caption,viewCount,commentCount,likeCount,createdAt,isLiked,isFollowed,user,assetVersion);

@override
String toString() {
  return 'GetPostDto(id: $id, caption: $caption, viewCount: $viewCount, commentCount: $commentCount, likeCount: $likeCount, createdAt: $createdAt, isLiked: $isLiked, isFollowed: $isFollowed, user: $user, assetVersion: $assetVersion)';
}


}

/// @nodoc
abstract mixin class _$GetPostDtoCopyWith<$Res> implements $GetPostDtoCopyWith<$Res> {
  factory _$GetPostDtoCopyWith(_GetPostDto value, $Res Function(_GetPostDto) _then) = __$GetPostDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? caption,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'like_count') int likeCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_followed') bool isFollowed, PostUserDto user,@JsonKey(name: 'asset_version') PostAssetVersionDto assetVersion
});


@override $PostUserDtoCopyWith<$Res> get user;@override $PostAssetVersionDtoCopyWith<$Res> get assetVersion;

}
/// @nodoc
class __$GetPostDtoCopyWithImpl<$Res>
    implements _$GetPostDtoCopyWith<$Res> {
  __$GetPostDtoCopyWithImpl(this._self, this._then);

  final _GetPostDto _self;
  final $Res Function(_GetPostDto) _then;

/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? caption = freezed,Object? viewCount = null,Object? commentCount = null,Object? likeCount = null,Object? createdAt = null,Object? isLiked = null,Object? isFollowed = null,Object? user = null,Object? assetVersion = null,}) {
  return _then(_GetPostDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isFollowed: null == isFollowed ? _self.isFollowed : isFollowed // ignore: cast_nullable_to_non_nullable
as bool,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as PostUserDto,assetVersion: null == assetVersion ? _self.assetVersion : assetVersion // ignore: cast_nullable_to_non_nullable
as PostAssetVersionDto,
  ));
}

/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostUserDtoCopyWith<$Res> get user {
  
  return $PostUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of GetPostDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAssetVersionDtoCopyWith<$Res> get assetVersion {
  
  return $PostAssetVersionDtoCopyWith<$Res>(_self.assetVersion, (value) {
    return _then(_self.copyWith(assetVersion: value));
  });
}
}


/// @nodoc
mixin _$PostUserDto {

 String get id; String get username;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of PostUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostUserDtoCopyWith<PostUserDto> get copyWith => _$PostUserDtoCopyWithImpl<PostUserDto>(this as PostUserDto, _$identity);

  /// Serializes this PostUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostUserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl);

@override
String toString() {
  return 'PostUserDto(id: $id, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $PostUserDtoCopyWith<$Res>  {
  factory $PostUserDtoCopyWith(PostUserDto value, $Res Function(PostUserDto) _then) = _$PostUserDtoCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$PostUserDtoCopyWithImpl<$Res>
    implements $PostUserDtoCopyWith<$Res> {
  _$PostUserDtoCopyWithImpl(this._self, this._then);

  final PostUserDto _self;
  final $Res Function(PostUserDto) _then;

/// Create a copy of PostUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostUserDto].
extension PostUserDtoPatterns on PostUserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostUserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostUserDto value)  $default,){
final _that = this;
switch (_that) {
case _PostUserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _PostUserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostUserDto() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _PostUserDto():
return $default(_that.id,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _PostUserDto() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostUserDto implements PostUserDto {
  const _PostUserDto({required this.id, required this.username, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _PostUserDto.fromJson(Map<String, dynamic> json) => _$PostUserDtoFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of PostUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostUserDtoCopyWith<_PostUserDto> get copyWith => __$PostUserDtoCopyWithImpl<_PostUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostUserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl);

@override
String toString() {
  return 'PostUserDto(id: $id, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$PostUserDtoCopyWith<$Res> implements $PostUserDtoCopyWith<$Res> {
  factory _$PostUserDtoCopyWith(_PostUserDto value, $Res Function(_PostUserDto) _then) = __$PostUserDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$PostUserDtoCopyWithImpl<$Res>
    implements _$PostUserDtoCopyWith<$Res> {
  __$PostUserDtoCopyWithImpl(this._self, this._then);

  final _PostUserDto _self;
  final $Res Function(_PostUserDto) _then;

/// Create a copy of PostUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? avatarUrl = freezed,}) {
  return _then(_PostUserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PostAssetVersionDto {

 String get id;@JsonKey(name: 'file_url') String get fileUrl; Map<String, dynamic>? get metadata;
/// Create a copy of PostAssetVersionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostAssetVersionDtoCopyWith<PostAssetVersionDto> get copyWith => _$PostAssetVersionDtoCopyWithImpl<PostAssetVersionDto>(this as PostAssetVersionDto, _$identity);

  /// Serializes this PostAssetVersionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostAssetVersionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileUrl,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PostAssetVersionDto(id: $id, fileUrl: $fileUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PostAssetVersionDtoCopyWith<$Res>  {
  factory $PostAssetVersionDtoCopyWith(PostAssetVersionDto value, $Res Function(PostAssetVersionDto) _then) = _$PostAssetVersionDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'file_url') String fileUrl, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$PostAssetVersionDtoCopyWithImpl<$Res>
    implements $PostAssetVersionDtoCopyWith<$Res> {
  _$PostAssetVersionDtoCopyWithImpl(this._self, this._then);

  final PostAssetVersionDto _self;
  final $Res Function(PostAssetVersionDto) _then;

/// Create a copy of PostAssetVersionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileUrl = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostAssetVersionDto].
extension PostAssetVersionDtoPatterns on PostAssetVersionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostAssetVersionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostAssetVersionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostAssetVersionDto value)  $default,){
final _that = this;
switch (_that) {
case _PostAssetVersionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostAssetVersionDto value)?  $default,){
final _that = this;
switch (_that) {
case _PostAssetVersionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'file_url')  String fileUrl,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostAssetVersionDto() when $default != null:
return $default(_that.id,_that.fileUrl,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'file_url')  String fileUrl,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PostAssetVersionDto():
return $default(_that.id,_that.fileUrl,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'file_url')  String fileUrl,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PostAssetVersionDto() when $default != null:
return $default(_that.id,_that.fileUrl,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostAssetVersionDto implements PostAssetVersionDto {
  const _PostAssetVersionDto({required this.id, @JsonKey(name: 'file_url') required this.fileUrl, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _PostAssetVersionDto.fromJson(Map<String, dynamic> json) => _$PostAssetVersionDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'file_url') final  String fileUrl;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PostAssetVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostAssetVersionDtoCopyWith<_PostAssetVersionDto> get copyWith => __$PostAssetVersionDtoCopyWithImpl<_PostAssetVersionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostAssetVersionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostAssetVersionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileUrl,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PostAssetVersionDto(id: $id, fileUrl: $fileUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PostAssetVersionDtoCopyWith<$Res> implements $PostAssetVersionDtoCopyWith<$Res> {
  factory _$PostAssetVersionDtoCopyWith(_PostAssetVersionDto value, $Res Function(_PostAssetVersionDto) _then) = __$PostAssetVersionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'file_url') String fileUrl, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$PostAssetVersionDtoCopyWithImpl<$Res>
    implements _$PostAssetVersionDtoCopyWith<$Res> {
  __$PostAssetVersionDtoCopyWithImpl(this._self, this._then);

  final _PostAssetVersionDto _self;
  final $Res Function(_PostAssetVersionDto) _then;

/// Create a copy of PostAssetVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileUrl = null,Object? metadata = freezed,}) {
  return _then(_PostAssetVersionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
