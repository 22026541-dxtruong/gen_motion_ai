package ie.app.neuragen.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "cached_jobs")
data class CachedJob(
    @PrimaryKey val id: String,
    val jsonData: String,
    val cachedAt: Long,
    val sortOrder: Int
)
