package ie.app.neuragen.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import ie.app.neuragen.data.network.model.AuthResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface SessionRepository {
    fun getSession(): Flow<AuthResponse?>
    suspend fun saveSession(session: AuthResponse)
    suspend fun clearSession()
}

@Single([SessionRepository::class])
class SessionRepositoryImpl(
    @Provided private val dataStore: DataStore<Preferences>,
    @Provided private val json: Json
) : SessionRepository {

    private val sessionKey = stringPreferencesKey("user_session")

    override fun getSession(): Flow<AuthResponse?> {
        return dataStore.data.map { preferences ->
            preferences[sessionKey]?.let { jsonString ->
                try {
                    json.decodeFromString<AuthResponse>(jsonString)
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun saveSession(session: AuthResponse) {
        dataStore.edit { preferences ->
            preferences[sessionKey] = json.encodeToString(session)
        }
    }

    override suspend fun clearSession() {
        dataStore.edit { preferences ->
            preferences.remove(sessionKey)
        }
    }
}
