
import Foundation

public struct RequestInfo {
    public var url: String
    public var method: HttpMethod = .GET
    public var parameters: [String: Any]?
    public var isAuthorized: Bool = false
    public var header: [String: String]?
}

public enum HttpMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}
