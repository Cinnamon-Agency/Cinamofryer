import Foundation

public enum UploadRequestType {
    case binary
    case multipartFormData
}

public struct UploadData {
    let name: String
    let data: Data
    let type: DataType

    public enum DataType {
        case jpegPhoto, pngPhoto
    }

    var mimeType: String {
        switch type {
        case .jpegPhoto:
            return "image/jpeg"
        case .pngPhoto:
            return "image/png"
        }
    }

    var fileExtension: String {
        switch type {
        case .jpegPhoto:
            return ".jpeg"
        case .pngPhoto:
            return ".png"
        }
    }
}
