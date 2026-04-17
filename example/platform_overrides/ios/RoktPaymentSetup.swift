import Foundation
import RoktStripePaymentExtension
import mParticle_Apple_SDK_ObjC

@objc public class RoktPaymentSetup: NSObject {
    @objc public static func registerPaymentExtension(merchantId: String) {
        if let stripeExt = RoktStripePaymentExtension(applePayMerchantId: merchantId) {
            MParticle.sharedInstance().rokt.register(stripeExt)
        }
    }
}
