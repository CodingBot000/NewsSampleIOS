//
//  NewsRepository.swift
//  News
//
//  Created by switchMac on 7/21/24.
//

import Foundation
import CoreData

class NewsRepository {
    static let shared = NewsRepository()
    
    private init() {}
    
    func saveArticles(_ articles: [NewsArticle]) {
        let coreDataMgr = CoreDataManager.shared
        let context = coreDataMgr.context
        

        articles.forEach { article in
            if !isArticleExists(publishedAt: article.publishedAt) {
                let entity = NewsArticleEntity(context: context)
                entity.id = article.url
                entity.source_id = article.source.id
                entity.source_name = article.source.name
                entity.author = article.author
                entity.title = article.title
                entity.desc = article.description
                entity.url = article.url
                entity.urlToImage = article.urlToImage
                entity.publishedAt = article.publishedAt
                entity.content = article.content
                entity.isSelected = article.isSelected
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save articles: \(error.localizedDescription)")
        }
    }
    
    func isArticleExists(publishedAt: String) -> Bool {
           let context = CoreDataManager.shared.context
           let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", publishedAt)
           
           do {
               let count = try context.count(for: fetchRequest)
               return count > 0
           } catch {
               print("Failed to fetch article: \(error.localizedDescription)")
               return false
           }
       }
       
   func fetchArticle(publishedAt: String) -> NewsArticleEntity? {
       let context = CoreDataManager.shared.context
       let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
       fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", publishedAt)
       
       do {
           return try context.fetch(fetchRequest).first
       } catch {
           print("Failed to fetch article: \(error.localizedDescription)")
           return nil
       }
   }
   
   func fetchArticles() -> [NewsArticleEntity] {
       let context = CoreDataManager.shared.context
       let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
       
       do {
           return try context.fetch(fetchRequest)
       } catch {
           print("Failed to fetch articles: \(error.localizedDescription)")
           return []
       }
   }
    
    func fetchArticles() -> [NewsArticle] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { entity in
                NewsArticle(
                    source: NewsArticle.Source(id: entity.source_id, name: entity.source_name ?? ""),
                    author: entity.author,
                    title: entity.title ?? "",
                    description: entity.desc,
                    url: entity.url ?? "",
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt ?? "",
                    content: entity.content,
                    isSelected: entity.isSelected
                )
            }
        } catch {
            print("Failed to fetch articles: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func toggleSelection(publishedAt: String) {
            let context = CoreDataManager.shared.context
            let fetchRequest: NSFetchRequest<NewsArticleEntity> = NewsArticleEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", publishedAt)
            
            do {
                let entities = try context.fetch(fetchRequest)
                if let entity = entities.first {
//                    entity.isSelected.toggle()
                    entity.isSelected = true
                    try context.save()
                }
            } catch {
                print("Failed to toggle selection: \(error.localizedDescription)")
            }
        }
    
    
    func saveImageFile(_ articles: [NewsArticle]) {
        for article in articles {
            guard let urlString = article.urlToImage, let url = URL(string: urlString) else {
                       print("Invalid URL for article: \(article.title)")
                       continue
                   }
                   let fileName = "\(article.publishedAt).jpg"
                   FileDownloader.shared.downloadImage(from: url, fileName: fileName) { result in
                       switch result {
                       case .success(let fileURL):
                           print("File saved to: \(fileURL.path)")
                       case .failure(let error):
                           print("Error downloading file: \(error.localizedDescription)")
                       }
                   }
        }
    }
}
