package com.mparticle.cordova;

import android.util.Log;

import com.mparticle.MPEvent;
import com.mparticle.MParticle;
import com.mparticle.commerce.CommerceEvent;
import com.mparticle.commerce.Impression;
import com.mparticle.commerce.Product;
import com.mparticle.commerce.TransactionAttributes;
import com.mparticle.commerce.Promotion;
import com.mparticle.identity.*;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static android.R.attr.type;

public class MParticleCordovaPlugin extends CordovaPlugin {

    private final static String LOG_TAG = "MParticleCordovaPlugin";

    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("logEvent")) {
            logEvent(args);
        } else if (action.equals("logCommerceEvent")) {
            logCommerceEvent(args);
        } else if (action.equals("logScreenEvent")) {
            logScreenEvent(args);
        } else if (action.equals("setUserAttribute")) {
            setUserAttribute(args);
        } else if (action.equals("setUserAttributeArray")) {
            setUserAttributeArray(args);
        } else if (action.equals("setUserTag")) {
            setUserTag(args);
        } else if (action.equals("removeUserAttribute")) {
            removeUserAttribute(args);
        } else if (action.equals("identify")) {
            identify(args, callbackContext);
            return true;
        } else if (action.equals("login")) {
            login(args, callbackContext);
            return true;
        } else if (action.equals("logout")) {
            logout(args, callbackContext);
            return true;
        } else if (action.equals("modify")) {
            modify(args, callbackContext);
            return true;
        } else if (action.equals("getCurrentUser")) {
            getCurrentUser(args, callbackContext);
            return true;
        } else if (action.equals("getUserIdentities")) {
            getUserIdentities(args, callbackContext);
            return true;
        } else {
            return false;
        }

        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, args.getString(0)));
        return true;
    }

    public void logEvent(final JSONArray args) throws JSONException {
        final String name = args.getString(0);
        int type = args.getInt(1);
        JSONObject attributesMap = args.getJSONObject(2);
        Map<String, String> attributes = ConvertStringMap(attributesMap);
        MParticle.EventType eventType = ConvertEventType(type);

        MPEvent event = new MPEvent.Builder(name, eventType)
                .info(attributes)
                .build();

        MParticle.getInstance().logEvent(event);
    }

    public void logCommerceEvent(final JSONArray args) throws JSONException {
        final JSONObject map = args.getJSONObject(0);
        if (map != null) {
            CommerceEvent commerceEvent = ConvertCommerceEvent(map);
            MParticle.getInstance().logEvent(commerceEvent);
        }
    }

    public void logScreenEvent(final JSONArray args) throws JSONException {
        final String event = args.getString(0);
        final JSONObject attributesMap = args.getJSONObject(1);
        Map<String, String> attributes = ConvertStringMap(attributesMap);

        MParticle.getInstance().logScreen(event, attributes);
    }

    public void setUserAttribute(final JSONArray args) throws JSONException {
        final String userId = args.getString(0);
        final String userAttribute = args.getString(1);
        final String value = args.getString(2);
        MParticleUser selectedUser = MParticle.getInstance().Identity().getUser(Long.parseLong(userId));

        if (selectedUser != null) {
            selectedUser.setUserAttribute(userAttribute, value);
        }
    }

    public void setUserAttributeArray(final JSONArray args) throws JSONException {
        final String userId = args.getString(0);
        final String key = args.getString(1);
        final JSONArray values = args.getJSONArray(2);
        MParticleUser selectedUser = MParticle.getInstance().Identity().getUser(Long.parseLong(userId));

        if (selectedUser != null && values != null) {
            List<String> list = new ArrayList<String>();
            for (int i = 0; i < values.length(); ++i) {
                list.add(values.getString(i));
            }
            selectedUser.setUserAttributeList(key, list);
        }
    }

    public void setUserTag(final JSONArray args) throws JSONException {
        final String userId = args.getString(0);
        final String tag = args.getString(1);
        MParticleUser selectedUser = MParticle.getInstance().Identity().getUser(Long.parseLong(userId));

        if (selectedUser != null) {
            selectedUser.setUserTag(tag);
        }
    }

    public void removeUserAttribute(final JSONArray args) throws JSONException {
        final String userId = args.getString(0);
        final String key = args.getString(1);
        MParticleUser selectedUser = MParticle.getInstance().Identity().getUser(Long.parseLong(userId));

        if (selectedUser != null) {
            selectedUser.removeUserAttribute(key);
        }
    }

    public void identify(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject map = args.getJSONObject(0);
        if (map != null) {
            IdentityApiRequest request = ConvertIdentityAPIRequest(map);
            MParticle.getInstance().Identity().identify(request)
                    .addFailureListener(new TaskFailureListener() {
                        @Override
                        public void onFailure(IdentityHttpResponse identityHttpResponse) {
                            final JSONObject cordovaError = new JSONObject();

                            try {
                                cordovaError.put("httpCode", identityHttpResponse.getHttpCode());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            try {
                                cordovaError.put("message", identityHttpResponse.toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, cordovaError);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    })
                    .addSuccessListener(new TaskSuccessListener() {
                        @Override
                        public void onSuccess(IdentityApiResult identityApiResult) {
                            MParticleUser user = identityApiResult.getUser();
                            String userID = Long.toString(user.getId());

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userID);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    });
        }
    }

    public void login(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject map = args.getJSONObject(0);
        if (map != null) {
            IdentityApiRequest request = ConvertIdentityAPIRequest(map);
            MParticle.getInstance().Identity().login(request)
                    .addFailureListener(new TaskFailureListener() {
                        @Override
                        public void onFailure(IdentityHttpResponse identityHttpResponse) {
                            final JSONObject cordovaError = new JSONObject();

                            try {
                                cordovaError.put("httpCode", identityHttpResponse.getHttpCode());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            try {
                                cordovaError.put("message", identityHttpResponse.toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, cordovaError);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    })
                    .addSuccessListener(new TaskSuccessListener() {
                        @Override
                        public void onSuccess(IdentityApiResult identityApiResult) {
                            MParticleUser user = identityApiResult.getUser();
                            String userID = Long.toString(user.getId());

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userID);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    });
        }
    }

    public void logout(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject map = args.getJSONObject(0);
        if (map != null) {
            IdentityApiRequest request = ConvertIdentityAPIRequest(map);
            MParticle.getInstance().Identity().logout(request)
                    .addFailureListener(new TaskFailureListener() {
                        @Override
                        public void onFailure(IdentityHttpResponse identityHttpResponse) {
                            final JSONObject cordovaError = new JSONObject();

                            try {
                                cordovaError.put("httpCode", identityHttpResponse.getHttpCode());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            try {
                                cordovaError.put("message", identityHttpResponse.toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, cordovaError);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    })
                    .addSuccessListener(new TaskSuccessListener() {
                        @Override
                        public void onSuccess(IdentityApiResult identityApiResult) {
                            MParticleUser user = identityApiResult.getUser();
                            String userID = Long.toString(user.getId());

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userID);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    });
        }
    }

    public void modify(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject map = args.getJSONObject(0);
        if (map != null) {
            IdentityApiRequest request = ConvertIdentityAPIRequest(map);
            MParticle.getInstance().Identity().modify(request)
                    .addFailureListener(new TaskFailureListener() {
                        @Override
                        public void onFailure(IdentityHttpResponse identityHttpResponse) {
                            final JSONObject cordovaError = new JSONObject();

                            try {
                                cordovaError.put("httpCode", identityHttpResponse.getHttpCode());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            try {
                                cordovaError.put("message", identityHttpResponse.toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, cordovaError);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    })
                    .addSuccessListener(new TaskSuccessListener() {
                        @Override
                        public void onSuccess(IdentityApiResult identityApiResult) {
                            MParticleUser user = identityApiResult.getUser();
                            String userID = Long.toString(user.getId());

                            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userID);
                            callbackContext.sendPluginResult(pluginResult);
                        }
                    });
        }
    }

    public void getCurrentUser(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        MParticleUser user = MParticle.getInstance().Identity().getCurrentUser();
        if (user != null) {
            String userID = Long.toString(user.getId());
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userID);
            callbackContext.sendPluginResult(pluginResult);
        }
    }

    public void getUserIdentities(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        String userId = args.getString(0);
        MParticleUser selectedUser = MParticle.getInstance().Identity().getUser(Long.parseLong(userId));
        JSONObject userIdentities = new JSONObject(ConvertFromUserIdentities(selectedUser.getUserIdentities()));

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, userIdentities);
        callbackContext.sendPluginResult(pluginResult);
    }

    private static IdentityApiRequest ConvertIdentityAPIRequest(JSONObject map) throws JSONException {
        IdentityApiRequest.Builder identityRequest = IdentityApiRequest.withEmptyUser();

        Map<MParticle.IdentityType, String> userIdentities = ConvertUserIdentities(map);
        identityRequest.userIdentities(userIdentities);

        return identityRequest.build();
    }

    private static CommerceEvent ConvertCommerceEvent(JSONObject map) throws JSONException {
        Boolean isProductAction = map.has("productActionType");
        Boolean isPromotion = map.has("promotionActionType");
        Boolean isImpression = map.has("impressions");

        if (!isProductAction && !isPromotion && !isImpression) {
            Log.e(LOG_TAG, "Invalid commerce event:" + map.toString());
            return null;
        }

        CommerceEvent.Builder builder = null;

        if (isProductAction) {
            int productActionInt = map.getInt("productActionType");
            String productAction = ConvertPromotionActionType(productActionInt);
            JSONArray productsArray = map.getJSONArray("products");
            JSONObject productMap = productsArray.getJSONObject(0);
            Product product = ConvertProduct(productMap);
            JSONObject transactionAttributesMap = map.getJSONObject("transactionAttributes");
            TransactionAttributes transactionAttributes = ConvertTransactionAttributes(transactionAttributesMap);
            builder = new CommerceEvent.Builder(productAction, product).transactionAttributes(transactionAttributes);

            for (int i = 1; i < productsArray.length(); ++i) {
                productMap = productsArray.getJSONObject(i);
                product = ConvertProduct(productMap);
                builder.addProduct(product);
            }
        }
        else if (isPromotion) {
            int promotionActionTypeInt = map.getInt("promotionActionType");
            String promotionAction = ConvertPromotionActionType(promotionActionTypeInt);
            JSONArray promotionsJSONArray = map.getJSONArray("promotions");
            JSONObject promotionMap = promotionsJSONArray.getJSONObject(0);
            Promotion promotion = ConvertPromotion(promotionMap);
            builder = new CommerceEvent.Builder(promotionAction, promotion);

            for (int i = 0; i < promotionsJSONArray.length(); ++i) {
                promotionMap = promotionsJSONArray.getJSONObject(i);
                promotion = ConvertPromotion(promotionMap);
                builder.addPromotion(promotion);
            }
        }
        else {
            JSONArray impressionsArray = map.getJSONArray("impressions");
            JSONObject impressionMap = impressionsArray.getJSONObject(0);
            Impression impression = ConvertImpression(impressionMap);
            builder = new CommerceEvent.Builder(impression);

            for (int i = 0; i < impressionsArray.length(); ++i) {
                impressionMap = impressionsArray.getJSONObject(i);
                impression = ConvertImpression(impressionMap);
                builder.addImpression(impression);
            }
        }

        return builder.build();
    }

    private static Product ConvertProduct(JSONObject map) throws JSONException {
        String name = map.getString("name");
        String sku = map.getString("sku");
        double unitPrice = map.getDouble("price");
        Product.Builder builder = new Product.Builder(name, sku, unitPrice);

        if (map.has("brand")) {
            String brand = map.getString("brand");
            builder.brand(brand);
        }

        if (map.has("category")) {
            String category = map.getString("category");
            builder.category(category);
        }

        if (map.has("couponCode")) {
            String couponCode = map.getString("couponCode");
            builder.couponCode(couponCode);
        }

        if (map.has("customAttributes")) {
            JSONObject customAttributesMap = map.getJSONObject("customAttributes");
            Map<String, String> customAttributes = ConvertStringMap(customAttributesMap);
            builder.customAttributes(customAttributes);
        }

        if (map.has("position")) {
            int position = map.getInt("position");
            builder.position(position);
        }

        if (map.has("quantity")) {
            double quantity = map.getDouble("quantity");
            builder.quantity(quantity);
        }

        return builder.build();
    }

    private static TransactionAttributes ConvertTransactionAttributes(JSONObject map) throws JSONException {
        if (!map.has("transactionId")) {
            return null;
        }

        TransactionAttributes transactionAttributes = new TransactionAttributes(map.getString("transactionId"));

        if (map.has("affiliation")) {
            transactionAttributes.setAffiliation(map.getString("affiliation"));
        }

        if (map.has("revenue")) {
            transactionAttributes.setRevenue(map.getDouble("revenue"));
        }

        if (map.has("shipping")) {
            transactionAttributes.setShipping(map.getDouble("shipping"));
        }

        if (map.has("tax")) {
            transactionAttributes.setTax(map.getDouble("tax"));
        }

        if (map.has("couponCode")) {
            transactionAttributes.setCouponCode(map.getString("couponCode"));
        }

        return transactionAttributes;
    }

    private static Promotion ConvertPromotion(JSONObject map) throws JSONException {
        Promotion promotion = new Promotion();

        if (map.has("id")) {
            promotion.setId(map.getString("id"));
        }

        if (map.has("name")) {
            promotion.setName(map.getString("name"));
        }

        if (map.has("creative")) {
            promotion.setCreative(map.getString("creative"));
        }

        if (map.has("position")) {
            promotion.setPosition(map.getString("position"));
        }

        return promotion;
    }

    private static Impression ConvertImpression(JSONObject map) throws JSONException {

        String listName = map.getString("impressionListName");
        JSONArray productsArray = map.getJSONArray("products");
        JSONObject productMap = productsArray.getJSONObject(0);
        Product product = ConvertProduct(productMap);
        Impression impression = new Impression(listName, product);

        for (int i = 1; i < productsArray.length(); ++i) {
            productMap = productsArray.getJSONObject(i);
            product = ConvertProduct(productMap);
            impression.addProduct(product);
        }

        return impression;
    }

    private static Map<String, String> ConvertStringMap(JSONObject jsonObject) throws JSONException {
        Map<String, String> map = new HashMap();

        if (jsonObject != null) {
            Iterator<String> iterator = jsonObject.keys();
            while (iterator.hasNext()) {
                String key = iterator.next();
                map.put(key, jsonObject.getString(key));
            }
        }

        return map;
    }

    private static Map<MParticle.IdentityType, String> ConvertUserIdentities(JSONObject jsonObject) throws JSONException {
        Map<MParticle.IdentityType, String> map = new HashMap();
        if (jsonObject != null) {
            Map<String, String> stringMap = ConvertStringMap(jsonObject);
            for (Map.Entry<String, String> entry : stringMap.entrySet())
            {
                MParticle.IdentityType identity = ConvertIdentityType(entry.getKey());
                String value = entry.getValue();
                map.put(identity, value);
            }
        }

        return map;
    }

    private static Map<String, String> ConvertFromUserIdentities(Map<MParticle.IdentityType, String> map) {
        Map<String, String> resultMap = new HashMap();

        for (MParticle.IdentityType key : map.keySet()) {
            String stringKey = ConvertFromIdentityType(key);
            String value = map.get(key);
            resultMap.put(stringKey, value);
        }

        return resultMap;
    }

    private static String ConvertFromIdentityType(MParticle.IdentityType val) {
        if (val.equals(MParticle.IdentityType.CustomerId)) {
            return "customerId";
        } else if (val.equals(MParticle.IdentityType.Facebook)) {
            return "facebook";
        } else if (val.equals(MParticle.IdentityType.Twitter)) {
            return "twitter";
        } else if (val.equals(MParticle.IdentityType.Google)) {
            return "google";
        } else if (val.equals(MParticle.IdentityType.Microsoft)) {
            return "microsoft";
        } else if (val.equals(MParticle.IdentityType.Yahoo)) {
            return "yahoo";
        } else if (val.equals(MParticle.IdentityType.Email)) {
            return "email";
        } else if (val.equals(MParticle.IdentityType.Alias)) {
            return "alias";
        } else if (val.equals(MParticle.IdentityType.FacebookCustomAudienceId)) {
            return "facebookCustom";
        } else if (val.equals(MParticle.IdentityType.Other2)) {
            return "other2";
        } else if (val.equals(MParticle.IdentityType.Other3)) {
            return "other3";
        } else if (val.equals(MParticle.IdentityType.Other4)) {
            return "other4";
        } else {
            return "other";
        }
    }

    private static MParticle.IdentityType ConvertIdentityType(String val) {
        if (val.equals("customerId")) {
            return MParticle.IdentityType.CustomerId;
        } else if (val.equals("facebook")) {
            return MParticle.IdentityType.Facebook;
        } else if (val.equals("twitter")) {
            return MParticle.IdentityType.Twitter;
        } else if (val.equals("google")) {
            return MParticle.IdentityType.Google;
        } else if (val.equals("microsoft")) {
            return MParticle.IdentityType.Microsoft;
        } else if (val.equals("yahoo")) {
            return MParticle.IdentityType.Yahoo;
        } else if (val.equals("email")) {
            return MParticle.IdentityType.Email;
        } else if (val.equals("alias")) {
            return MParticle.IdentityType.Alias;
        } else if (val.equals("facebookCustom")) {
            return MParticle.IdentityType.FacebookCustomAudienceId;
        } else if (val.equals("other2")) {
            return MParticle.IdentityType.Other2;
        } else if (val.equals("other3")) {
            return MParticle.IdentityType.Other3;
        } else if (val.equals("other4")) {
            return MParticle.IdentityType.Other4;
        } else {
            return MParticle.IdentityType.Other;
        }
    }

    private static MParticle.EventType ConvertEventType(int eventType) throws JSONException {
        switch (eventType) {
            case 1:
                return MParticle.EventType.Navigation;
            case 2:
                return MParticle.EventType.Location;
            case 3:
                return MParticle.EventType.Search;
            case 4:
                return MParticle.EventType.Transaction;
            case 5:
                return MParticle.EventType.UserContent;
            case 6:
                return MParticle.EventType.UserPreference;
            case 7:
                return MParticle.EventType.Social;
            default:
                return MParticle.EventType.Other;
        }
    }

    private static String ConvertProductActionType(int productActionType)  throws JSONException {
        switch (productActionType) {
            case 1:
                return Product.ADD_TO_CART;
            case 2:
                return Product.REMOVE_FROM_CART;
            case 3:
                return Product.CHECKOUT;
            case 4:
                return Product.CHECKOUT_OPTION;
            case 5:
                return Product.CLICK;
            case 6:
                return Product.DETAIL;
            case 7:
                return Product.PURCHASE;
            case 8:
                return Product.REFUND;
            case 9:
                return Product.ADD_TO_WISHLIST;
            default:
                return Product.REMOVE_FROM_WISHLIST;
        }
    }

    private static String ConvertPromotionActionType(int promotionActionType) {
        switch (promotionActionType) {
            case 0:
                return Promotion.VIEW;
            default:
                return Promotion.CLICK;
        }
    }
}

