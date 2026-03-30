import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let completeOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) {
 data,
 response,
            error in
            if let error {
                print(
                    "[URLSession.data]: urlRequestError - \(error.localizedDescription)"
                )
                completeOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard
                let data,
                let httpResponse = response as? HTTPURLResponse
            else {
                print("[URLSession.data]: urlSessionError")
                completeOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard (200 ..< 300).contains(statusCode) else {
                print("[URLSession.data]: httpStatusCode(\(statusCode))")
                completeOnMain(
                    .failure(NetworkError.httpStatusCode(statusCode))
                )
                return
            }
            
            completeOnMain(.success(data))
        }
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print(
                        "[URLSession.objectTask]: decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")"
                    )
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
