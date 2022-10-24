# Cinnanet

Cinnanet is an HTTP networking library written in Swift.

Simple network manager used for simple applications that need network calls.

## Installation

#### Swift Package Manager

1. Using Xcode 11 or higher go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/cinnanet/cinnanet.git
3. Click on next, select the project target and click finish
4. `Import Cinnanet`

## Usage

Works only with Async/Await pattern.

### Basic API request

``` swift
    public static func request<T: Decodable>(url: String,
                                             method: HTTPMethod,
                                             parameters: [String: Any]? = nil,
                                             contentType: ContentType = .JSON,
                                             headers: [String: String]? = nil) async throws -> T {
        let request = try createRequest(url: url,
                                        method: method,
                                        parameters: parameters,
                                        contentType: contentType,
                                        headers: headers)
        return try await run(request: request)
    }
```

####  GET request 
 

```swift
func getAllRepos(url: String) -> ApiResponse<[Repo]> {
    async try NetworkManager.request(url: url, method: .GET)
}
```

#### Example POST request
 

``` swift
  func verifyEmail(url: String) async throws -> ApiResponse<EmailVerificationResponse> {
        try await NetworkManager.request(url,
                                             method: .POST,
                                             parameters: ["email": "dummyEmail"],
                                             contentType = .JSON,
                                             headers: SessionManager.shared.authorizationHeader){
    }
```

### Upload image API request

Used for basic API call and upload image.


### TODO

### Error handling

Throws NetworkManagerError error.

``` swift
enum NetworkManagerError: Error {
    // If the error is Out of the range <200, 300>. We want to handle every error with status code.
    case invalidStatusCode(code: Int)
    
    // When converting url property from String to URL data model
    case invalidURL
    
    // If for example set HTTPMethod type GET for image upload request
    case invalidHTTPMethod
}
```

If the error is caused by JSONDecoder the error should be logged in console to see which property of the data model is false.
Same for JSONEncoding and JSONSerialization.

### Decoding

Decoding response in generic type T. We mostly use model:
``` swift
ApiResponse<T> {
    let code: String
    let message: String
    let data: T
} 
```

### Encoding

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
