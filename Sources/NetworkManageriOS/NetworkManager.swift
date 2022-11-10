import Foundation

public typealias ProgressHandler = (Double) -> Void

public enum NetworkManager {
    /// Used for a basic API request.
    /// Async/await pattern, throws NetworkManagerError error.
    /// - Parameters:
    ///   - url: String URL
    ///   - method: type HTTPMethod. Note: GET method receives query params
    ///   - parameters: Default nil. Mostly used for POST and PUT request.
    ///   - contentType: Default JSON type.
    ///   - headers: Default nil. Mostly used for JWT token.
    /// - Returns: Generic API response type.
    public static func request<T: Decodable>(url: String,
                                             method: HTTPMethod,
                                             parameters: [String: Any]? = nil,
                                             contentType: ContentType = .JSON,
                                             headers: [String: String]? = nil) async throws -> T {
        let request = try createRequest(url: url,
                                        method: method,
                                        parameters: parameters,
                                        contentType: contentType,
                                        headers: headers)
        return try await run(request: request)
    }

    /// Used for upload image file. Works with progress delegate.
    /// Async/await pattern,  throws NetworkManagerError error.
    /// - Parameters:
    ///   - url: String URL
    ///   - method: Works only with POST and PUT request
    ///   - data: UploadData type
    ///   - requestType: UploadRequestType
    ///   - headers: Default nil. Mostly used for JWT token.
    ///   - progressHandler:To track upload progess.
    /// - Returns: Generic API response type.
    public static func uploadRequest<T: Decodable>(url: String,
                                                   method: HTTPMethod,
                                                   data: UploadData,
                                                   requestType: UploadRequestType,
                                                   headers: [String: String]? = nil,
                                                   progressHandler: ProgressHandler? = nil) async throws -> T {
        guard method == .POST || method == .PUT || method == .PATCH else { throw NetworkManagerError.invalidHTTPMethod }
        let request = try createUploadRequest(url: url,
                                              method: method,
                                              data: data,
                                              requestType: requestType,
                                              headers: headers)
        return try await run(request: request, progressHandler: progressHandler)
    }
}

// MARK: - Private
private extension NetworkManager {
    static func createRequest(url: String,
                              method: HTTPMethod,
                              parameters: [String: Any]?,
                              contentType: ContentType,
                              headers: [String: String]?) throws -> URLRequest {
        guard var components = URLComponents(string: url) else { throw NetworkManagerError.invalidURL }

        if case .GET(let queryParameters) = method, let queryParameters = queryParameters {
            components.queryItems = queryParameters.map { (key: String, value: Any) in
                return URLQueryItem(name: key, value: "\(value)")
            }
        }

        guard let url = components.url else { throw NetworkManagerError.invalidURL }

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

    static func createUploadRequest(url: String,
                                    method: HTTPMethod,
                                    data: UploadData,
                                    requestType: UploadRequestType,
                                    headers: [String: String]?) throws -> URLRequest {
        guard let url = URL(string: url) else { throw NetworkManagerError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.raw

        var body = Data()

        switch requestType {
        case .binary:
            body.append(data.data)
            request.setValue(data.mimeType, forHTTPHeaderField: "Content-Type")
        case .multipartFormData:
            let boundary: String = UUID().uuidString
            let contentDisposition = "Content-Disposition: form-data; name=\"\(data.name)\""

            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("\(contentDisposition); filename=\"\(data.name)\(data.fileExtension)\"\r\n".utf8))
            body.append(Data("Content-Type: \(data.mimeType)\r\n".utf8))
            body.append(Data("\r\n".utf8))
            body.append(data.data)
            body.append(Data("\r\n".utf8))
            body.append(Data("--\(boundary)--\r\n".utf8))

            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = body

        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }

        return request
    }

    static func run<T: Decodable>(request: URLRequest, progressHandler: ProgressHandler? = nil) async throws -> T {
        let session = URLSession.shared
        let delegate = (progressHandler == nil) ? nil : NetworkManagerUploadProgressHandler(handler: progressHandler)
        let (data, response) = try await session.data(for: request, delegate: delegate)
        try validate(response)
        return try result(from: data)
    }
}

private extension NetworkManager {
    static func validate(_ response: URLResponse) throws {
        if let response = response as? HTTPURLResponse,
           response.statusCode < 200 || response.statusCode > 300 {
            throw NetworkManagerError.invalidStatusCode(code: response.statusCode)
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

// MARK: - NetworkManagerUploadProgressHandler

final class NetworkManagerUploadProgressHandler: NSObject, URLSessionTaskDelegate {
    let handler: ProgressHandler?

    init(handler: ProgressHandler?) {
        self.handler = handler
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        handler?(Double(totalBytesSent / totalBytesExpectedToSend))
    }
}
