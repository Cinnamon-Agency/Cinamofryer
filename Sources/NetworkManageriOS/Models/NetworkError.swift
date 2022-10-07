import Foundation

enum NetworkError: Error {
    case invalidStatusCode(code: Int)
    case invalidURL
    case invalidHTTPMethod
}
