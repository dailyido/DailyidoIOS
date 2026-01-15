import SuperwallKit
import RevenueCat
import StoreKit

final class RCPurchaseController: PurchaseController {

    // MARK: - PurchaseController

    func purchase(product: SKProduct) async -> PurchaseResult {
        do {
            let storeProduct = RevenueCat.StoreProduct(sk1Product: product)
            let result = try await Purchases.shared.purchase(product: storeProduct)

            if result.userCancelled {
                return .cancelled
            } else {
                return .purchased
            }
        } catch let error as ErrorCode {
            if error == .purchaseCancelledError {
                return .cancelled
            } else {
                return .failed(error)
            }
        } catch {
            return .failed(error)
        }
    }

    func restorePurchases() async -> RestorationResult {
        do {
            _ = try await Purchases.shared.restorePurchases()
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
