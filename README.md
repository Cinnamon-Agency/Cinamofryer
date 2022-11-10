# Cinnanet

Cinnanet is an HTTP networking library written in Swift.

A lightweight networking manager used for simple and clear network calls.

## Installation

### Swift Package Manager

Cinnanet can be installed via the official [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

1. Go to `File` > `Swift Packages` > `Add Package Dependency`
2. Paste the project URL: `https://github.com/cinnanet/cinnanet.git`
3. Click on next, select the project target and click finish.

Then simply `import Cinnanet` wherever you’d like to use it.


## Requirements

* Xcode 13.0+
* iOS 15.0+

Works only with the `async`/`await` pattern.


## Usage

### Basic API request

Used for basic API calls.

``` swift
public static func request<T: Decodable>(url: String,
                                         method: HTTPMethod,
                                         parameters: [String: Any]? = nil,
                                         contentType: ContentType = .JSON,
                                         headers: [String: String]? = nil) async throws -> T
```

#### HTTP Methods

Use `GET`, `POST`, `DELETE`, `PUT` & `PATCH` methods to make network calls.

``` swift
public enum HTTPMethod {
    case GET(query: [String: Any]? = nil)
    case POST
    case DELETE
    case PUT
    case PATCH
}
```

####  Examples 

#####  GET request 


```swift
func getAllUsers(url: String) async throws -> ApiResponse<[User]> {
    try await NetworkManager.request(url: url, method: .GET())
}
```

##### POST request


``` swift
func verifyEmail(url: String) async throws -> ApiResponse<EmailVerificationResponse> {
    try await NetworkManager.request(url: url,
                                     method: .POST,
                                     parameters: ["email": "example@mail.com"],
                                     contentType: .JSON,
                                     headers: SessionManager.shared.authorizationHeader)
}
```

### Upload image API request

Used for a basic image upload.

``` swift
public static func uploadRequest<T: Decodable>(url: String,
                                               method: HTTPMethod,
                                               data: UploadData,
                                               requestType: UploadRequestType,
                                               headers: [String: String]? = nil,
                                               progressHandler: ProgressHandler? = nil) async throws -> T
```

#### Upload Request Type

``` swift
public enum UploadRequestType {
    case binary
    case multipartFormData
}
```

#### Example

``` swift
func uploadPhoto(url: String, data: Data) async throws -> Bool {
    try await NetworkManager.uploadRequest(url: url,
                                           method: .POST,
                                           data: UploadData(name: "fileName", data: data, type: .pngPhoto),
                                           requestType: .multipartFormData,
                                           progressHandler: { progress in
                                              // Do something
                                           })
}
```

You can pass the `progressUpload` handler to this method whenever you need to show the user the progress of their upload.

### Error handling

Throws `NetworkManagerError`.

``` swift
enum NetworkManagerError: Error {
    // If the response status code is not in [200, 299]
    case invalidStatusCode(code: Int)
    
    // If the passed url string cannot be converted to URL data model
    case invalidURL
    
    // If the passed HTTPMethod is not allowed (e.g. GET for image upload request)
    case invalidHTTPMethod
}
```

If the error is caused by `JSONDecoder`, `JSONEncoder` or `JSONSerialization` - you'll probably want to log it to the console to see the exact source of the problem.


### Decoding

The response is decoded to generic type `T`.

We mainly using the following model for the API response:

``` swift
struct ApiResponse<T>: Decodable where T: Decodable {
    let code: Int
    let message: String
    let data: T
}
```

### Encoding

If you need to send a request using URL encoded form data, set `contentType` to `.formUrlEncoded`. Default is `.JSON`.

``` swift
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

public enum ParameterEncoding {
    case JSONEncoding
    case URLEncoding
}
```
