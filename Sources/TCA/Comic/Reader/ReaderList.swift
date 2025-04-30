//
//  ReaderList.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/25.
//

import UIKit
import IdentifiedCollections
import Kingfisher
import SwiftUI

struct ReaderList: UIViewRepresentable {
    let imageData: IdentifiedArrayOf<ReaderFeature.Image>
    let isHorizontal: Bool
    
    func makeUIView(context: Context) -> CollectionView {
        return .init()
    }
    
    func updateUIView(_ uiView: CollectionView, context: Context) {
        uiView.reloadUI(imageData: imageData, isHorizontal: isHorizontal)
    }
}

final class CollectionView: UICollectionView {
    var imageData: IdentifiedArrayOf<ReaderFeature.Image> = []
    var images: [IndexPath: UIImage] = [:] // 已下載的 temp image
    var isHorizontal: Bool = true
    
    init() {
        super.init(frame: .zero, collectionViewLayout: .init())
        setupSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSelf() {
        self.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        self.contentInsetAdjustmentBehavior = .never
        self.delegate = self
        self.dataSource = self
        setupLayout(view: self, isHorizontal: isHorizontal)
    }
    
    func reloadUI(imageData: IdentifiedArrayOf<ReaderFeature.Image>, isHorizontal: Bool) {
        self.imageData = imageData
        self.isHorizontal = isHorizontal
        self.images.removeAll()
        setupLayout(view: self, isHorizontal: isHorizontal)
        reloadData()
    }
}

extension CollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
                let data = imageData[indexPath.item]
                
                cell.callback = { image in
                    DispatchQueue.main.async { [weak self] in
                        self?.images[indexPath] = image
                        UIView.setAnimationsEnabled(false)
                        collectionView.reloadItems(at: [indexPath])
                        UIView.setAnimationsEnabled(true)
                    }
                }
                
                if let image = images[indexPath] {
                    cell.imgView.image = image
                }
                else {
                    cell.reloadUI(uri: data.uri)
                }
                
                return cell
    }
}

extension CollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var result = collectionView.frame.size
        
        switch isHorizontal {
        case true:
            return result
        case false:
            if let image = images[indexPath], let ratio = makeRatio(image: image, maxWidth: result.width) {
                // 有小數點會造成產生一條白線
                let height = Int(image.size.height * ratio)
                result.height = CGFloat(height)
            }
            
            return result
        }
    }
}

final class Cell: UICollectionViewCell {
    let imgView = UIImageView(frame: .zero)
    
    let modifier = AnyModifier { request in
        var result = request
        result.setValue(.UserAgent.safari.value, forHTTPHeaderField: "User-Agent")
        result.setValue("https://tw.manhuagui.com", forHTTPHeaderField: "Referer")
        return result
    }
    
    var callback: ((UIImage) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupSelf()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadUI(uri: String) {
        imgView.kf.indicatorType = .activity
        
        imgView.kf.setImage(
            with: URL(string: uri),
            options: [
                .requestModifier(modifier),
                .processor(DownsamplingImageProcessor(size: imgView.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]) { [weak self] result in
                guard let self else { return }
                if case let .success(value) = result {
                    callback?(value.image)
                }
            }
    }
    
    func setupSelf() {
        backgroundColor = .white
    }
    
    func addViews() {
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        contentView.addSubview(imgView)
        
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

@MainActor
private func setupLayout(view: CollectionView, isHorizontal: Bool) {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = isHorizontal ? .horizontal : .vertical
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    view.isPagingEnabled = isHorizontal ? true : false
    view.alwaysBounceVertical = isHorizontal ? false : true
    view.alwaysBounceHorizontal = isHorizontal ? true : false
    view.showsVerticalScrollIndicator = isHorizontal ? false : true
    view.showsHorizontalScrollIndicator = isHorizontal ? true : false
    view.setCollectionViewLayout(layout, animated: false)
    layout.invalidateLayout()
}

private func makeRatio(image: UIImage?, maxWidth: CGFloat?) -> CGFloat? {
    guard let image, let maxWidth else {
        return 1
    }
    
    guard image.size.width > 0, image.size.height > 0 else {
        return 1
    }
    
    return maxWidth / image.size.width
}
