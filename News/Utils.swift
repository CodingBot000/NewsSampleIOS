//
//  Utils.swift
//  News
//
//  Created by switchMac on 7/24/24.
//

import Foundation


func dateConvertForDisplay(_ dateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [
        .withInternetDateTime,
        .withFractionalSeconds
    ]

    let outputDateFormat = "yyyy-MM-dd"
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.dateFormat = outputDateFormat
    outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    outputDateFormatter.timeZone = TimeZone.current
    
    if let date = isoFormatter.date(from: dateString) {
        return outputDateFormatter.string(from: date)
    } else {
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return outputDateFormatter.string(from: date)
        }
    }
    
    return ""

}
