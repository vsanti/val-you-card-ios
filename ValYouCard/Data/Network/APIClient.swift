import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum AppError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case notFound
    case validationError(String)
    case redemptionFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let error): return error.localizedDescription
        case .decodingError(let error): return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(_, let message): return message ?? "Server error"
        case .unauthorized: return "Session expired. Please sign in again."
        case .notFound: return "Resource not found"
        case .validationError(let message): return message
        case .redemptionFailed(let message): return message
        case .unknown(let message): return message
        }
    }
}

struct APIRequest {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem]?
    var body: Encodable?
    var headers: [String: String]?
}

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(
        baseURL: String,
        _ apiRequest: APIRequest,
        defaultQueryItems: [URLQueryItem] = []
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + apiRequest.path) else {
            throw AppError.invalidURL
        }

        var allQueryItems = defaultQueryItems
        if let queryItems = apiRequest.queryItems {
            allQueryItems.append(contentsOf: queryItems)
        }
        if !allQueryItems.isEmpty {
            components.queryItems = allQueryItems
        }

        guard let url = components.url else {
            throw AppError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = apiRequest.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers = apiRequest.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = apiRequest.body {
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw AppError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AppError.decodingError(error)
            }
        case 401:
            throw AppError.unauthorized
        case 404:
            throw AppError.notFound
        default:
            let message = try? decoder.decode(ErrorResponse.self, from: data)
            throw AppError.serverError(statusCode: httpResponse.statusCode, message: message?.error)
        }
    }
}

private struct ErrorResponse: Decodable {
    let error: String?
    let message: String?
}

private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        self.encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
