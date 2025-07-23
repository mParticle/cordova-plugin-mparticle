#import <Cordova/CDV.h>
@import mParticle_Apple_SDK;

@interface CDVMParticle : CDVPlugin
@end

@implementation CDVMParticle

- (void)logEvent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *eventName = [command.arguments objectAtIndex:0];
        NSInteger type = [[command.arguments objectAtIndex:1] intValue];
        NSDictionary *attributes = [command.arguments objectAtIndex:2];
        
        [[MParticle sharedInstance] logEvent:eventName eventType:type eventInfo:attributes];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logMPEvent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedEvent = [command.arguments objectAtIndex:0];
        
        MPEvent *event = [CDVMParticle MPEvent:serializedEvent];
        
        [[MParticle sharedInstance] logEvent:event];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logCommerceEvent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedCommerceEvent = [command.arguments objectAtIndex:0];
        
        MPCommerceEvent *commerceEvent = [CDVMParticle MPCommerceEvent:serializedCommerceEvent];
        
        [[MParticle sharedInstance] logEvent:commerceEvent];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logScreenEvent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *screenName = [command.arguments objectAtIndex:0];
        NSDictionary *attributes = [command.arguments objectAtIndex:1];
        
        [[MParticle sharedInstance] logScreen:screenName eventInfo:attributes];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setATTStatus:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSInteger status = [[command.arguments objectAtIndex:0] intValue];
        NSNumber *timestamp = [command.arguments objectAtIndex:1];
        
        [[MParticle sharedInstance] setATTStatus:status withATTStatusTimestampMillis:timestamp];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)addGDPRConsentState:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedConsent = [command.arguments objectAtIndex:0];
        NSString *purpose = [command.arguments objectAtIndex:1];
        
        MPGDPRConsent *consent = [CDVMParticle MPGDPRConsent:serializedConsent];
        MPConsentState *consentState = [[MParticle sharedInstance].identity.currentUser.consentState copy];
        [consentState addGDPRConsentState:consent purpose:purpose];
        
        [MParticle sharedInstance].identity.currentUser.consentState = consentState;

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeGDPRConsentStateWithPurpose:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *purpose = [command.arguments objectAtIndex:0];
        
        [[MParticle sharedInstance].identity.currentUser.consentState removeGDPRConsentStateWithPurpose:purpose];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)addCCPAConsentState:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedConsent = [command.arguments objectAtIndex:0];
        
        MPCCPAConsent *consent = [CDVMParticle MPCCPAConsent:serializedConsent];
        MPConsentState *consentState = [[MParticle sharedInstance].identity.currentUser.consentState copy];
        [consentState setCCPAConsentState:consent];
        
        [MParticle sharedInstance].identity.currentUser.consentState = consentState;

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeCCPAConsentState:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [[MParticle sharedInstance].identity.currentUser.consentState removeCCPAConsentState];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setUserAttribute:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *userId = [command.arguments objectAtIndex:0];
        NSString *key = [command.arguments objectAtIndex:1];
        NSString *value = [command.arguments objectAtIndex:2];
        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:[NSNumber numberWithLong:userId.longLongValue]];
        
        if (selectedUser != nil) {
            [selectedUser setUserAttribute:key value:value];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setUserAttributeArray:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *userId = [command.arguments objectAtIndex:0];
        NSString *key = [command.arguments objectAtIndex:1];
        NSArray *values = [command.arguments objectAtIndex:2];
        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:[NSNumber numberWithLong:userId.longLongValue]];
        
        if (selectedUser != nil) {
            [selectedUser setUserAttributeList:key values:values];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setUserTag:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *userId = [command.arguments objectAtIndex:0];
        NSString *tag = [command.arguments objectAtIndex:1];
        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:[NSNumber numberWithLong:userId.longLongValue]];
        
        if (selectedUser != nil) {
            [selectedUser setUserTag:tag];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeUserAttribute:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *userId = [command.arguments objectAtIndex:0];
        NSString *key = [command.arguments objectAtIndex:1];
        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:[NSNumber numberWithLong:userId.longLongValue]];
        
        if (selectedUser != nil) {
            [selectedUser removeUserAttribute:key];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)identify:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] identify:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *cordovaError;
            if (error) {
                cordovaError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                if ([NSNumber numberWithInteger:error.code] != nil) {
                    [cordovaError setObject:[NSNumber numberWithInteger:error.code] forKey:@"httpCode"];
                }
                if (error.localizedDescription != nil) {
                    [cordovaError setObject:error.localizedDescription forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:cordovaError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apiResult.user.userId.stringValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)login:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] login:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *cordovaError;
            if (error) {
                cordovaError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                if ([NSNumber numberWithInteger:error.code] != nil) {
                    [cordovaError setObject:[NSNumber numberWithInteger:error.code] forKey:@"httpCode"];
                }
                if (error.localizedDescription != nil) {
                    [cordovaError setObject:error.localizedDescription forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:cordovaError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apiResult.user.userId.stringValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)logout:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] logout:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *cordovaError;
            if (error) {
                cordovaError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                if ([NSNumber numberWithInteger:error.code] != nil) {
                    [cordovaError setObject:[NSNumber numberWithInteger:error.code] forKey:@"httpCode"];
                }
                if (error.localizedDescription != nil) {
                    [cordovaError setObject:error.localizedDescription forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:cordovaError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apiResult.user.userId.stringValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)modify:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] modify:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *cordovaError;
            if (error) {
                cordovaError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                if ([NSNumber numberWithInteger:error.code] != nil) {
                    [cordovaError setObject:[NSNumber numberWithInteger:error.code] forKey:@"httpCode"];
                }
                if (error.localizedDescription != nil) {
                    [cordovaError setObject:error.localizedDescription forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:cordovaError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apiResult.user.userId.stringValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)getCurrentUser:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[[MParticle sharedInstance] identity] currentUser].userId.stringValue];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserIdentities:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSNumber *userId = [command.arguments objectAtIndex:0];
        
        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:userId];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[selectedUser identities]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

typedef NS_ENUM(NSUInteger, MPCDVCommerceEventAction) {
    MPCDVCommerceEventActionAddToCart = 1,
    MPCDVCommerceEventActionRemoveFromCart,
    MPCDVCommerceEventActionCheckout,
    MPCDVCommerceEventActionCheckoutOptions,
    MPCDVCommerceEventActionClick,
    MPCDVCommerceEventActionViewDetail,
    MPCDVCommerceEventActionPurchase,
    MPCDVCommerceEventActionRefund,
    MPCDVCommerceEventActionAddToWishList,
    MPCDVCommerceEventActionRemoveFromWishlist
};

+ (MPCommerceEventAction)MPCommerceEventAction:(NSNumber *)json {
    int actionInt = [json intValue];
    MPCommerceEventAction action;
    switch (actionInt) {
        case MPCDVCommerceEventActionAddToCart:
            action = MPCommerceEventActionAddToCart;
            break;
            
        case MPCDVCommerceEventActionRemoveFromCart:
            action = MPCommerceEventActionRemoveFromCart;
            break;
            
        case MPCDVCommerceEventActionCheckout:
            action = MPCommerceEventActionCheckout;
            break;
            
        case MPCDVCommerceEventActionCheckoutOptions:
            action = MPCommerceEventActionCheckoutOptions;
            break;
            
        case MPCDVCommerceEventActionClick:
            action = MPCommerceEventActionClick;
            break;
            
        case MPCDVCommerceEventActionViewDetail:
            action = MPCommerceEventActionViewDetail;
            break;
            
        case MPCDVCommerceEventActionPurchase:
            action = MPCommerceEventActionPurchase;
            break;
            
        case MPCDVCommerceEventActionRefund:
            action = MPCommerceEventActionRefund;
            break;
            
        case MPCDVCommerceEventActionAddToWishList:
            action = MPCommerceEventActionAddToWishList;
            break;
            
        case MPCDVCommerceEventActionRemoveFromWishlist:
            action = MPCommerceEventActionRemoveFromWishlist;
            break;
            
        default:
            action = MPCommerceEventActionAddToCart;
            NSAssert(NO, @"Invalid commerce event action");
            break;
    }
    return action;
}

+ (MPCommerceEvent *)MPCommerceEvent:(NSMutableDictionary *)json {
    BOOL isProductAction = json[@"productActionType"] != nil;
    BOOL isPromotion = json[@"promotionActionType"] != nil;
    BOOL isImpression = json[@"impressions"] != nil;
    BOOL isValid = isProductAction || isPromotion || isImpression;
    
    MPCommerceEvent *commerceEvent = nil;
    if (!isValid) {
        NSAssert(NO, @"Invalid commerce event");
        return commerceEvent;
    }
    
    if (isProductAction) {
        MPCommerceEventAction action = [CDVMParticle MPCommerceEventAction:json[@"productActionType"]];
        commerceEvent = [[MPCommerceEvent alloc] initWithAction:action];
    }
    else if (isPromotion) {
        MPPromotionContainer *promotionContainer = [CDVMParticle MPPromotionContainer:json];
        commerceEvent = [[MPCommerceEvent alloc] initWithPromotionContainer:promotionContainer];
    }
    else {
        commerceEvent = [[MPCommerceEvent alloc] initWithImpressionName:nil product:nil];
    }
    
    commerceEvent.checkoutOptions = json[@"checkoutOptions"];
    commerceEvent.currency = json[@"currency"];
    commerceEvent.productListName = json[@"productActionListName"];
    commerceEvent.productListSource = json[@"productActionListSource"];
    commerceEvent.screenName = json[@"screenName"];
    commerceEvent.transactionAttributes = [CDVMParticle MPTransactionAttributes:json[@"transactionAttributes"]];\
    if (json[@"productActionType"] != nil) {
        commerceEvent.action = [CDVMParticle MPCommerceEventAction:json[@"productActionType"]];
    }
    if (json[@"checkoutStep"] != nil) {
        commerceEvent.checkoutStep = [json[@"checkoutStep"] intValue];
    }
    commerceEvent.nonInteractive = [json[@"nonInteractive"] boolValue];
    if (json[@"shouldUploadEvent"] != nil) {
        commerceEvent.shouldUploadEvent = [json[@"shouldUploadEvent"] boolValue];
    }
    if (json[@"customAttributes"] != nil) {
        commerceEvent.customAttributes = json[@"customAttributes"];
    }
    
    NSMutableArray *products = [NSMutableArray array];
    NSArray *jsonProducts = json[@"products"];
    [jsonProducts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPProduct *product = [CDVMParticle MPProduct:obj];
        [products addObject:product];
    }];
    [commerceEvent addProducts:products];
    
    NSArray *jsonImpressions = json[@"impressions"];
    [jsonImpressions enumerateObjectsUsingBlock:^(NSDictionary *jsonImpression, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *listName = jsonImpression[@"impressionListName"];
        NSArray *jsonProducts = jsonImpression[@"products"];
        [jsonProducts enumerateObjectsUsingBlock:^(id  _Nonnull jsonProduct, NSUInteger idx, BOOL * _Nonnull stop) {
            MPProduct *product = [CDVMParticle MPProduct:jsonProduct];
            [commerceEvent addImpression:product listName:listName];
        }];
    }];
    
    return commerceEvent;
}

+ (MPPromotionContainer *)MPPromotionContainer:(NSMutableDictionary *)json {
    MPPromotionAction promotionAction = (MPPromotionAction)[json[@"promotionActionType"] intValue];
    MPPromotionContainer *promotionContainer = [[MPPromotionContainer alloc] initWithAction:promotionAction promotion:nil];
    NSArray *jsonPromotions = json[@"promotions"];
    [jsonPromotions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPPromotion *promotion = [CDVMParticle MPPromotion:obj];
        [promotionContainer addPromotion:promotion];
    }];
    
    return promotionContainer;
}

+ (MPPromotion *)MPPromotion:(NSMutableDictionary *)json {
    MPPromotion *promotion = [[MPPromotion alloc] init];
    promotion.creative = json[@"creative"];
    promotion.name = json[@"name"];
    promotion.position = json[@"position"];
    promotion.promotionId = json[@"id"];
    return promotion;
}

+ (MPTransactionAttributes *)MPTransactionAttributes:(NSMutableDictionary *)json {
    MPTransactionAttributes *transactionAttributes = [[MPTransactionAttributes alloc] init];
    transactionAttributes.affiliation = json[@"affiliation"];
    transactionAttributes.couponCode = json[@"couponCode"];
    transactionAttributes.shipping = json[@"shipping"];
    transactionAttributes.tax = json[@"tax"];
    transactionAttributes.revenue = json[@"revenue"];
    transactionAttributes.transactionId = json[@"transactionId"];
    return transactionAttributes;
}

+ (MPProduct *)MPProduct:(NSMutableDictionary *)json {
    MPProduct *product = [[MPProduct alloc] init];
    product.brand = json[@"brand"];
    product.category = json[@"category"];
    product.couponCode = json[@"couponCode"];
    product.name = json[@"name"];
    product.price = json[@"price"];
    product.sku = json[@"sku"];
    product.variant = json[@"variant"];
    product.position = [json[@"position"] intValue];
    product.quantity = json[@"quantity"] ?: @1;
    NSDictionary *jsonAttributes = json[@"customAttributes"];
    for (NSString *key in jsonAttributes) {
        NSString *value = jsonAttributes[key];
        [product setObject:value forKeyedSubscript:key];
    }
    return product;
}

+ (MPEvent *)MPEvent:(NSMutableDictionary *)json {
    MPEvent *event = [[MPEvent alloc] init];
    event.category = json[@"category"];
    event.duration = json[@"duration"];
    event.endTime = json[@"endTime"];
    event.customAttributes = json[@"info"];
    event.name = json[@"name"];
    event.startTime = json[@"startTime"];
    event.type = [json[@"type"] integerValue];
    if (json[@"shouldUploadEvent"] != nil) {
        event.shouldUploadEvent = [json[@"shouldUploadEvent"] boolValue];
    }
    
    NSDictionary *jsonFlags = json[@"customFlags"];
    for (NSString *key in jsonFlags) {
        NSString *value = jsonFlags[key];
        [event addCustomFlag:value withKey:key];
    }
    
    return event;
}

+ (MPIdentityApiRequest *)MPIdentityApiRequest:(NSMutableDictionary *)json {
    MPIdentityApiRequest *request = [[MPIdentityApiRequest alloc] init];
    for (NSString *key in json) {
        NSString *value = json[key];
        [request setIdentity:value identityType:[CDVMParticle ConvertIdentityType:key]];
    }
    
    return request;
}

+ (MPIdentity)ConvertIdentityType:(NSString *)val {
    if ([val  isEqual: @"customerId"]) {
        return MPIdentityCustomerId;
    } else if ([val  isEqual: @"facebook"]) {
        return MPIdentityFacebook;
    } else if ([val  isEqual: @"twitter"]) {
        return MPIdentityTwitter;
    } else if ([val  isEqual: @"google"]) {
        return MPIdentityGoogle;
    } else if ([val  isEqual: @"microsoft"]) {
        return MPIdentityMicrosoft;
    } else if ([val  isEqual: @"yahoo"]) {
        return MPIdentityYahoo;
    } else if ([val  isEqual: @"email"]) {
        return MPIdentityEmail;
    } else if ([val  isEqual: @"alias"]) {
        return MPIdentityAlias;
    } else if ([val  isEqual: @"facebookCustom"]) {
        return MPIdentityFacebookCustomAudienceId;
    } else if ([val  isEqual: @"other2"]) {
        return MPIdentityOther2;
    } else if ([val  isEqual: @"other3"]) {
        return MPIdentityOther3;
    } else if ([val  isEqual: @"other4"]) {
        return MPIdentityOther4;
    } else if ([val  isEqual: @"other5"]) {
        return MPIdentityOther5;
    } else if ([val  isEqual: @"other6"]) {
        return MPIdentityOther6;
    } else if ([val  isEqual: @"other7"]) {
        return MPIdentityOther7;
    } else if ([val  isEqual: @"other8"]) {
        return MPIdentityOther8;
    } else if ([val  isEqual: @"other9"]) {
        return MPIdentityOther9;
    } else if ([val  isEqual: @"other10"]) {
        return MPIdentityOther10;
    } else if ([val  isEqual: @"mobileNumber"]) {
        return MPIdentityMobileNumber;
    } else if ([val  isEqual: @"phoneNumber2"]) {
        return MPIdentityPhoneNumber2;
    } else if ([val  isEqual: @"phoneNumber3"]) {
        return MPIdentityPhoneNumber3;
    } else if ([val  isEqual: @"iosIDFA"]) {
        return MPIdentityIOSAdvertiserId;
    } else if ([val  isEqual: @"iosIDFV"]) {
        return MPIdentityIOSVendorId;
    } else if ([val  isEqual: @"pushToken"]) {
        return MPIdentityPushToken;
    } else if ([val  isEqual: @"deviceApplicationStamp"]) {
        return MPIdentityDeviceApplicationStamp;
    } else {
        return MPIdentityOther;
    }
}

+ (MPGDPRConsent *)MPGDPRConsent:(NSMutableDictionary *)json {
    NSString *dateString =  json[@"timestamp"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timestamp = [dateFormatter dateFromString:dateString];
    
    MPGDPRConsent *consentState = [[MPGDPRConsent alloc] init];
    consentState.consented = [json[@"consented"] boolValue];
    consentState.document = json[@"document"];
    consentState.timestamp = timestamp;
    consentState.location = json[@"location"];
    consentState.hardwareId = json[@"hardwareId"];
    
    return consentState;
}

+ (MPCCPAConsent *)MPCCPAConsent:(NSMutableDictionary *)json {
    NSString *dateString =  json[@"timestamp"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timestamp = [dateFormatter dateFromString:dateString];
    
    MPCCPAConsent *consentState = [[MPCCPAConsent alloc] init];
    consentState.consented = [json[@"consented"] boolValue];
    consentState.document = json[@"document"];
    consentState.timestamp = timestamp;
    consentState.location = json[@"location"];
    consentState.hardwareId = json[@"hardwareId"];
    
    return consentState;
}

@end


