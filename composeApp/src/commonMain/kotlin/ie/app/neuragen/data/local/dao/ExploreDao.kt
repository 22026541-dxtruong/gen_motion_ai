package ie.app.neuragen.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import ie.app.neuragen.data.local.entity.CachedExploreItem
import kotlinx.coroutines.flow.Flow

@Dao
interface ExploreDao {
    @Query("SELECT * FROM cached_explore_items WHERE mode = :mode ORDER BY sortOrder ASC")
    fun getByMode(mode: String): Flow<List<CachedExploreItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<CachedExploreItem>)

    @Query("DELETE FROM cached_explore_items WHERE mode = :mode")
    suspend fun clearByMode(mode: String)

    @Query("DELETE FROM cached_explore_items WHERE cachedAt < :before")
    suspend fun clearOlderThan(before: Long)

    @Query("DELETE FROM cached_explore_items")
    suspend fun clearAll()
}
