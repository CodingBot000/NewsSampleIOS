//
//  ContentView.swift
//  News
//
//  Created by switchMac on 7/21/24.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = NewsViewModel()
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @State private var isLandscape = UIDevice.current.orientation.isLandscape
    @State private var showAlert = false
        
    var body: some View {
        NavigationView {
            Group {
                if isLandscape {
                    GridView(articles: viewModel.articles, toggleSelection: viewModel.toggleSelection, showAlert: $showAlert)
                } else {
                    ListView(articles: viewModel.articles, toggleSelection: viewModel.toggleSelection, showAlert: $showAlert)
                }
            }
            .navigationBarTitle("News")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Network Error"), message: Text("Cannot connect to the network"), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.fetchNews()
                self.isLandscape = UIDevice.current.orientation.isLandscape
            }
            .onRotate { newOrientation in
                self.isLandscape = newOrientation.isLandscape
            }
        }
    }
}


struct ListView: View {
    let articles: [NewsArticle]
    let toggleSelection: (String) -> Void

    @Binding var showAlert: Bool
    
    @State private var selectedArticle: NewsArticle? = nil
    @State private var showWebView = false
    
    private let listItemImgLength : CGFloat = 150.0
    
    var body: some View {
        List(articles) { article in
            NavigationLink(destination: WebViewScreen(url: URL(string: article.url)!, title: article.title)
                .onAppear {
                    if NetworkMonitor.shared.isConnected {
                       toggleSelection(article.publishedAt ?? "")
                   } else {
                       showAlert = true
                   }
            })
            {
                HStack {
                    if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                        if NetworkMonitor.shared.isConnected {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: listItemImgLength, height: listItemImgLength)
                                        .clipped()
                                } else if phase.error != nil {
                                    Color.red.frame(width: listItemImgLength, height: listItemImgLength)
                                } else {
                                    ProgressView().frame(width: listItemImgLength, height: listItemImgLength)
                                }
                            }
                        } else {
                            if let localImage = loadLocalImage(publishedAt: article.publishedAt) {
                                Image(uiImage: localImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: listItemImgLength, height: listItemImgLength)
                                    .clipped()
                            }
                        }
                    } else {
                        Color.gray.frame(width: listItemImgLength, height: listItemImgLength)
                    }
                    VStack(alignment: .leading) {
                        Text(article.title)
                            .font(.headline)
                            .foregroundColor(article.isSelected ? .red : .primary)
                            .lineLimit(3)
                        Text(article.author ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(dateConvertForDisplay(article.publishedAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(article.description ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(5)

                    }
                }
                .contentShape(Rectangle())
            }
        }
    }

}

struct GridView: View {
    let articles: [NewsArticle]
    let toggleSelection: (String) -> Void
    @Binding var showAlert: Bool
    
    @State private var selectedArticle: NewsArticle? = nil
    @State private var showWebView = false
  
    var spacing: CGFloat {
        return 10
    }
    
    var columns: [GridItem] {
        return [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]
    }

    var body: some View {

        let imgLength = (UIScreen.main.bounds.width - (spacing * 4)) / 3
        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                
                ForEach(articles) { article in
                    NavigationLink(destination: WebViewScreen(url: URL(string: article.url)!, title: article.title)
                        .onAppear {
                            if NetworkMonitor.shared.isConnected {
                               toggleSelection(article.publishedAt ?? "")
                            } else {
                                showAlert = true
                            }
                       }
                    ) {
                        VStack {
                            if NetworkMonitor.shared.isConnected {
                                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                                    
                                    GeometryReader { geometry in
                                        var gridItemLength = geometry.size.width
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: gridItemLength, height: gridItemLength)
                                                    .clipped()
                                            } else if phase.error != nil {
                                                Color.red
                                                    .frame(width: gridItemLength, height: gridItemLength)
                                            } else {
                                                ProgressView().frame(width: gridItemLength, height: gridItemLength)
                                            }
                                        }
                                    }
                                    .frame(height: imgLength - 50)
                                } else {
                                    Color.gray.frame(width: imgLength, height: imgLength)
                                }
                            } else {
                                if let localImage = loadLocalImage(publishedAt: article.publishedAt) {
                                    GeometryReader { geometry in
                                        var gridItemLength = geometry.size.width
                                        Image(uiImage: localImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: gridItemLength, height: gridItemLength)
                                            .clipped()
                                    }
                                    .frame(height: imgLength - 50)
                                }
                            }
                            Text(article.author ?? "Empty")
                                .font(.caption)
                                .foregroundColor(.black)
                            Text(dateConvertForDisplay(article.publishedAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(article.title)
                                .font(.headline)
                                .foregroundColor(article.isSelected ? .red : .primary)
                                .lineLimit(2)
                            
                            Text(article.description ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                }
            }
            .padding()
        }
    }
}

struct OnRotateModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: observeRotation)
    }
    
    private func observeRotation() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            action(UIDevice.current.orientation)
        }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(OnRotateModifier(action: action))
    }
}

func loadLocalImage(publishedAt: String) -> UIImage? {
        let fileName = "\(publishedAt).jpg"
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
