import Foundation
import RoktPaymentExtension
import mParticle_Apple_SDK_ObjC

/// Swift bridge that lets the ObjC AppDelegate construct a concrete
/// `RoktPaymentExtension` instance and register it with the mParticle
/// Rokt namespace before any `selectShoppableAds` call.
///
/// `RoktPaymentExtension` is a pure-Swift class with a failable initialiser
/// that isn't `@objc`-exported, so ObjC code can't instantiate it directly —
/// this helper provides a one-call entry point.
///
/// The mParticle Rokt kit reads `stripePublishableKey` from kit configuration
/// in the mParticle dashboard and passes it to Rokt as `stripeKey` at
/// registration time, so the host app only needs to supply the Apple Pay
/// merchant identifier.
@objc public class RoktPaymentSetup: NSObject {
    @objc public static func registerPaymentExtension(merchantId: String) {
        if let paymentExt = RoktPaymentExtension(applePayMerchantId: merchantId) {
            MParticle.sharedInstance().rokt.register(paymentExt)
        }
    }
}
