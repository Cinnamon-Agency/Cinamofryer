import Foundation

struct APIResponse<T>: Decodable where T: Decodable {
    let code: Int
    let data: T
    let message: String
}

struct EmptyResponse: Decodable {
    let code: Int
    let message: String
}
