import Foundation

public enum ContentType: String {
    case JSON = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded; charset=utf-8"

    var encoding: ParameterEncoding {
        switch self {
        case .JSON:
            return .JSONEncoding
        case .formUrlEncoded:
            return .URLEncoding
        }
    }
}
