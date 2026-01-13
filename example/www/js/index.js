document.getElementById("selectPlacementsBtn").addEventListener('click', selectPlacements, false);
document.getElementById("setUserAttributeBtn").addEventListener('click', setUserAttribute, false);
document.getElementById("identifyUserBtn").addEventListener('click', identifyUser, false);
document.getElementById("modifyUserBtn").addEventListener('click', modifyUser, false);
document.getElementById("logEventBtn").addEventListener('click', logEvent, false);
document.getElementById("logScreenEventBtn").addEventListener('click', logScreenEvent, false);
document.getElementById("logCommerceEventBtn").addEventListener('click', logCommerceEvent, false);
document.getElementById("removeUserAttributeBtn").addEventListener('click', removeUserAttribute, false);
document.getElementById("getUserIdentitiesBtn").addEventListener('click', getUserIdentities, false);
document.getElementById("setUserTagBtn").addEventListener('click', setUserTag, false);
document.getElementById("setATTStatusBtn").addEventListener('click', setATTStatus, false);
document.getElementById("loginBtn").addEventListener('click', login, false);
document.getElementById("logoutBtn").addEventListener('click', logout, false);
document.getElementById("trackConversionBtn").addEventListener('click', trackConversion, false);

var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        console.log('MParticleCordova Plugin Example: Device ready');
        this.receivedEvent('deviceready');
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

function selectPlacements() {
    console.log('MParticleCordova Plugin Example: Selecting Placements');
    
    var attributes = {
        'email': 'j.smith@example.com',
        'firstname': 'Jenny',
        'lastname': 'Smith',
        'billingzipcode': '90210',
        'confirmationref': '54321',
        'country': 'US'
    };

    var config = {
        colorMode: mparticle.Rokt.ColorMode.SYSTEM,
        cacheConfig: {
            cacheDurationInSeconds: 5400,
            cacheAttributes: {}
        },
        edgeToEdgeDisplay: true
    };

    mparticle.Rokt.selectPlacements(
        'MSDKOverlayLayout',
        attributes,
        config
    );
}

function setUserAttribute() {
    console.log('MParticleCordova Plugin Example: Setting User Attribute');
    
    var identity = new mparticle.Identity();

    identity.getCurrentUser(function(userID) {
        var user = new mparticle.User(userID);

        // Once you have successfully set the current user to `currentUser`, you can set user attributes with:
        user.setUserAttribute('custom-attribute-name', 'custom-attribute-value');
        // Note: all user attributes (including list attributes and tags) must have distinct names.

        // Rokt recommends setting as many of the following user attributes as possible:
        user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Jane');
        user.setUserAttribute(mparticle.UserAttributeType.LastName, 'Smith');

        // Phone numbers can be formatted either as '1234567890', or '+1 (234) 567-8901'
        user.setUserAttribute(mparticle.UserAttributeType.MobileNumber, '3125551515');
        user.setUserAttribute(mparticle.UserAttributeType.Age, '33');
        user.setUserAttribute(mparticle.UserAttributeType.Gender, 'M');
        user.setUserAttribute(mparticle.UserAttributeType.City, 'Brooklyn');
        user.setUserAttribute(mparticle.UserAttributeType.State, 'NY');
        user.setUserAttribute(mparticle.UserAttributeType.Zipcode, '123456');

        user.setUserAttribute('dob', 'yyyymmdd');
        user.setUserAttribute('title', 'Mr');
        user.setUserAttribute('language', 'en');
        user.setUserAttribute('value', '52.25');
        user.setUserAttribute('predictedltv', '136.23');

        // You can create a user attribute to contain a list of values
        user.setUserAttributeArray('favorite-genres', ['documentary', 'comedy', 'romance', 'drama']);
    });
}

function identifyUser() {
    console.log('MParticleCordova Plugin Example: Identifying User');
    
    var identifyRequest = new mparticle.IdentityRequest();
    identifyRequest.setEmail('j.smith@example.com');
    
    var identity = new mparticle.Identity();
    
    identity.identify(identifyRequest, function (userID) {
        console.log('Identify Success: ' + userID);
    });
}

function modifyUser() {
    console.log('MParticleCordova Plugin Example: Modifying User');
    
    var identity = new mparticle.Identity();

    var modifyRequest = new mparticle.IdentityRequest();
    modifyRequest.setEmail('k.smith@example.com');

    identity.modify(modifyRequest, function (userID) {
        console.log('Modify Success: ' + userID);
    });
}

function logEvent() {
    console.log('MParticleCordova Plugin Example: Logging Event');
    mparticle.logEvent('Cordova Test event', mparticle.EventType.Other, {'Cordova Test key': 'Cordova Test value'});
}

function logScreenEvent() {
    console.log('MParticleCordova Plugin Example: Logging Screen Event');
    
    mparticle.logScreenEvent('homepage', { 'custom-attribute': 'custom-value' });
}

function logCommerceEvent() {
    console.log('MParticleCordova Plugin Example: Logging Commerce Event');
    
    console.log('MParticleCordova Plugin Example: Product');
    var product = new mparticle.Product('CordovaTest viewed product', 5678, 29.99);
    var impression = new mparticle.Impression('CordovaTest impression list name', [product]);
    var event = mparticle.CommerceEvent.createImpressionEvent([impression]);
    mparticle.logCommerceEvent(event);
}

function removeUserAttribute() {
    console.log('MParticleCordova Plugin Example: Removing User Attribute');
    var identity = new mparticle.Identity();

    identity.getCurrentUser(function(userID) {
        var user = new mparticle.User(userID);

        user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Cordova Test first name');
        user.setUserAttributeArray(mparticle.UserAttributeType.FirstName, ['Cordova Test value 1', 'Cordova Test value 2']);

        user.removeUserAttribute(mparticle.UserAttributeType.FirstName);
    });
}

function getUserIdentities() {
    console.log('MParticleCordova Plugin Example: Getting User Identities');
    var identity = new mparticle.Identity();

    identity.getCurrentUser(function(userID) {
        var user = new mparticle.User(userID);

        user.getUserIdentities(function(userIdenitities) {
            console.log('User userIdentities: ' + userIdenitities);
        });
    });
}

function setUserTag() {
    console.log('MParticleCordova Plugin Example: Setting User Tag');
    var identity = new mparticle.Identity();

    identity.getCurrentUser(function(userID) {
        var user = new mparticle.User(userID);
        user.setUserTag('Cordova testUser');
    });
}

function setATTStatus() {
    console.log('MParticleCordova Plugin Example: Setting ATT Status');
    mparticle.setATTStatus(mparticle.MPATTStatus.Authorized, null);
}

function login() {
    console.log('MParticleCordova Plugin Example: Logging In');

    var request = new mparticle.IdentityRequest();
    request.setEmail('j.smith@example.com');

    identity.login(request, function (userID) {
        console.log('Login Success: ' + userID);
    });
}

function logout() {

    console.log('MParticleCordova Plugin Example: Logging Out');
    
    var identity = new mparticle.Identity();
    var logoutRequest = new mparticle.IdentityRequest();

    identity.logout(logoutRequest, function (userID) {
        console.log('Logout Success: ' + userID);
    });
}

function trackConversion() {
    console.log('MParticleCordova Plugin Example: Tracking Conversion');

    var identity = new mparticle.Identity();

    identity.getCurrentUser(function(userID) {
        var user = new mparticle.User(userID);

        user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Jane');
        user.setUserAttribute(mparticle.UserAttributeType.LastName, 'Smith');
        user.setUserAttribute(mparticle.UserAttributeType.Zipcode, '123456');
        user.setUserAttribute(mparticle.UserAttributeType.MobileNumber, '3125551515');
    });
    
    mparticle.logEvent(
        'conversion',
        mparticle.EventType.Transaction,
        {
            'conversiontype': 'signup', // type of conversion
            'confirmationref': '54321', // Transaction ID / Order ID
            'amount': '',               // Transaction amount e.g. 300.5
            'currency': '',             // Transaction currency e.g. USD
            // You can track your own custom event attributes!
            'CUSTOM_EVENT_ATTRIBUTE_NAME' : 'CUSTOM_EVENT_ATTRIBUTE_VALUE'
        }
    );
}

app.initialize();
