package ie.app.neuragen

import android.app.Application
import ie.app.neuragen.di.AppModule
import org.koin.android.ext.koin.androidContext
import org.koin.plugin.module.dsl.startKoin

class NeuraGenApp : Application() {
    override fun onCreate() {
        super.onCreate()

        startKoin<AppModule> {
            androidContext(this@NeuraGenApp)
        }
    }
}