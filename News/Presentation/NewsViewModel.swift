//
//  NewsViewModel.swift
//  News
//
//  Created by switchMac on 7/21/24.
//

import SwiftUI
import Combine
import Alamofire


class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    private var cancellable: AnyCancellable?

    func fetchNews() {
        if NetworkMonitor.shared.isConnected {
            fetchNewsFromNetwork()
        } else {
            fetchNewsFromCoreData()
        }
    }
    
    private func fetchNewsFromNetwork() {
    
        AF.request(urlString)
                    .validate()
                    .responseDecodable(of: NewsResponse.self) { response in
                        switch response.result {
                        case .success(let newsResponse):
                            self.articles = newsResponse.articles
                            self.syncWithCoreData()
                            NewsRepository.shared.saveArticles(newsResponse.articles)
                            
                            NewsRepository.shared.saveImageFile(newsResponse.articles)
                        case .failure(let error):
                            print("Failed to fetch news: \(error)")
                            self.articles = []
                            NewsRepository.shared.saveArticles([])
                        }
                    }
    }
    
    
    private func syncWithCoreData() {
        for index in articles.indices {
            let article = articles[index]
            if let storedArticle = NewsRepository.shared.fetchArticle(publishedAt: article.publishedAt) {
                if (storedArticle.isSelected) {
                    // true-> false로 하는 케이스는 없음
                    articles[index].isSelected = true
                }
            } else {
                NewsRepository.shared.saveArticles([article])
            }
        }
    }
    
    private func fetchNewsFromCoreData() {
        self.articles = NewsRepository.shared.fetchArticles()
        print("self.articles :  \(self.articles)")
    }
    
    func toggleSelection(publishedAt: String) {
        NewsRepository.shared.toggleSelection(publishedAt: publishedAt)
        self.fetchNewsFromCoreData()
    }
}
