import Foundation

public enum NetworkManager {
    public static func request<T: Decodable>(url: String,
                                             method: HTTPMethod,
                                             parameters: [String: Any]? = nil,
                                             contentType: ContentType = .JSON,
                                             headers: [String: String]? = nil) async throws -> T {
        let session = URLSession.shared
        let request = try createRequest(url: url,
                                        method: method,
                                        parameters: parameters,
                                        contentType: contentType,
                                        headers: headers)
        
        let (data, response) = try await session.data(for: request)
        try validate(response)
        
        return try result(from: data)
    }
}

// MARK: - Private

private extension NetworkManager {
    static func createRequest(url: String,
                              method: HTTPMethod,
                              parameters: [String: Any]?,
                              contentType: ContentType,
                              headers: [String: String]?) throws -> URLRequest {
        guard var components = URLComponents(string: url) else { throw NetworkError.invalidURL }
    
        if case .GET(let queryParameters) = method, let queryParameters = queryParameters {
            components.queryItems = queryParameters.map { (key: String, value: Any) in
                return URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.raw
        
        if let parameters = parameters {
            let bodyParams = try NetworkManager.encode(parameters, encoding: contentType.encoding)
            request.httpBody = bodyParams
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }

        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }

        return request
    }
    
    static func encode(_ parameters: [String: Any], encoding: ParameterEncoding) throws -> Data {
        switch encoding {
        case .JSONEncoding:
            return try JSONSerialization.data(withJSONObject: parameters, options: [])
        case .URLEncoding:
            let query = parameters.map { (key, value) in
                if let value = value as? String {
                    return escape(key) + "=" + escape(value)
                } else {
                    return escape(key) + "=" + "\(value)"
                }
            }.joined(separator: "&")
            return Data(query.utf8)
        }
    }

    static func validate(_ response: URLResponse) throws {
        if let response = response as? HTTPURLResponse,
           response.statusCode < 200 || response.statusCode > 300 {
            throw NetworkError.invalidStatusCode(code: response.statusCode)
        }
    }

    static func result<T: Decodable>(from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            throw error
        }
    }
    
}

// MARK: - URLEncoding

private extension NetworkManager {
    static func escape(_ string: String) -> String {
        return string.replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
            .replacingOccurrences(of: " ", with: "+")
    }
    
    static let allowedCharacters: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(" ")
        allowed.remove("+")
        allowed.remove("/")
        allowed.remove("?")
        return allowed
    }()
}

// MARK: - HTTPMethod

public enum HTTPMethod {
    case GET(query: [String: Any]? = nil)
    case POST
    case DELETE
    case PUT
    
    var raw: String {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .DELETE:
            return "DELETE"
        case .PUT:
            return "PUT"
        }
    }
}

// MARK: - ContentType

public enum ContentType: String {
    case JSON = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
    
    var encoding: ParameterEncoding {
        switch self {
        case .JSON:
            return .JSONEncoding
        case .formUrlEncoded:
            return .URLEncoding
        }
    }
}

// MARK: - ParameterEncoding

public enum ParameterEncoding {
    case JSONEncoding
    case URLEncoding
}
