import Foundation

enum CinamofryerError: Error {
    case invalidStatusCode(code: Int)
    case invalidURL
    case invalidHTTPMethod
}
