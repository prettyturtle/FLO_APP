//
//  String+.swift
//  FLOApp
//
//  Created by yc on 2022/01/30.
//

import Foundation

extension String {
    var removeTimeLyricsString: String {
        let textList = self.split(separator: "\n")
        var lyricsList = [String]()
        textList.forEach {
            let line = $0.split(separator: "]").map { String($0) }
            lyricsList.append(line[1])
        }
        return lyricsList.joined(separator: "\n")
    }
    var getTimeOfLyrics: [Float] {
        let textList = self.split(separator: "\n")
        var timeList = [Float]()
        
        textList.forEach {
            let tempLine = $0.split(separator: "[").map { String($0) }[0]
            let line = tempLine.split(separator: "]").map { String($0) }[0]
            let splittedTime = line.split(separator: ":").map { Int($0) ?? 0 }
            let min = Float(splittedTime[0])
            let sec = Float(splittedTime[1])
            let millisec = Float(splittedTime[2])
            let sumTime: Float = min*60.0 + sec + millisec / 1000.0
            timeList.append(sumTime)
        }
        return timeList
    }
}
