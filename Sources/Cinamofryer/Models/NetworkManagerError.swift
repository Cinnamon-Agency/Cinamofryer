import Foundation

enum NetworkManagerError: Error {
    case invalidStatusCode(code: Int)
    case invalidURL
    case invalidHTTPMethod
}
