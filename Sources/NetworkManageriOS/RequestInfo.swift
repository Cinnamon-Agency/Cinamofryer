
import Foundation

public struct RequestInfo {
    public var url: String
    public var method: HttpMethod = .GET
    public var parameters: [String: Any]?
    public var isAuthorized: Bool = false
    public var header: [String: String]?

    public init(url: String, method: HttpMethod = .GET, parameters: [String: Any]? = nil, isAuthorized: Bool = false, header: [String: String]?) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.isAuthorized = isAuthorized
        self.header = header
    }
}

public enum HttpMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}
