package com.mparticle.cordova;

import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;

interface RoktPluginDelegate {
    void selectPlacements(JSONArray args, CallbackContext callbackContext) throws JSONException;

    void selectShoppableAds(JSONArray args, CallbackContext callbackContext) throws JSONException;

    void purchaseFinalized(JSONArray args, CallbackContext callbackContext) throws JSONException;

    void setSessionId(JSONArray args, CallbackContext callbackContext) throws JSONException;

    void getSessionId(CallbackContext callbackContext);

    void roktEvents(JSONArray args, CallbackContext callbackContext) throws JSONException;

    void onDestroy();
}
