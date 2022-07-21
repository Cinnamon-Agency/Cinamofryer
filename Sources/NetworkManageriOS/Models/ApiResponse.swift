import Foundation

struct ApiResponse<T>: Decodable where T: Decodable {
    let data: T
}
