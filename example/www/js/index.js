document.getElementById("selectPlacementsBtn").addEventListener('click', selectPlacements, false);

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
        mparticle.logEvent('Cordova Test event', mparticle.EventType.Other, {'Cordova Test key': 'Cordova Test value'});

        console.log('MParticleCordova Plugin Example: Product');
        var product = new mparticle.Product('CordovaTest viewed product', 5678, 29.99);
        var impression = new mparticle.Impression('CordovaTest impression list name', [product]);
        var event = mparticle.CommerceEvent.createImpressionEvent([impression]);
        mparticle.logCommerceEvent(event);

        console.log('MParticleCordova Plugin Example: Screen');
        mparticle.logScreenEvent('Test screen', { 'Test key': 'Test value' });

        mparticle.setATTStatus(mparticle.MPATTStatus.Authorized, null);

        console.log('MParticleCordova Plugin Example: Identity');
        var identity = new mparticle.Identity();

        identity.getCurrentUser(function(userID) {
            var user = new mparticle.User(userID);

            user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Cordova Test first name');
            user.setUserAttributeArray(mparticle.UserAttributeType.FirstName, ['Cordova Test value 1', 'Cordova Test value 2']);
            user.setUserTag('Cordova testUser');
            user.removeUserAttribute(mparticle.UserAttributeType.FirstName);
            user.getUserIdentities(function(userIdenitities) {
                console.log('User userIdentities: ' + userIdenitities);
            });
        });

        var request = new mparticle.IdentityRequest();
        request.setEmail('cordova123@gmail.com');

        identity.login(request, function (userID) {
            console.log('Login Success: ' + userID);
        });

        identity.identify(request, function (userID) {
            console.log('Identify Success: ' + userID);
        });

        var modifyRequest = new mparticle.IdentityRequest();
        modifyRequest.setEmail('tester@gmail.com');

        identity.modify(modifyRequest, function (userID) {
            console.log('Modify Success: ' + userID);
        });

        console.log('MParticleCordova Plugin Example: Logout');
        var logoutRequest = new mparticle.IdentityRequest();

        identity.logout(logoutRequest, function (userID) {
            console.log('Logout Success: ' + userID);
        });
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
        'confirmationref': '54321'
    };

    var config = {
        colorMode: mparticle.RoktColorMode.SYSTEM,
        cacheConfig: {
            cacheDurationInSeconds: 5400,
            cacheAttributes: {}
        },
        edgeToEdgeDisplay: true
    };

    mparticle.selectPlacements(
        'MSDKOverlayLayout',
        attributes,
        config
    );
}

app.initialize();
