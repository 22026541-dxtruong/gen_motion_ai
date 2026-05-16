package ie.app.neuragen.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "cached_user_profile")
data class CachedUserProfile(
    @PrimaryKey val id: String,
    val jsonData: String,
    val cachedAt: Long
)
