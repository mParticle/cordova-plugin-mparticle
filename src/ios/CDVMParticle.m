
#import <Cordova/CDV.h>
#import "mParticle.h"

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

- (void)logCommerceEvent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *serializedCommerceEvent = [command.arguments objectAtIndex:0];

        MPCommerceEvent *commerceEvent = [CDVMParticle MPCommerceEvent:serializedCommerceEvent];

        [[MParticle sharedInstance] logCommerceEvent:commerceEvent];

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
            [selectedUser setUserAttribute:key value:values];
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
        NSString *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] identify:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *reactError;
            if (error) {
                reactError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                MPIdentityHTTPErrorResponse *response = error.userInfo[mParticleIdentityErrorKey];

                if ([NSNumber numberWithLong:response.httpCode] != nil) {
                    [reactError setObject:[NSNumber numberWithLong:response.httpCode] forKey:@"httpCode"];
                }
                if ([NSNumber numberWithInt:response.code] != nil) {
                    [reactError setObject:[NSNumber numberWithInt:response.code] forKey:@"responseCode"];
                }
                if (response.message != nil) {
                    [reactError setObject:response.message forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:reactError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:apiResult.user.userId.doubleValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)login:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] login:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *reactError;
            if (error) {
                reactError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                MPIdentityHTTPErrorResponse *response = error.userInfo[mParticleIdentityErrorKey];
                
                if ([NSNumber numberWithLong:response.httpCode] != nil) {
                    [reactError setObject:[NSNumber numberWithLong:response.httpCode] forKey:@"httpCode"];
                }
                if ([NSNumber numberWithInt:response.code] != nil) {
                    [reactError setObject:[NSNumber numberWithInt:response.code] forKey:@"responseCode"];
                }
                if (response.message != nil) {
                    [reactError setObject:response.message forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:reactError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:apiResult.user.userId.doubleValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)logout:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] logout:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *reactError;
            if (error) {
                reactError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                MPIdentityHTTPErrorResponse *response = error.userInfo[mParticleIdentityErrorKey];
                
                if ([NSNumber numberWithLong:response.httpCode] != nil) {
                    [reactError setObject:[NSNumber numberWithLong:response.httpCode] forKey:@"httpCode"];
                }
                if ([NSNumber numberWithInt:response.code] != nil) {
                    [reactError setObject:[NSNumber numberWithInt:response.code] forKey:@"responseCode"];
                }
                if (response.message != nil) {
                    [reactError setObject:response.message forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:reactError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:apiResult.user.userId.doubleValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)modify:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *serializedrequest = [command.arguments objectAtIndex:0];
        MPIdentityApiRequest *request = [CDVMParticle MPIdentityApiRequest:serializedrequest];
        
        [[[MParticle sharedInstance] identity] modify:request completion:^(MPIdentityApiResult * _Nullable apiResult, NSError * _Nullable error) {
            CDVPluginResult *pluginResult = nil;
            NSMutableDictionary *reactError;
            if (error) {
                reactError = [[NSMutableDictionary alloc] initWithCapacity:4];
                
                MPIdentityHTTPErrorResponse *response = error.userInfo[mParticleIdentityErrorKey];
                
                if ([NSNumber numberWithLong:response.httpCode] != nil) {
                    [reactError setObject:[NSNumber numberWithLong:response.httpCode] forKey:@"httpCode"];
                }
                if ([NSNumber numberWithInt:response.code] != nil) {
                    [reactError setObject:[NSNumber numberWithInt:response.code] forKey:@"responseCode"];
                }
                if (response.message != nil) {
                    [reactError setObject:response.message forKey:@"message"];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:reactError];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:apiResult.user.userId.doubleValue];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)getCurrentUser:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDouble:[[[MParticle sharedInstance] identity] currentUser].userId.doubleValue];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserIdentities:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSNumber *userId = [command.arguments objectAtIndex:0];

        MParticleUser *selectedUser = [[[MParticle sharedInstance] identity] getUser:userId];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[selectedUser userIdentities]];
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

+ (MPCommerceEvent *)MPCommerceEvent:(id)json {
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
    commerceEvent.transactionAttributes = [CDVMParticle MPTransactionAttributes:json[@"transactionAttributes"]];
    commerceEvent.action = [CDVMParticle MPCommerceEventAction:json[@"productActionType"]];
    commerceEvent.checkoutStep = [json[@"checkoutStep"] intValue];
    commerceEvent.nonInteractive = [json[@"nonInteractive"] boolValue];

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

+ (MPPromotionContainer *)MPPromotionContainer:(id)json {
    MPPromotionAction promotionAction = (MPPromotionAction)[json[@"promotionActionType"] intValue];
    MPPromotionContainer *promotionContainer = [[MPPromotionContainer alloc] initWithAction:promotionAction promotion:nil];
    NSArray *jsonPromotions = json[@"promotions"];
    [jsonPromotions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPPromotion *promotion = [CDVMParticle MPPromotion:obj];
        [promotionContainer addPromotion:promotion];
    }];

    return promotionContainer;
}

+ (MPPromotion *)MPPromotion:(id)json {
    MPPromotion *promotion = [[MPPromotion alloc] init];
    promotion.creative = json[@"creative"];
    promotion.name = json[@"name"];
    promotion.position = json[@"position"];
    promotion.promotionId = json[@"id"];
    return promotion;
}

+ (MPTransactionAttributes *)MPTransactionAttributes:(id)json {
    MPTransactionAttributes *transactionAttributes = [[MPTransactionAttributes alloc] init];
    transactionAttributes.affiliation = json[@"affiliation"];
    transactionAttributes.couponCode = json[@"couponCode"];
    transactionAttributes.shipping = json[@"shipping"];
    transactionAttributes.tax = json[@"tax"];
    transactionAttributes.revenue = json[@"revenue"];
    transactionAttributes.transactionId = json[@"transactionId"];
    return transactionAttributes;
}

+ (MPProduct *)MPProduct:(id)json {
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

+ (MPIdentityApiRequest *)MPIdentityApiRequest:(id)json {
    MPIdentityApiRequest *request = [[MPIdentityApiRequest alloc] init];
    request.email = json[@"email"];
    request.customerId = json[@"customerId"];
    NSDictionary *jsonAttributes = json[@"userIdentities"];
    for (NSString *key in jsonAttributes) {
        NSString *value = jsonAttributes[key];
        [request.userIdentities setObject:value forKeyedSubscript:key];
    }
    
    return request;
}

+ (MPEvent *)MPEvent:(id)json {
    MPEvent *event = [[MPEvent alloc] init];
    event.category = json[@"category"];
    event.duration = json[@"duration"];
    event.endTime = json[@"endTime"];
    event.info = json[@"info"];
    event.name = json[@"name"];
    event.startTime = json[@"startTime"];
    event.type = [json[@"type"] integerValue];

    NSDictionary *jsonFlags = json[@"customFlags"];
    for (NSString *key in jsonFlags) {
        NSString *value = jsonFlags[key];
        [event addCustomFlag:value withKey:key];
    }
    
    return event;
}

@end
