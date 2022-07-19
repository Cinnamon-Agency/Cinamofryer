import Foundation

enum NetworkError: Error {
    case invalidStatusCode
    case failedToDecode
    case failedToEncode
}
