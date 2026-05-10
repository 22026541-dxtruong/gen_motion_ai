package ie.app.neuragen

import android.app.Application
import coil3.ImageLoader
import coil3.SingletonImageLoader
import coil3.video.VideoFrameDecoder
import ie.app.neuragen.di.AppModule
import org.koin.android.ext.koin.androidContext
import org.koin.plugin.module.dsl.startKoin

class NeuraGenApp : Application() {
    override fun onCreate() {
        super.onCreate()

        SingletonImageLoader.setSafe {
            ImageLoader.Builder(this)
                .components {
                    add(VideoFrameDecoder.Factory())
                }
                .build()
        }

        startKoin<AppModule> {
            androidContext(this@NeuraGenApp)
        }
    }
}