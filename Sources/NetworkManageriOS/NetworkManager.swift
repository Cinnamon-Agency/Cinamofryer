
import Foundation

public struct NetworkManageriOS {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

enum NetworkManager {
    static func performRequest<T: Decodable>(_ requestInfo: RequestInfo) async throws -> T {
        let urlSession = URLSession.shared
        let request = try createRequest(with: requestInfo)
        let (data, response) = try await urlSession.data(for: request)

        try validate(response)

        return try result(from: data)
    }
}

private extension NetworkManager {
    static func createRequest(with requestInfo: RequestInfo) throws -> URLRequest {
        var request = URLRequest(url: URL(string: requestInfo.url)!)

        request.httpMethod = requestInfo.method.rawValue

        if let parameters = requestInfo.parameters {
            let bodyParams = try NetworkManager.encode(parameters)
            request.httpBody = bodyParams
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        }

        if let header = requestInfo.header {
            request.allHTTPHeaderFields = header
        }

        return request
    }

    static func validate(_ response: URLResponse) throws {
        if let response = response as? HTTPURLResponse,
           response.statusCode < 200 || response.statusCode > 300 {
            throw NetworkError.invalidStatusCode
        }
    }

    static func result<T: Decodable>(from data: Data) throws -> T {
        guard let decodedData = try? JSONDecoder().decode(ApiResponse<T>.self, from: data) else {
            throw NetworkError.failedToDecode
        }

        return decodedData.data
    }

    static func encode(_ value: [String: Any]) throws -> Data {
        guard let parameter = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            throw NetworkError.failedToEncode
        }

        return parameter
    }
}
