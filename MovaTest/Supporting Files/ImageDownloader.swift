//
//  ImageDownloader.swift
//  MovaTest
//
//  Created by Danil Shchegol on 21.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import UIKit

final class ImageDownloader {
    
    static let shared = ImageDownloader()
    
    private init() {}
        
    func download(url: URL, activityIndicator: UIActivityIndicatorView? = nil, completion: @escaping (_ image: UIImage?) -> Void) {
        
        //removing all "/" symbols in URL for proper image saving
        if let mediaSubstring = url.absoluteString.split(separator: "/").last {
            
            let mediaFileName = String(mediaSubstring)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                //GIF has been already saved
                if let cachedData = self?.loadDataFromDiskWith(fileName: mediaFileName),
                    let image = UIImage.gifImageWithData(data: cachedData) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    //showing activityView before download starts
                    DispatchQueue.main.async {
                        activityIndicator?.startAnimating()
                    }
                    //download starts here
                    if let data = try? Data(contentsOf: url) as NSData, let image = UIImage.gifImageWithData(data: data) {
                        //saving image to documents folder after download completed
                        self?.saveData(fileName: mediaFileName, data: data)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    private func saveData(fileName: String, data: NSData) {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }

    private func loadDataFromDiskWith(fileName: String) -> NSData? {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return nil }
        
        let localUrl = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: localUrl.path) {
            if let data = NSData(contentsOfFile: localUrl.path) {
                return data
            }
        }
        return nil
    }
}
