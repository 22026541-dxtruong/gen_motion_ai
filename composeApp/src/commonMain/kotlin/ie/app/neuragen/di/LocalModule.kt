package ie.app.neuragen.di

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import ie.app.neuragen.data.local.AppDatabase
import ie.app.neuragen.data.local.DataStoreFactory
import ie.app.neuragen.data.local.DatabaseFactory
import ie.app.neuragen.data.local.dao.ExploreDao
import ie.app.neuragen.data.local.dao.JobDao
import ie.app.neuragen.data.local.dao.UserProfileDao
import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.Module
import org.koin.core.annotation.Single

@Module
@ComponentScan("ie.app.neuragen.data.local", "ie.app.neuragen.data.sync")
object LocalModule {
    @Single
    fun provideDataStore(factory: DataStoreFactory): DataStore<Preferences> = factory.create()

    @Single
    fun provideDatabase(factory: DatabaseFactory): AppDatabase = factory.create()

    @Single
    fun provideExploreDao(db: AppDatabase): ExploreDao = db.exploreDao()

    @Single
    fun provideJobDao(db: AppDatabase): JobDao = db.jobDao()

    @Single
    fun provideUserProfileDao(db: AppDatabase): UserProfileDao = db.userProfileDao()
}
