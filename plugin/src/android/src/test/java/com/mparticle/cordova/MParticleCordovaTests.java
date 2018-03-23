package com.mparticle.cordova;

import android.provider.ContactsContract;

import com.mparticle.MPEvent;
import com.mparticle.MParticle;
import com.mparticle.commerce.CommerceEvent;
import com.mparticle.commerce.Product;
import com.mparticle.identity.*;

import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.Mockito;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;


public class MParticleCordovaTests {

    @Before
    public void setup() {
        MParticle.setInstance(Mockito.mock(MParticle.class));
        Mockito.when(MParticle.getInstance().getEnvironment()).thenReturn(MParticle.Environment.Production);
    }

    private static int IntFromEventType(MParticle.EventType eventType) {
        switch (eventType) {
            case Navigation:
                return 1;
            case Location:
                return 2;
            case Search:
                return 3;
            case Transaction:
                return 4;
            case UserContent:
                return 5;
            case UserPreference:
                return 6;
            case Social:
                return 7;
            default:
                return 8; // Other
        }
    }

    private static int IntFromProductActionType(String productActionType) {
        switch (productActionType) {
            case Product.ADD_TO_CART:
                return 1;
            case Product.REMOVE_FROM_CART:
                return 2;
            case Product.CHECKOUT:
                return 3;
            case Product.CHECKOUT_OPTION:
                return 4;
            case Product.CLICK:
                return 5;
            case Product.DETAIL:
                return 6;
            case Product.PURCHASE:
                return 7;
            case Product.REFUND:
                return 8;
            case Product.ADD_TO_WISHLIST:
                return 9;
            default:
                return 10; // Product.REMOVE_FROM_WISHLIST
        }
    }

    @Test
    public void testLogEvent() throws Exception {
        String eventName = "Test event";
        MParticle.EventType eventType = MParticle.EventType.Other;
        int type = IntFromEventType(eventType);
        JSONObject info = new JSONObject();
        Map<String, String> attributes = new HashMap();
        attributes.put("Test key", "Test value");
        info.put("Test key", "Test value");
        MPEvent event = new MPEvent.Builder(eventName, eventType)
                .info(attributes)
                .build();

        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
        JSONArray array = new JSONArray();
        array.put(eventName);
        array.put(type);
        array.put(info);

        plugin.logEvent(array);

        Mockito.verify(MParticle.getInstance()).logEvent(event);
    }

    @Test
    public void testLogCommerceEvent() throws Exception {
        JSONObject jsonCommerceEvent = new JSONObject();

        JSONObject jsonProduct = new JSONObject();
        jsonProduct.put("name", "Test product");
        jsonProduct.put("sku", "123");
        jsonProduct.put("price", 19.99);

        JSONArray products = new JSONArray();
        products.put(jsonProduct);


        JSONObject jsonTransactionAttributes = new JSONObject();
        jsonTransactionAttributes.put("id", "Test transaction id");

        jsonCommerceEvent.put("productActionType", IntFromProductActionType(Product.ADD_TO_CART));
        jsonCommerceEvent.put("products", products);
        jsonCommerceEvent.put("transactionAttributes", jsonTransactionAttributes);

        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
        JSONArray array = new JSONArray();
        array.put(jsonCommerceEvent);

        plugin.logCommerceEvent(array);

        ArgumentCaptor<CommerceEvent> commerceEventArgumentCaptor = ArgumentCaptor.forClass(CommerceEvent.class);
        Mockito.verify(MParticle.getInstance()).logEvent(commerceEventArgumentCaptor.capture());
        CommerceEvent loggedEvent = commerceEventArgumentCaptor.getValue();
        Product product1 = loggedEvent.getProducts().get(0);
        assertEquals(product1.getName(), "Test product");
        assertEquals(product1.getSku(), "123");
        assertEquals(product1.getUnitPrice(), 19.99, 0.0001);
    }

//    @Test
//    public void testSetUserAttribute() throws Exception {
//        String key = "Test key";
//        String value = "Test value";
//        MParticleUser user = MParticle.getInstance().Identity().getUser(Long.parseLong("12345"));
//
//        if (user != null) {
//            MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
//            JSONArray array = new JSONArray();
//            array.put(user.getId());
//            array.put(key);
//            array.put(value);
//
//            plugin.setUserAttribute(array);
//
//            Mockito.verify(user.setUserAttribute("Test key", "Test value"));
//        }
//    }
//
//    @Test
//    public void testSetUserAttributeArray() throws Exception {
//        String key = "Test key";
//        String value1 = "Test value 1";
//        String value2 = "Test value 2";
//        JSONArray valuesArray = new JSONArray();
//        valuesArray.put(value1);
//        valuesArray.put(value2);
//        MParticleUser user = MParticle.getInstance().Identity().getCurrentUser();
//
//        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
//        JSONArray array = new JSONArray();
//        array.put(user.getId());
//        array.put(key);
//        array.put(valuesArray);
//
//        plugin.setUserAttributeArray(array);
//
//        List list = new ArrayList();
//        list.add("Test value 1");
//        list.add("Test value 2");
//        Mockito.verify(user.setUserAttributeList("Test key", list));
//    }
//
//    @Test
//    public void testSetUserTag() throws Exception {
//        String key = "Test key";
//        MParticleUser user = MParticle.getInstance().Identity().getCurrentUser();
//
//        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
//        JSONArray array = new JSONArray();
//        array.put(user.getId());
//        array.put(key);
//
//        plugin.setUserTag(array);
//
//        Mockito.verify(user.setUserTag("Test key"));
//    }
//
//    @Test
//    public void testRemoveUserAttribute() throws Exception {
//        String key = "Test key";
//        MParticleUser user = MParticle.getInstance().Identity().getCurrentUser();
//
//        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
//        JSONArray array = new JSONArray();
//        array.put(user.getId());
//        array.put(key);
//
//        plugin.removeUserAttribute(array);
//
//        Mockito.verify(user.removeUserAttribute("Test key"));
//    }
//
//    @Test
//    public void testSetUserIdentity() throws Exception {
//        String identity = "12345";
//        int type = MParticle.IdentityType.CustomerId.getValue();
//        MParticleUser user = MParticle.getInstance().Identity().getCurrentUser();
//        IdentityApiRequest request = IdentityApiRequest.withEmptyUser()
//            .userIdentity(MParticle.IdentityType.CustomerId, "12345")
//            .build();
//
//        MParticleCordovaPlugin plugin = new MParticleCordovaPlugin();
//        JSONArray array = new JSONArray();
//        array.put(user.getId());
//        array.put(identity);
//        array.put(type);
//
//        plugin.setUserAttribute(array);
//
//        Mockito.verify(MParticle.getInstance().Identity().modify(request));
//    }
}