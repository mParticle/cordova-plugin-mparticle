import UIKit
import mParticle_Apple_SDK_ObjC
import RoktStripePaymentExtension

@objc(AppDelegate) class AppDelegate: CDVAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let options = MParticleOptions(key: "REPLACE_ME_API_KEY", secret: "REPLACE_ME_API_SECRET")

        let request = MPIdentityApiRequest.withEmptyUser()
        request.email = "email@example.com"
        options.identifyRequest = request
        options.onIdentifyComplete = { result, error in
            print("Identify complete. userId = \(String(describing: result?.user.userId)) error = \(String(describing: error))")
        }

        MParticle.sharedInstance().start(with: options)
        MParticle.sharedInstance().logLevel = .verbose

        // Register Rokt Stripe payment extension for Shoppable Ads
        if let stripeExt = RoktStripePaymentExtension(applePayMerchantId: "merchant.com.mparticle.example") {
            MParticle.sharedInstance().rokt.register(stripeExt)
        }

        self.viewController = CDVViewController()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
