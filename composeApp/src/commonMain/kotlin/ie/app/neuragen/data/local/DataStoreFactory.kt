package ie.app.neuragen.data.local

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import org.koin.core.annotation.Single

@Single
expect class DataStoreFactory {
    fun create(): DataStore<Preferences>
}

const val DATASTORE_FILE_NAME = "neuragen.preferences_pb"
