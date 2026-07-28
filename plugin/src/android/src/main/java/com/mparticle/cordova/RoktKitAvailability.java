package com.mparticle.cordova;

final class RoktKitAvailability {
    static final String REQUIRED_MESSAGE =
        "Rokt is unavailable. Install @mparticle/cordova-rokt-kit to enable Rokt APIs.";

    private static final String ROKT_EMBEDDED_VIEW_CLASS = "com.mparticle.kits.RoktEmbeddedView";

    private RoktKitAvailability() {
    }

    static boolean isAvailable() {
        try {
            Class.forName(ROKT_EMBEDDED_VIEW_CLASS);
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        } catch (LinkageError e) {
            return false;
        }
    }

    static RoktPluginDelegate createDelegate() {
        if (!isAvailable()) {
            return null;
        }
        return new RoktBridge();
    }
}
