package com.mparticle.example;

import android.app.Application;
import com.mparticle.MParticle;
import com.mparticle.identity.IdentityApiRequest;
import com.mparticle.MParticleOptions;

public class ExampleApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        IdentityApiRequest.Builder identityRequest = IdentityApiRequest.withEmptyUser();

        MParticleOptions options = MParticleOptions.builder(this)
                .credentials("REPLACE ME WITH KEY","REPLACE ME WITH SECRET")
                .logLevel(MParticle.LogLevel.VERBOSE)
                .identify(identityRequest.build())
                .build();

        MParticle.start(options);
    }
}
