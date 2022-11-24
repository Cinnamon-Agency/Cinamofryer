import Foundation

public enum HTTPMethod: Equatable {
    case GET(query: [String: Any]? = nil)
    case POST
    case DELETE
    case PUT
    case PATCH

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
        case .PATCH:
            return "PATCH"
        }
    }

    public static func == (lhs: HTTPMethod, rhs: HTTPMethod) -> Bool {
        return lhs.raw == rhs.raw
    }
}
