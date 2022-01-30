//
//  FetchMusicDataManager.swift
//  FLOApp
//
//  Created by yc on 2022/01/25.
//

import Foundation

struct FetchMusicDataManager {
    
    func fetchMusicData(completionHandler: @escaping ((Music) -> Void)) {
        let urlString = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse else { return }
            
            switch response.statusCode {
            case (200...299):
                guard let result = try? JSONDecoder().decode(Music.self, from: data) else { return }
                completionHandler(result)
            default:
                print("response statusCode is not in (200...299)")
            }
        }.resume()
    }
}
