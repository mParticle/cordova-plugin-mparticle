/*
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
*/

// The cordova-ios 8 AppDelegate template, plus mParticle start-up.

import UIKit
import mParticle_Apple_SDK
import RoktPaymentExtension

@main
#if compiler(>=6.1)
@objc @implementation
#else
@_objcImplementation
#endif
extension AppDelegate {
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let options = MParticleOptions(key: "REPLACE_ME_API_KEY", secret: "REPLACE_ME_API_SECRET")

        // Please see the Identity page for more information on building this object
        let request = MPIdentityApiRequest.withEmptyUser()
        request.email = "email@example.com"
        options.identifyRequest = request
        options.onIdentifyComplete = { apiResult, error in
            NSLog("Identify complete. userId = %@ error = %@", String(describing: apiResult?.user.userId), String(describing: error))
        }

        MParticle.sharedInstance().start(with: options)
        MParticle.sharedInstance().logLevel = .verbose

        // Register Rokt payment extension for Shoppable Ads.
        // The Rokt kit reads `stripePublishableKey` from mParticle dashboard
        // config and forwards it to Rokt as `stripeKey` at registration time;
        // the host only supplies the Apple Pay merchant identifier here.
        if let paymentExtension = RoktPaymentExtension(applePayMerchantId: "merchant.com.mparticle.example") {
            MParticle.sharedInstance().rokt.registerPaymentExtension(paymentExtension)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    open override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
