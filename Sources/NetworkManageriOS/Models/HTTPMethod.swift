import Foundation

public enum HTTPMethod: Equatable {
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

    public static func == (lhs: HTTPMethod, rhs: HTTPMethod) -> Bool {
        switch (lhs, rhs) {
        case (.GET, .GET):
            return true
        case (.POST, .POST):
            return true
        case (.DELETE, .DELETE):
            return true
        case (.PUT, .PUT):
            return true
        default:
            return false
        }
    }
}
