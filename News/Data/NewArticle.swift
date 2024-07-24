//
//  NewArticle.swift
//  News
//
//  Created by switchMac on 7/24/24.
//


struct NewsArticle: Identifiable, Codable {
    var id: String { publishedAt }
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    var isSelected: Bool = false
    
    struct Source: Codable {
        let id: String?
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
}

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}
