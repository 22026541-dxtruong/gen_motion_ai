package ie.app.neuragen.data.local

import android.app.Application
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import okio.Path.Companion.toPath
import org.koin.core.annotation.Single

@Single
actual class DataStoreFactory(private val application: Application) {
    actual fun create(): DataStore<Preferences> {
        return PreferenceDataStoreFactory.createWithPath {
            application.filesDir.resolve(DATASTORE_FILE_NAME).absolutePath.toPath()
        }
    }
}
