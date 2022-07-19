
import Foundation

struct RequestInfo {
    var url: String
    var method: HttpMethod = .GET
    var parameters: [String: Any]?
    var isAuthorized: Bool = false
    var header: [String: String]?
}

enum HttpMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}
