//
//  FileDownloader.swift
//  News
//
//  Created by switchMac on 7/24/24.
//

import Foundation

class FileDownloader {
    static let shared = FileDownloader()

    private init() {}

    func downloadImage(from url: URL, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let session = URLSession(configuration: .default)
        let downloadTask = session.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "Invalid Temp URL", code: 1, userInfo: nil)))
                return
            }

            do {
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsURL.appendingPathComponent(fileName)

                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.copyItem(at: tempURL, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        downloadTask.resume()
    }
}
