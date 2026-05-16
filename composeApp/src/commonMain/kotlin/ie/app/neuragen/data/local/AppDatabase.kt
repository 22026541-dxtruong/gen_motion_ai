package ie.app.neuragen.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.ConstructedBy
import androidx.room.RoomDatabaseConstructor
import ie.app.neuragen.data.local.dao.ExploreDao
import ie.app.neuragen.data.local.dao.JobDao
import ie.app.neuragen.data.local.dao.UserProfileDao
import ie.app.neuragen.data.local.entity.CachedExploreItem
import ie.app.neuragen.data.local.entity.CachedJob
import ie.app.neuragen.data.local.entity.CachedUserProfile

@Database(
    entities = [
        CachedExploreItem::class,
        CachedJob::class,
        CachedUserProfile::class
    ],
    version = 1,
    exportSchema = true
)
@ConstructedBy(AppDatabaseConstructor::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun exploreDao(): ExploreDao
    abstract fun jobDao(): JobDao
    abstract fun userProfileDao(): UserProfileDao
}

// Room KSP generates the actual implementation
@Suppress("NO_ACTUAL_FOR_EXPECT")
expect object AppDatabaseConstructor : RoomDatabaseConstructor<AppDatabase>
