//
//  CircleImageView.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/14.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

enum DefaultIconName: String {
    case user = "default_icon_user"
}

extension DefaultIconName {
    func createIcon() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}

final class CircleImageView: UIImageView {
    
    enum ShapeType {
        case square
        case round(radius: CGFloat)
        case circle
    }
    
    enum EdgeType {
        case none
        case edge
    }
    
    private var imageUrl: String?
    private var crop: Bool
    private var shapeType: ShapeType
    private var defaultImage: UIImage?
    private var edgeType: EdgeType
    private var aspectMode: AspectMode
    private var loadImageContentMode: ContentMode?

    convenience init(size: CGSize,
                     imageUrl: String? = nil,
                     crop: Bool = false,
                     shapeType: ShapeType = .square,
                     defaultIconName: DefaultIconName,
                     edgeType: EdgeType = .none,
                     aspectMode: AspectMode = .aspectFill,
                     loadImageContentMode: UIView.ContentMode? = nil) {
        self.init(size: size,
                  imageUrl: imageUrl,
                  crop: crop,
                  shapeType: shapeType,
                  defaultImage: defaultIconName.createIcon(),
                  edgeType: edgeType,
                  aspectMode: aspectMode,
                  loadImageContentMode: loadImageContentMode)
    }
    

    init(size: CGSize,
         imageUrl: String? = nil,
         crop: Bool = false,
         shapeType: ShapeType = .square,
         defaultImage: UIImage? = nil,
         edgeType: EdgeType = .none,
         aspectMode: AspectMode = .aspectFill,
         loadImageContentMode: UIView.ContentMode? = nil) {
        self.imageUrl = imageUrl
        self.crop = crop
        self.shapeType = shapeType
        self.defaultImage = defaultImage
        self.edgeType = edgeType
        self.aspectMode = aspectMode
        self.loadImageContentMode = loadImageContentMode
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        self.image = defaultImage
        
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        
        self.drawImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        self.image = defaultImage
        self.imageUrl = nil
    }
    
    /// Set the image URL and load the image from the network
    ///
    /// - Parameters:
    ///   - imageUrl: a url for loading an image
    func setImageUrl(imageUrl: String?) {
        self.imageUrl = imageUrl
        self.drawImage()
    }
    
    private func drawImage() {
        switch shapeType {
        case .square:
            switch edgeType {
            case .none:
                self.drawSquare()
            case .edge:
                self.drawEdgedSquare()
            }
        case .round(let radius):
            switch edgeType {
            case .none:
                self.drawRound(radius: radius)
            case .edge:
                self.drawEdgedRound(radius: radius)
            }
        case .circle:
            switch edgeType {
            case .none:
                self.drawCircle(width: 0)
            case .edge:
                self.drawEdgeCircle(width: 0)
            }
        }
    }
    
    private func drawSquare() {
        self.loadImage()
    }
    
    private func drawEdgedSquare() {
        self.drawEdge()
        self.loadImage()
    }
    
    private func drawRound(radius: CGFloat) {
        self.layer.cornerRadius = radius
        
        self.loadImage()
    }
    
    private func drawEdgedRound(radius: CGFloat) {
        self.layer.cornerRadius = radius
        
        self.drawEdge()
        self.loadImage()
    }
    
    private func drawCircle(width: CGFloat) {
        layer.cornerRadius = width * 0.5
        
        self.loadImage()
    }
    
    private func drawEdgeCircle(width: CGFloat) {
        layer.cornerRadius = width * 0.5
        
        self.drawEdge()
        self.loadImage()
    }
    
    private func loadImage() {
        (self as UIImageView).ex.loadUrl(imageUrl: imageUrl,
                                         processorOption: .resize,
                                         aspectMode: aspectMode, crop: crop,
                                         defaultImage: image, contentMode: loadImageContentMode)
    }
    
    private func drawEdge() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.5
    }
}
