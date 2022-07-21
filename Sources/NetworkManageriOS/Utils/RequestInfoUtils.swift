import Foundation

public protocol RequestInfoUtils {
    func getParams<T: Codable>(_ value: T) throws -> [String: Any]
}

extension RequestInfoUtils {
    func getParams<T: Codable>(_ value: T) throws -> [String: Any] {
        guard let parameters = try? value.asDictionary() else {
            throw NetworkError.failedToEncode
        }

        return parameters
    }
}
