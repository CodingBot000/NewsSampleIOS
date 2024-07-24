//
//  DataMapper.swift
//  News
//
//  Created by switchMac on 7/22/24.
//

import Foundation

import CoreData

func mapNewsArticleToEntity(article: NewsArticle, context: NSManagedObjectContext) -> NewsArticleEntity {
    let entity = NewsArticleEntity(context: context)
    entity.id = article.id
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
    return entity
}

func mapEntityToNewsArticle(entity: NewsArticleEntity) -> NewsArticle {
    return NewsArticle(
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

func mapNewsArticlesToEntities(articles: [NewsArticle], context: NSManagedObjectContext) -> [NewsArticleEntity] {
    return articles.map { mapNewsArticleToEntity(article: $0, context: context) }
}

func mapEntitiesToNewsArticles(entities: [NewsArticleEntity]) -> [NewsArticle] {
    return entities.map { mapEntityToNewsArticle(entity: $0) }
}
