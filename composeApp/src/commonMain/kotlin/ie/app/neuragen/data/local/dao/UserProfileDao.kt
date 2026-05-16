package ie.app.neuragen.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import ie.app.neuragen.data.local.entity.CachedUserProfile
import kotlinx.coroutines.flow.Flow

@Dao
interface UserProfileDao {
    @Query("SELECT * FROM cached_user_profile LIMIT 1")
    fun get(): Flow<CachedUserProfile?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(profile: CachedUserProfile)

    @Query("DELETE FROM cached_user_profile")
    suspend fun clear()
}
