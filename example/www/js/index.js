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
        this.receivedEvent('deviceready');
        mparticle.logEvent('Test event', mparticle.EventType.Other, {'Test key': 'Test value'});

        var product = new mparticle.Product('Test viewed product', 5678, 29.99);
        var impression = new mparticle.Impression('Test impression list name', [product]);
        var event = mparticle.CommerceEvent.createImpressionEvent([impression]);
        mparticle.logCommerceEvent(event);

        mparticle.logScreenEvent('Test screen', { 'Test key': 'Test value' });


        var identity = new mparticle.Identity();

        identity.getCurrentUser(function(userID) {
            var user = new mparticle.User(userID);

            user.setUserAttribute(mparticle.UserAttributeType.FirstName, 'Test first name');
            user.setUserAttributeArray(mparticle.UserAttributeType.FirstName, ['Test value 1', 'Test value 2']);
            user.setUserTag('testUser');
            user.removeUserAttribute(mparticle.UserAttributeType.FirstName);
            user.getUserIdentities(function(userIdenitities) {
                console.log('User userIdentities: ' + userIdenitities);
            });
        });

        var request = new mparticle.IdentityRequest();
        request.setEmail('123@gmail.com');

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

app.initialize();
