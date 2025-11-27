//
//  HTTPService.swift
//
//  Created by Paulo Lazarini on 16/04/24.
//

import UIKit

private let dateFormaterFractionalSeconds: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

private let dateFormatterDefault: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

private let dateFormatterDateOnly: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

enum JSON {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormaterFractionalSeconds)
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = dateFormaterFractionalSeconds.date(from: dateString) {
                return date
            }
            
            if let date = dateFormatterDefault.date(from: dateString) {
                return date
            }
            
            if let date = dateFormatterDateOnly.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Formato de data inválido: \(dateString)")
        }
        return decoder
    }()
}

public protocol HTTPClient {
    func request(endpoint: Endpoint) async -> Result<Void, RequestError>
    func requestModel<T: Decodable>(endpoint: Endpoint) async -> Result<T, RequestError>
    func requestSingle<T: Decodable>(endpoint: Endpoint) async -> Result<T, RequestError>
    
}

public extension HTTPClient {
    func requestSingle<T: Decodable>(
        endpoint: Endpoint
    ) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme.rawValue
        urlComponents.host = endpoint.baseURL
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.parameters
        
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = endpoint.body {
            do {
                request.httpBody = try JSON.encoder.encode(body)
            } catch {
                return .failure(.encode)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            
            switch response.statusCode {
            case 200...299:
                do {
                    let decodedArray = try JSON.decoder.decode([T].self, from: data)
                    guard let firstElement = decodedArray.first else {
                        return .failure(.noResponse)
                    }
                    return .success(firstElement)
                } catch {
                    return .failure(.decode)
                }
                
            case 401:
                return .failure(.unauthorized)
                
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    func requestModel<T: Decodable>(
        endpoint: Endpoint
    ) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme.rawValue
        urlComponents.host = endpoint.baseURL
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.parameters
        
        guard let url = urlComponents.url else {
            print("🔴 Falha ao criar URL a partir dos componentes.")
            return .failure(.invalidURL)
        }
        
        print("✅ URL Construída: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = endpoint.body {
            do {
                let bodyData = try JSON.encoder.encode(body)
                request.httpBody = bodyData
                print("✅ Corpo (Body) JSON: \(String(data: bodyData, encoding: .utf8) ?? "Corpo vazio ou inválido")")
            } catch {
                print("🔴 Falha ao codificar o Body: \(error)")
                return .failure(.encode)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            
            print("✅ JSON Recebido: \(String(data: data, encoding: .utf8) ?? "JSON Vazio ou Inválido")")
            
            switch response.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSON.decoder.decode(T.self, from: data)
                    return .success(decodedResponse)
                } catch {
                    print("🔴 Falha ao decodificar a resposta JSON: \(error)")
                    return .failure(.decode)
                }
                
            case 401:
                return .failure(.unauthorized)
                
            default:
                print("🔴 Status Code inesperado: \(response.statusCode)")
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            print("🔴 URLSession falhou com erro: \(error.localizedDescription)")
            return .failure(.networkError(error))
        }
    }
    
    func request(
        endpoint: Endpoint
    ) async -> Result<Void, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme.rawValue
        urlComponents.host = endpoint.baseURL
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.parameters
        
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = endpoint.body {
            do {
                let bodyData = try JSON.encoder.encode(body)
                request.httpBody = bodyData
                print("✅ Corpo (Body) JSON: \(String(data: bodyData, encoding: .utf8) ?? "Corpo vazio ou inválido")")
            } catch {
                return .failure(.encode)
            }
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            switch response.statusCode {
            case 200...299:
                return .success(Void())
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}
