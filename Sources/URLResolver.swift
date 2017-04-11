//
//  URLResolver.swift
//  MetalScopeViewerProfile
//
//  Created by Jun Tanaka on 2017/04/11.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import Foundation

public final class URLResolver {
    public enum Error: Swift.Error {
        case cancelled
        case invalidURL
        case base64DecodingFailed
        case sessionTaskFailed(Swift.Error)
    }

    public final class CancellationToken {
        let task: URLSessionTask

        init(task: URLSessionTask) {
            self.task = task
        }

        public func cancel() {
            task.cancel()
        }
    }

    public let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    public func resolve(url: URL, completionHandler: @escaping (Data?, Error?) -> Void) -> CancellationToken? {
        func getData(from url: URL) throws -> Data {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw Error.invalidURL
            }

            guard let base64 = components.queryItems?.flatMap({ $0.name == "p" ? $0.value : nil }).first else {
                throw Error.invalidURL
            }

            var safeString = base64
                .replacingOccurrences(of: "-", with: "+", options: .literal, range: nil)
                .replacingOccurrences(of: "_", with: "/", options: .literal, range: nil)
            while safeString.characters.count % 4 > 0 {
                safeString += "="
            }
            guard let data = Data(base64Encoded: safeString) else {
                throw Error.base64DecodingFailed
            }

            return data
        }

        if let data = try? getData(from: url) {
            completionHandler(data, nil)
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                if let error = error as? URLError, error.code == .cancelled {
                    completionHandler(nil, Error.cancelled)
                } else {
                    completionHandler(nil, Error.sessionTaskFailed(error))
                }
            } else if let resolvedURL = response?.url {
                do {
                    let data = try getData(from: resolvedURL)
                    completionHandler(data, nil)
                } catch let error as Error {
                    completionHandler(nil, error)
                } catch {
                    fatalError("Unexpexted error")
                }
            } else {
                completionHandler(nil, Error.invalidURL)
            }
        }

        task.resume()

        return CancellationToken(task: task)
    }
}
