import Foundation

extension PutioAPI {
    public func login(username: String, password: String, clientName: String, completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        let clientName = clientName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let URL = "/oauth2/authorizations/clients/\(self.config.clientID)?client_secret=\(self.config.clientSecret)&client_name=\(clientName!)"

        self.authenticate(username: username, password: password)
            .put(URL)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(response!["access_token"].stringValue, nil)
        }
    }

    public func getLoginURL(redirectURI: String, responseType: String = "token", state: String = "") -> URL {
        var url = URLComponents(string: "\(PutioAPI.webAppURL)/authenticate")

        url?.queryItems = [
            URLQueryItem(name: "client_id", value: self.config.clientID),
            URLQueryItem(name: "client_name", value: self.config.clientName),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "state", value: state),
        ]

        return (url?.url!)!
    }

    public func getAuthCode(clientName: String, completion: @escaping (_ code: String?, _ error: Error?) -> Void) {
        let clientName = clientName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let URL = "/oauth2/oob/code?app_id=\(self.config.clientID)&client_name=\(clientName!)"

        self.get(URL)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(response!["code"].stringValue, nil)
        }
    }

    public func checkAuthCodeMatch(code: String, completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        let URL = "/oauth2/oob/code/\(code)"

        self.get(URL)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(response!["oauth_token"].stringValue, nil)
        }
    }

    public func validateToken(token: String, completion: @escaping (_ result: PutioTokenValidationResult?, _ error: Error?) -> Void) {
        let URL = "/oauth2/validate"

        self.get(URL)
            .end { response, error in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(PutioTokenValidationResult(json: response!), nil)
            }
    }

    public func verifyTOTP(totp: String, completion: @escaping (_ result: PutioVerifyTOTPResult?, _ error: Error?) -> Void) {
        let URL = "/two_factor/verify/totp"
        let body = ["totp": totp] as [String: String]

        self.post(URL)
            .send(body)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(PutioVerifyTOTPResult(json: response!), nil)
        }
    }

    public func logout() {}
}
