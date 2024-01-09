// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import VLBeaconLib

final public class VLStoreKit:NSObject {
    
    static public let sharedStoreKitManager:VLStoreKit = {
        let instance = VLStoreKit()
        instance.setAPIVersion = .V1
        return instance
    }()
        
    public init(withAPIVersion apiVersion:APIVersion = .V1)
    {
        self.setAPIVersion = apiVersion
        super.init()
    }
    
    public var enableDebugLogs: Bool = false{
        didSet{
            VLBeacon.getInstance().debugLogs = enableDebugLogs
        }
    }
    public weak var storeKitDelegate:VLStoreKitDelegate? {
        didSet {
            VLStoreKitInternal.shared.storeKitDelegate = storeKitDelegate
        }
    }
    
    public weak var storeKitAppStoreSubscriptionDelegate:VLStoreKitAppStoreSubscriptionDelegate? {
        didSet {
            VLStoreKitInternal.shared.storeKitAppStoreSubscriptionDelegate = storeKitAppStoreSubscriptionDelegate
        }
    }
    
    public weak var storeKitSubscriptionSyncDelegate:VLStoreKitSubscriptionSyncDelegate? {
        didSet {
            VLStoreKitInternal.shared.storeKitSubscriptionSyncDelegate = storeKitSubscriptionSyncDelegate
        }
    }
    
    public weak var socketSyncDelgate:VLStoreKitSocketMessageDelegate? {
        didSet {
            VLStoreKitInternal.shared.socketSyncDelegate = socketSyncDelgate
        }
    }

    @frozen public enum APIVersion {
        case V1
        case V2 //This is only available from OS 15.0 and above
    }
    
    public var setAPIVersion:APIVersion = .V1 {
        didSet {
            VLStoreKitInternal.shared.supportedAPIVersion = setAPIVersion
        }
    }
    
    /**
     Initiate purchase to apple
     
     - Parameters:
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore. Default value is .purchase
        - userUniqueIdentifier: This is the unique identifier which is tied with the subscription. This identifier client provides so that we can reuse the same for linking it.
     */
    public func initateTransaction(productDetails: VLProductDetails, transactionType:TransactionType = .purchase) {
        VLStoreKitInternal.shared.initateTransaction(productDetails: productDetails, transactionType: transactionType)
    }
    
    /**
     Initiate purchase to apple
     
     - Parameters:
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore. Default value is .purchase
        - userUniqueIdentifier: This is the unique identifier which is tied with the subscription. This identifier client provides so that we can reuse the same for linking it.
        - deviceId: This is the device Id which would be used to tie while make subscription sync call. If not provided then internally generate device id.
        - makeInternalSubscriptionCall: This needs to be set if subscritpion sync call needs to be done on Viewlift side post subscription from Appstore.
        - planId: This is the plan identifier of the plan created in Viewlift tools section
     */
    public func initateTransaction(productDetails: VLProductDetails, transactionType:TransactionType = .purchase, deviceId:String? = nil, makeInternalSubscriptionCall:Bool = false, planId:String? = nil) {
        VLStoreKitInternal.shared.initateTransaction(productDetails: productDetails, transactionType: transactionType, deviceId: deviceId, makeInternalSubscriptionCall: makeInternalSubscriptionCall, planId: planId)
    }
    
    /**
     Initiate purchase request to apple for Transaction content
     
     - Parameters:
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore. Default value is .purchase
        - userUniqueIdentifier: This is the unique identifier which is tied with the subscription. This identifier client provides so that we can reuse the same for linking it.
        - deviceId: This is the device Id which would be used to tie while make subscription sync call. If not provided then internally generate device id.
        - makeInternalSubscriptionCall: This needs to be set if subscritpion sync call needs to be done on Viewlift side post subscription from Appstore.
        - transactionalPurchaseObject: This is the transaction purchase object which contains details related to content such as contentId, seriesId, seasonId, planId and contentType
     */
    public func initateTransaction(productDetails: VLProductDetails, transactionType:TransactionType = .purchase, deviceId:String? = nil, makeInternalSubscriptionCall:Bool = false, transactionalPurchaseObject:VLTransactionalObject) {
        VLStoreKitInternal.shared.initateTransaction(productDetails: productDetails, transactionType: transactionType, deviceId: deviceId, makeInternalSubscriptionCall: makeInternalSubscriptionCall, transactionalPurchaseObject: transactionalPurchaseObject)
    }
    
    /**
     Initiate request to apple to get previous purchase from appstore. This is currently supported for auto renewable subscription
     
     - Parameters:
        - restorePurchaseCallback: Callback method which will return latest transaction details if any and error if restore purchase fails or returns no product.
     */
    public func initateRestorePurchase(restorePurchaseCallback: @escaping((_ storeKitModel:VLStoreKitModel?, _ error:TransactionError?) -> Void)) {
        VLStoreKitInternal.shared.initateRestorePurchase(restorePurchaseCallback: restorePurchaseCallback)
    }
    
    /**
     Check for previous purchases from appstore before loading plans. If subscription found will return back subscription details. This is currently supported for auto renewable subscription
     
     - Parameters:
        - restorePurchaseCallback: Callback method which will return latest transaction details if any and error if restore purchase fails or returns no product.
     */
    public func checkPreviousTransaction(restorePurchaseCallback: @escaping((_ storeKitModel:VLStoreKitModel?, _ error:TransactionError?) -> Void)) {
        VLStoreKitInternal.shared.checkPreviousTransaction(restorePurchaseCallback: restorePurchaseCallback)
    }
    
    /**
     Get transaction id and receipt data from apple. This is currently supported for auto renewable subscription
     
     - Parameters:
        - transactionDetailsCallback: Callback method which will return latest transaction details if any and error if no details found
     */
    public func getTransactionDetailsFromApple(transactionDetailsCallback:@escaping((_ storeKitModel:VLStoreKitModel?, _ error:TransactionError?) -> Void)) {
        VLStoreKitInternal.shared.getTransactionDetailsFromApple(transactionDetailsCallback: transactionDetailsCallback)
    }
    
    /**
     This will provide region and currency code of appstore
     
     - Parameters:
        - productIds: List of product identifiers
        - callback: Callback method which will return region and currency code
     */
    public func fetchRegionAndCurrencyCode(productIds: Set<String>, callback: @escaping ((_ regionCode:String?, _ currencyCode:String?) ->  Void)) {
        VLStoreKitInternal.shared.fetchRegionAndCurrencyCode(productIds: productIds, callback: callback)
    }
    
    /**
     This should be called in the start to listen for callbacks provided by AppStore
     */
    public func listenForStoreKitCallbacks() {
        VLStoreKitInternal.shared.listenForStoreKitCallbacks()
    }
    
    /**
     This should be called on terminate to deregister from callbacks provided by AppStore
     */
    public func deRegisterStoreKitCallbacks() {
        VLStoreKitInternal.shared.deRegisterStoreKitCallbacks()
    }

    /**
     This should be called only once on launch or when your application is configured. This needs to be called when subscription sync is to be done at Viewlift server.
     
     - Parameters:
        - apiKey: API key provided from Viewlift Dashboard
        - authorizationToken: Token provided from Viewlift Dashboard
     */
    public static func setupConfig(apiKey:String, authorizationToken:String) {
        VLStoreKitInternal.shared.apiKey = apiKey
        VLStoreKitInternal.shared.authorizationToken = authorizationToken
    }
    
    /**
     This should be called if the authorization token is renewed or regenerated
     
     - Parameters:
        - authorizationToken: Updated authorization token
     */
    public static func updateAuthorizationToken(_ authorizationToken:String) {
        VLStoreKitInternal.shared.authorizationToken = authorizationToken
    }
    
    /**
     This should be called to finish any transaction which was not finished earlier
     */
    public func finishInCompleteTransactions() {
        VLStoreKitInternal.shared.finishInCompleteTransactions()
    }
    
    /**
     This is called to sync subscription status to Viewlift system
     
     - Parameters:
        - planId: This is the plan identifier of the plan created in Viewlift tools section
        - transactionId: Transaction id for the current transaction. This can be different from original transaction id
        - originalTransactionId: This is the original transaction id which remains same even after doing any number of transaction on same product
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionReceipt: This is receipt generated from appstore after subscription
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore.
     */
    public func syncSubscriptionStatusToVLSystem(planId:String?, transactionId:String?, originalTransactionId:String?, productId:String, transactionReceipt:Data?, transactionType: TransactionType) {
        VLStoreKitInternal.shared.syncSubscriptionStatusToVLServer(planId: planId, transactionId: transactionId, originalTransactionId: originalTransactionId, productId: productId, transactionReceipt: transactionReceipt, transactionType: transactionType)
    }
    
    /**
     This is called to sync subscription status to Viewlift system
     
     - Parameters:
        - planId: This is the plan identifier of the plan created in Viewlift tools section
        - transactionId: Transaction id for the current transaction. This can be different from original transaction id
        - originalTransactionId: This is the original transaction id which remains same even after doing any number of transaction on same product
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionReceipt: This is receipt generated from appstore after subscription
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore.
        - subscriptionSyncCallback:Callback method which will return subscription details or error if failed
     */
    public func syncSubscriptionStatusToVLSystem(planId:String?, transactionId:String?, originalTransactionId:String?, productId:String, transactionReceipt:Data?, transactionType: TransactionType, subscriptionSyncCallback: ((_ subscriptionSyncResponse: SubscriptionSyncResponse?, _ errorCode:String?) -> Void)?) {
        VLStoreKitInternal.shared.syncSubscriptionStatusToVLServer(planId: planId, transactionId: transactionId, originalTransactionId: originalTransactionId, productId: productId, transactionReceipt: transactionReceipt, transactionType: transactionType, subscriptionSyncCallback: subscriptionSyncCallback)
    }
    
    /**
     This is called to sync subscription status to Viewlift system
     
     - Parameters:
        - planId: This is the plan identifier of the plan created in Viewlift tools section
        - transactionId: Transaction id for the current transaction. This can be different from original transaction id
        - originalTransactionId: This is the original transaction id which remains same even after doing any number of transaction on same product
        - productId: This is the product identifier being set in appstoreconnect for which subscription is processed
        - transactionReceipt: This is receipt generated from appstore after subscription
        - transactionType: Type of transaction being done such as rent, buy, purchase, restore.
        - transactionalPurchaseObject: This is the transaction purchase object which contains details related to content such as contentId, seriesId, seasonId, planId and contentType
     */
    public func syncTransactionPurchaseStatusToVLSystem(planId:String?, transactionId:String?, originalTransactionId:String?, productId:String, transactionReceipt:Data?, transactionType: TransactionType, transactionPurchaseObject:VLTransactionalObject) {
        VLStoreKitInternal.shared.syncTransactionPurchaseStatusToVLSystem(planId: planId, transactionId: transactionId, originalTransactionId: originalTransactionId, productId: productId, transactionReceipt: transactionReceipt, transactionType: transactionType, transactionPurchaseObject: transactionPurchaseObject)
    }
    
    /**
     This is called to resync transaction purchase if failed to Viewlift system
     
     - Parameters:
        - userIdentifier: This is the unique identifier which is tied with the subscription. This identifier client provides so that we can reuse the same for linking it.
        - syncComplete: Callback method triggered once sync is completed
     */
    public func reSyncFailedTransactionalPurchase(userIdentifier:String, syncComplete:(() -> Void)? = nil) {
        VLStoreKitInternal.shared.reSyncFailedTransactionalPurchase(userIdentifier: userIdentifier, syncComplete: syncComplete)
    }
}
