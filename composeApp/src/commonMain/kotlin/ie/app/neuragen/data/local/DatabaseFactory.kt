package ie.app.neuragen.data.local

import org.koin.core.annotation.Single

@Single
expect class DatabaseFactory {
    fun create(): AppDatabase
}
