//
//  ImageViewExtension.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/14.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import Nuke

extension UIImageView: TargetedExtensionCompatible {}

public enum ProcessorsOption {
    case resize
    case resizeRound(radius: CGFloat)
    case resizeCircle
}

public typealias AspectMode = ImageProcessors.Resize.ContentMode

public extension TargetedExtension where Base: UIImageView {

    func loadUrl(imageUrl: String?,
                 processorOption: ProcessorsOption = ProcessorsOption.resize,
                 aspectMode: AspectMode = .aspectFill,
                 crop: Bool = false,
                 defaultImage: UIImage? = nil,
                 contentMode: UIView.ContentMode? = nil) {
        loadUrl(imageUrl: imageUrl,
                processorOption: processorOption,
                aspectMode: aspectMode,
                crop: crop,
                placeHolder: defaultImage,
                failureImage: defaultImage,
                contentMode: contentMode)
    }
    
    func loadUrl(imageUrl: String?,
                 processorOption: ProcessorsOption = ProcessorsOption.resize,
                 aspectMode: AspectMode = .aspectFill,
                 crop: Bool = false,
                 placeHolder: UIImage? = nil,
                 failureImage: UIImage? = nil,
                 contentMode: UIView.ContentMode? = nil) {
        guard let url: String = imageUrl,
            let loadUrl: URL = URL(string: url) else {
            base.image = failureImage
            return
        }
        
        let resizeProcessor = ImageProcessors.Resize(size: base.bounds.size,
                                                     contentMode: aspectMode, crop: crop)
        let processors: [ImageProcessing]
        
        switch processorOption {
        case .resize:
            processors = [resizeProcessor]
        case .resizeRound(let radius):
            processors = [resizeProcessor, ImageProcessors.RoundedCorners(radius: radius)]
        case .resizeCircle:
            processors = [resizeProcessor, ImageProcessors.Circle()]
        }
        
        let request = ImageRequest(
            url: loadUrl,
            processors: processors
        )
        var contentModes: ImageLoadingOptions.ContentModes?
        
        if let mode = contentMode {
            contentModes = ImageLoadingOptions.ContentModes.init(success: mode,
                                                                 failure: mode, placeholder: mode)
        }
        let loadingOptions = ImageLoadingOptions(placeholder: placeHolder,
                                                 failureImage: failureImage, contentModes: contentModes)
        
        Nuke.loadImage(with: request, options: loadingOptions, into: base)
    }
}
