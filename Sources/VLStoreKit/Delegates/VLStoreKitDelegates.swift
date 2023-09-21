//
//  VLStoreKitDelegates.swift
//  VLStoreKit
//
//  Created by Gaurav Vig on 22/02/22.
//

public protocol VLStoreKitDelegate:AnyObject {
    func transactionFinished(storeKitModel:VLStoreKitModel, isSubscriptionSyncInProcess:Bool)
    func transactionFailed(error:TransactionError)
    func transactionInProcess()
    func connectionToAppStoreFailed(errorMessage:String)
}

public protocol VLStoreKitAppStoreSubscriptionDelegate:AnyObject {
    func transactionFromAppStoreFound(showOverlay:Bool)
    func transactionDoneFromAppStoreCompleted(storeKitModel:VLStoreKitModel)
}

public protocol VLStoreKitSubscriptionSyncDelegate:AnyObject {
    func subscriptionSyncCompleted(subscriptionSyncResponse:SubscriptionSyncResponse)
    func subscriptionSyncFailed(errorCode:SubscriptionSyncStatus)
    func transactionPurchaseSync(isSyncCompleted:Bool,errorCode:SubscriptionSyncStatus)
}

public protocol VLStoreKitSocketMessageDelegate:AnyObject {
    func socketMessageHandler()
}
