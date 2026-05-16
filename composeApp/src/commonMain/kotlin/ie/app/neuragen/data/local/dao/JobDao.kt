package ie.app.neuragen.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import ie.app.neuragen.data.local.entity.CachedJob
import kotlinx.coroutines.flow.Flow

@Dao
interface JobDao {
    @Query("SELECT * FROM cached_jobs ORDER BY sortOrder ASC")
    fun getAll(): Flow<List<CachedJob>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<CachedJob>)

    @Query("DELETE FROM cached_jobs")
    suspend fun clearAll()

    @Query("DELETE FROM cached_jobs WHERE cachedAt < :before")
    suspend fun clearOlderThan(before: Long)
}
