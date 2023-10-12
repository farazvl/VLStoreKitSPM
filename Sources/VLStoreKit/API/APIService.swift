//
//  APIService.swift
//  VLStoreKit
//
//  Created by Gaurav Vig on 17/02/22.
//

import Foundation

protocol APIService {
    func makeSubscriptionAPICall<T: Decodable>(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: T?, _ isSuccess:Bool, _ responseCode:Int?) -> Void))
    func makeTransactionalSubscriptionAPICall(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: [String:Any]?, _ isSuccess:Bool, _ responseCode:Int?) -> Void))
    func getTransactionDetailsAPICall<T: Decodable>(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: T?, _ isSuccess:Bool) -> Void))
}

extension APIService {
    func makeSubscriptionAPICall<T: Decodable>(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: T?, _ isSuccess:Bool, _ responseCode:Int?) -> Void)) {
        let requestHeaders = ["Accept-Encoding": "gzip", "Content-Type": "application/json", "x-api-key": VLStoreKitInternal.shared.apiKey ?? "", "Accept":"application/json", "User-Agent": HelperFunctions.getUserAgent(), "Authorization": VLStoreKitInternal.shared.authorizationToken ?? ""]
        let userIdentity = VLStoreKitInternal.shared.userIdentity
        var apiRequestString = APIUrl.getAPIBaseUrl() + APIUrl.subscribeEndPoint.rawValue + "?site=\(userIdentity?.siteName ?? "")"
        #if os(iOS)
        apiRequestString.append("&platform=ios_phone")
        #else
        apiRequestString.append("&platform=ios_apple_tv")
        #endif
        if let storeCountryCode = VLStoreKitInternal.shared.storeCountryCode {
            apiRequestString.append("&store_countryCode=\(storeCountryCode)")
        }
        NetworkRequest().makeNetworkRequest(apiRequestString: apiRequestString, requestHeaders: requestHeaders, requestParams: requestParams, requestType: "POST") { responseConfigData, isSuccess, responseCode in
            if let data = responseConfigData {
                do {
                    let responseDecoder = try JSONDecoder().decode(T.self, from: data)
                    responseCallback(responseDecoder, isSuccess, responseCode)
                }
                catch {
                    responseCallback(nil, false, responseCode)
                }
            }
        }
    }
    
    func makeTransactionalSubscriptionAPICall(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: [String:Any]?, _ isSuccess:Bool, _ responseCode:Int?) -> Void)) {
        let requestHeaders = ["Accept-Encoding": "gzip", "Content-Type": "application/json", "x-api-key": VLStoreKitInternal.shared.apiKey ?? "", "Accept":"application/json", "User-Agent": HelperFunctions.getUserAgent(), "Authorization": VLStoreKitInternal.shared.authorizationToken ?? ""]
        let userIdentity = VLStoreKitInternal.shared.userIdentity
        var apiRequestString = APIUrl.getAPIBaseUrl() + APIUrl.transactionPurchaseEndPoint.rawValue + "?site=\(userIdentity?.siteName ?? "")"
        #if os(iOS)
        apiRequestString.append("&platform=ios_phone")
        #else
        apiRequestString.append("&platform=ios_apple_tv")
        #endif
        if let storeCountryCode = VLStoreKitInternal.shared.storeCountryCode {
            apiRequestString.append("&store_countryCode=\(storeCountryCode)")
        }
        NetworkRequest().makeNetworkRequest(apiRequestString: apiRequestString, requestHeaders: requestHeaders, requestParams: requestParams, requestType: "POST") { responseConfigData, isSuccess, responseCode in
            if isSuccess == true, let responseConfigData = responseConfigData, let transactionJson = try? JSONSerialization.jsonObject(with: responseConfigData), let transactionDict = transactionJson as? Dictionary<String,AnyObject> {
                if let val = transactionDict["RequestResponses"], let recordIdDict = val.object(at: 0) as? Dictionary<String, AnyObject>, let _ = recordIdDict["RecordId"] {
                    responseCallback(transactionDict, true, nil)
                }
                else if let status = transactionDict["status"] as? String, status == "success" {
                    responseCallback(transactionDict, true, nil)
                }
                else {
                    responseCallback(transactionDict, false, responseCode)
                }
            }
            else {
                responseCallback([:], false, responseCode)
            }
        }
    }
    
    func getTransactionDetailsAPICall<T: Decodable>(requestParams:[String:Any]?, responseCallback:@escaping ((_ response: T?, _ isSuccess:Bool) -> Void)) {
        let requestHeaders = ["Accept-Encoding": "gzip", "Content-Type": "application/json", "x-api-key": VLStoreKitInternal.shared.apiKey ?? "", "Accept":"application/json", "User-Agent": HelperFunctions.getUserAgent(), "Authorization": VLStoreKitInternal.shared.authorizationToken ?? ""]
        let userIdentity = VLStoreKitInternal.shared.userIdentity
        var apiRequestString = APIUrl.getAPIBaseUrl() + APIUrl.validateIOSReceiptEndPoint.rawValue + "?site=\(userIdentity?.siteName ?? "")"
        #if os(iOS)
        apiRequestString.append("&platform=ios_phone")
        #else
        apiRequestString.append("&platform=ios_apple_tv")
        #endif
        if let storeCountryCode = VLStoreKitInternal.shared.storeCountryCode {
            apiRequestString.append("&store_countryCode=\(storeCountryCode)")
        }
        NetworkRequest().makeNetworkRequest(apiRequestString: apiRequestString, requestHeaders: requestHeaders, requestParams: requestParams, requestType: "POST") { responseConfigData, isSuccess, responseCode in
            guard let data = responseConfigData else {
                responseCallback(nil, false)
                return
            }
            do {
                let responseDecoder = try JSONDecoder().decode(T.self, from: data)
                responseCallback(responseDecoder, isSuccess)
            }
            catch {
                responseCallback(nil, false)
            }
        }
    }
}

struct NetworkRequest {
    func makeNetworkRequest(apiRequestString:String, requestHeaders:[String:String], requestParams:[String:Any]?, requestType:String, responseForConfiguration: @escaping ((_ responseConfigData: Data?, _ isSuccess:Bool, _ responseCode:Int?) -> Void)) {
        guard let apiUrl = URL(string: apiRequestString) else { return }
        var urlRequest = URLRequest(url: apiUrl)
        urlRequest.httpMethod = requestType
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.allHTTPHeaderFields = requestHeaders
        if let _requestParams = requestParams, let data = try? JSONSerialization.data(withJSONObject: _requestParams) {
            urlRequest.httpBody = data
        }
		if VLStoreKit.sharedStoreKitManager.enableDebugLogs {
			getCURLRequest(request: urlRequest)
		}
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil,let usableData = data {
                responseForConfiguration(usableData, self.getSuccessStatus(response: response), (response as? HTTPURLResponse)?.statusCode)
            }
            else if error != nil, let usableData = data {
                responseForConfiguration(usableData, self.getSuccessStatus(response: response), (response as? HTTPURLResponse)?.statusCode)
            }
            else {
                responseForConfiguration(nil, self.getSuccessStatus(response: response), (response as? HTTPURLResponse)?.statusCode)
            }
        }.resume()
    }
    
    private func getSuccessStatus(response:URLResponse?) -> Bool {
        if let urlResponse = response as? HTTPURLResponse {
            let statusCode = urlResponse.statusCode
            switch statusCode {
            case 200..<300:
                return true
            default:
                return false
            }
        }
        return false
    }
	
	
	private func getCURLRequest(request: URLRequest) {
//#if DEBUG
		var curlString = "VLStoreKitLib CURL REQUEST:\n"
		curlString += "curl -X \(request.httpMethod!) \\\n"
		
		request.allHTTPHeaderFields?.forEach({ (key, value) in
			let headerKey = self.escapeQuotesInString(str: key)
			let headerValue = self.escapeQuotesInString(str: value)
			curlString += " -H \'\(headerKey): \(headerValue)\' \n"
		})
		
		guard let requestUrl = request.url else {return}
		curlString += " \(requestUrl.absoluteString) \\\n"
		
		if let body = request.httpBody, body.count > 0 {
			if let str = String(data: body, encoding: String.Encoding.utf8) {
				let bodyDataString = self.escapeQuotesInString(str: str)
				curlString += " -d \'\(bodyDataString)\'"
			}
		}
		
		print(curlString)
//#endif
	}
	
	private func escapeQuotesInString(str:String) -> String {
		return str.replacingOccurrences(of: "\\", with: "")
	}
}

enum APIUrl:String {
    case subscribeEndPoint = "/subscription/subscribe"
    case transactionPurchaseEndPoint = "/transaction/transaction"
    case validateIOSReceiptEndPoint = "/subscription/ios/validate_ios_receipt"
    
    static func getAPIBaseUrl() -> String {
        return VLStoreKitInternal.shared.apiUrl ?? ""
    }
}
