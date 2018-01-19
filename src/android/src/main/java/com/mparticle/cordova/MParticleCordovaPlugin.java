package com.mparticle.cordova;

import android.util.Log;

import com.mparticle.MParticle;
import com.mparticle.MParticleOptions;
import com.mparticle.commerce.CommerceEvent;
import com.mparticle.commerce.Impression;
import com.mparticle.commerce.Product;
import com.mparticle.commerce.TransactionAttributes;
import com.mparticle.commerce.Promotion;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static android.R.attr.type;

public class MParticleCordovaPlugin extends CordovaPlugin {

    private final static String LOG_TAG = "MParticleCordovaPlugin";

    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        
        if (action.equals("start")) {
           String key = null;
           String secret = null;
           if (args != null) {
               key = args.getString(0);
               secret = args.getString(1);
           }
           MParticleOptions options = MParticleOptions.builder(this.cordova.getActivity().getApplication())
                              .credentials(key, secret).build();
           Mparticle.start(options);
        } else if (action.equals("logEvent")) {
            logEvent(args);
        } else if (action.equals("logCommerceEvent")) {
            logCommerceEvent(args);
        } else if (action.equals("logScreenEvent")) {
            logScreen(args);
        } else if (action.equals("setUserAttribute")) {
            setUserAttribute(args);
        } else if (action.equals("setUserAttributeArray")) {
            setUserAttributeArray(args);
        } else if (action.equals("setUserTag")) {
            setUserTag(args);
        } else if (action.equals("removeUserAttribute")) {
            removeUserAttribute(args);
        } else if (action.equals("setUserIdentity")) {
            setUserIdentity(args);
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
        MParticle.getInstance().logEvent(name, eventType, attributes);
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
        final String userAttribute = args.getString(0);
        final String value = args.getString(1);
        MParticle.getInstance().setUserAttribute(userAttribute, value);
    }

    public void setUserAttributeArray(final JSONArray args) throws JSONException {
        final String key = args.getString(0);
        final JSONArray values = args.getJSONArray(1);
        if (values != null) {
            List<String> list = new ArrayList<String>();
            for (int i = 0; i < values.length(); ++i) {
                list.add(values.getString(i));
            }
            MParticle.getInstance().setUserAttributeList(key, list);
        }
    }

    public void setUserTag(final JSONArray args) throws JSONException {
        final String tag = args.getString(0);
        MParticle.getInstance().setUserTag(tag);
    }

    public void removeUserAttribute(final JSONArray args) throws JSONException {
        final String key = args.getString(0);
        MParticle.getInstance().removeUserAttribute(key);
    }

    public void setUserIdentity(final JSONArray args) throws JSONException {
        final String identity = args.getString(0);
        int type = args.getInt(1);
        MParticle.IdentityType identityType = MParticle.IdentityType.parseInt(type);
        MParticle.getInstance().setUserIdentity(identity, identityType);
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

