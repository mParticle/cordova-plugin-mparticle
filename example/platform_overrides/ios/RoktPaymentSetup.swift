import Foundation
import RoktPaymentExtension
import mParticle_Apple_SDK_ObjC

@objc public class RoktPaymentSetup: NSObject {
    @objc public static func registerPaymentExtension(merchantId: String) {
        if let paymentExt = RoktPaymentExtension(applePayMerchantId: merchantId) {
            MParticle.sharedInstance().rokt.register(paymentExt)
        }
    }
}
