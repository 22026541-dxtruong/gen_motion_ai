package ie.app.neuragen.di

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import ie.app.neuragen.data.local.DataStoreFactory
import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.Module
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

@Module
@ComponentScan("ie.app.neuragen.data.local")
object LocalModule {
    @Single
    fun provideDataStore(factory: DataStoreFactory): DataStore<Preferences> = factory.create()
}
