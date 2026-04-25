package ie.app.neuragen.di

import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.Module

@Module
@ComponentScan("ie.app.neuragen.data.repository")
class RepositoryModule
