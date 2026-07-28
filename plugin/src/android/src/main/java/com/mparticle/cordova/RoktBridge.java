package com.mparticle.cordova;

import com.mparticle.MParticle;
import com.mparticle.internal.Logger;
import com.mparticle.kits.MParticleRoktKt;
import com.rokt.roktsdk.CacheConfig;
import com.rokt.roktsdk.RoktConfig;
import com.rokt.roktsdk.RoktEvent;

import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.jvm.functions.Function2;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.CoroutineScopeKt;
import kotlinx.coroutines.Dispatchers;
import kotlinx.coroutines.flow.Flow;
import kotlinx.coroutines.flow.FlowKt;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.CancellationException;

final class RoktBridge implements RoktPluginDelegate {
    private final Map<String, CoroutineScope> roktEventScopes = new HashMap<>();

    private com.mparticle.kits.Rokt rokt() {
        return MParticleRoktKt.getRokt(MParticle.getInstance());
    }

    @Override
    public void selectPlacements(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String identifier = args.getString(0);
        final JSONObject attributesMap = args.getJSONObject(1);
        final JSONObject configMap = args.isNull(2) ? null : args.getJSONObject(2);

        final Map<String, String> attributes = convertStringMap(attributesMap);
        final RoktConfig roktConfig = buildRoktConfig(configMap);

        rokt().selectPlacements(
            identifier,
            attributes,
            null,
            null,
            roktConfig
        );
        callbackContext.success();
    }

    @Override
    public void selectShoppableAds(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String identifier = args.getString(0);
        final JSONObject attributesMap = args.getJSONObject(1);
        final JSONObject configMap = args.isNull(2) ? null : args.getJSONObject(2);

        final Map<String, String> attributes = convertStringMap(attributesMap);
        final RoktConfig roktConfig = buildRoktConfig(configMap);

        rokt().selectShoppableAds(identifier, attributes, roktConfig);
        callbackContext.success();
    }

    @Override
    public void purchaseFinalized(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String identifier = args.getString(0);
        final String catalogItemId = args.getString(1);
        final boolean success = args.getBoolean(2);

        rokt().purchaseFinalized(identifier, catalogItemId, success);
        callbackContext.success();
    }

    @Override
    public void setSessionId(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String sessionId = args.getString(0);
        if (sessionId != null && sessionId.length() > 0) {
            rokt().setSessionId(sessionId);
        }
        callbackContext.success();
    }

    @Override
    public void getSessionId(final CallbackContext callbackContext) {
        String sessionId = rokt().getSessionId();
        if (sessionId != null) {
            callbackContext.success(sessionId);
        } else {
            callbackContext.success();
        }
    }

    @Override
    public void roktEvents(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String identifier = args.getString(0);

        CoroutineScope previous = roktEventScopes.remove(identifier);
        if (previous != null) {
            CoroutineScopeKt.cancel(previous, (CancellationException) null);
        }

        Flow<RoktEvent> events = rokt().events(identifier);

        Function2<RoktEvent, Continuation<? super Unit>, Object> onEach =
            (event, continuation) -> {
                JSONObject json = jsonFromRoktEvent(event);
                if (json != null) {
                    PluginResult result = new PluginResult(PluginResult.Status.OK, json);
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                }
                return Unit.INSTANCE;
            };

        CoroutineScope scope = CoroutineScopeKt.CoroutineScope(Dispatchers.getDefault());
        FlowKt.launchIn(FlowKt.onEach(events, onEach), scope);
        roktEventScopes.put(identifier, scope);
    }

    @Override
    public void onDestroy() {
        for (CoroutineScope scope : roktEventScopes.values()) {
            CoroutineScopeKt.cancel(scope, (CancellationException) null);
        }
        roktEventScopes.clear();
    }

    private static RoktConfig buildRoktConfig(final JSONObject configMap) throws JSONException {
        if (configMap == null || configMap == JSONObject.NULL || configMap.length() == 0) {
            return null;
        }

        final RoktConfig.Builder builder = new RoktConfig.Builder();
        boolean hasConfig = false;

        if (configMap.has("colorMode") && !configMap.isNull("colorMode")) {
            final JSONObject colorModeObj = configMap.getJSONObject("colorMode");
            if (colorModeObj.has("value") && !colorModeObj.isNull("value")) {
                hasConfig = true;
                builder.colorMode(RoktConfig.ColorMode.valueOf(colorModeObj.getString("value")));
            }
        }

        if (configMap.has("cacheConfig") && !configMap.isNull("cacheConfig")) {
            final JSONObject cacheConfigMap = configMap.getJSONObject("cacheConfig");
            hasConfig = true;
            final long cacheDuration = cacheConfigMap.has("cacheDurationInSeconds")
                && !cacheConfigMap.isNull("cacheDurationInSeconds")
                ? cacheConfigMap.getLong("cacheDurationInSeconds")
                : 0L;
            final JSONObject cacheAttributes = cacheConfigMap.has("cacheAttributes")
                && !cacheConfigMap.isNull("cacheAttributes")
                ? cacheConfigMap.getJSONObject("cacheAttributes")
                : new JSONObject();
            builder.cacheConfig(new CacheConfig(cacheDuration, convertStringMap(cacheAttributes)));
        }

        if (configMap.has("edgeToEdgeDisplay") && !configMap.isNull("edgeToEdgeDisplay")) {
            hasConfig = true;
            builder.edgeToEdgeDisplay(configMap.getBoolean("edgeToEdgeDisplay"));
        }

        return hasConfig ? builder.build() : null;
    }

    private static JSONObject jsonFromRoktEvent(RoktEvent event) {
        JSONObject json = new JSONObject();
        try {
            if (event instanceof RoktEvent.ShowLoadingIndicator) {
                json.put("event", "ShowLoadingIndicator");
            } else if (event instanceof RoktEvent.HideLoadingIndicator) {
                json.put("event", "HideLoadingIndicator");
            } else if (event instanceof RoktEvent.InitComplete) {
                json.put("event", "InitComplete");
                json.put("success", ((RoktEvent.InitComplete) event).getSuccess());
            } else if (event instanceof RoktEvent.PlacementReady) {
                json.put("event", "PlacementReady");
                json.put("placementId", ((RoktEvent.PlacementReady) event).getIdentifier());
            } else if (event instanceof RoktEvent.PlacementInteractive) {
                json.put("event", "PlacementInteractive");
                json.put("placementId", ((RoktEvent.PlacementInteractive) event).getIdentifier());
            } else if (event instanceof RoktEvent.PlacementClosed) {
                json.put("event", "PlacementClosed");
                json.put("placementId", ((RoktEvent.PlacementClosed) event).getIdentifier());
            } else if (event instanceof RoktEvent.PlacementCompleted) {
                json.put("event", "PlacementCompleted");
                json.put("placementId", ((RoktEvent.PlacementCompleted) event).getIdentifier());
            } else if (event instanceof RoktEvent.PlacementFailure) {
                json.put("event", "PlacementFailure");
                String placementId = ((RoktEvent.PlacementFailure) event).getIdentifier();
                json.put("placementId", placementId != null ? placementId : JSONObject.NULL);
            } else if (event instanceof RoktEvent.OfferEngagement) {
                json.put("event", "OfferEngagement");
                json.put("placementId", ((RoktEvent.OfferEngagement) event).getIdentifier());
            } else if (event instanceof RoktEvent.PositiveEngagement) {
                json.put("event", "PositiveEngagement");
                json.put("placementId", ((RoktEvent.PositiveEngagement) event).getIdentifier());
            } else if (event instanceof RoktEvent.FirstPositiveEngagement) {
                json.put("event", "FirstPositiveEngagement");
                json.put("placementId", ((RoktEvent.FirstPositiveEngagement) event).getIdentifier());
            } else if (event instanceof RoktEvent.OpenUrl) {
                RoktEvent.OpenUrl openUrl = (RoktEvent.OpenUrl) event;
                json.put("event", "OpenUrl");
                json.put("placementId", openUrl.getIdentifier());
                json.put("url", openUrl.getUrl());
            } else if (event instanceof RoktEvent.CartItemInstantPurchase) {
                RoktEvent.CartItemInstantPurchase purchase = (RoktEvent.CartItemInstantPurchase) event;
                json.put("event", "CartItemInstantPurchase");
                json.put("placementId", purchase.getIdentifier());
                json.put("cartItemId", purchase.getCartItemId());
                json.put("catalogItemId", purchase.getCatalogItemId());
                json.put("currency", purchase.getCurrency());
                json.put("description", purchase.getDescription());
                json.put("linkedProductId", purchase.getLinkedProductId());
                json.put("totalPrice", purchase.getTotalPrice());
                json.put("quantity", purchase.getQuantity());
                json.put("unitPrice", purchase.getUnitPrice());
            } else {
                json.put("event", event.getClass().getSimpleName());
            }
        } catch (JSONException e) {
            Logger.warning(e, "Failed to serialize RoktEvent");
            return null;
        }
        return json;
    }

    private static Map<String, String> convertStringMap(final JSONObject jsonObject) throws JSONException {
        Map<String, String> stringMap = new HashMap<>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            stringMap.put(key, jsonObject.getString(key));
        }
        return stringMap;
    }
}
