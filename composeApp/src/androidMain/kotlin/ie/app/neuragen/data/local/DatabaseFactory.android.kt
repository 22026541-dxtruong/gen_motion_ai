package ie.app.neuragen.data.local

import android.app.Application
import androidx.room.Room
import org.koin.core.annotation.Single

@Single
actual class DatabaseFactory(private val application: Application) {
    actual fun create(): AppDatabase {
        val dbFile = application.getDatabasePath("neuragen.db")
        return Room.databaseBuilder<AppDatabase>(
            context = application,
            name = dbFile.absolutePath
        ).build()
    }
}
