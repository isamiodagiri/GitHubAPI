//
//  RepositoryWebViewController.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/19.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import WebKit
import RxWebKit
import RxSwift
import RxCocoa

class RepositoryWebViewController: UIViewController {
    
    static func instance(at url: String?) -> RepositoryWebViewController {
        let vc = RepositoryWebViewController()
        vc.accessUrl = url
        return vc
    }
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    
    let disposeBag = DisposeBag()
    var accessUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupBarButton()
    }
    
    func setupBarButton() {
        forwardButton.rx.tap
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.webView.goForward()
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.webView.goBack()
            })
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.showSharedSheet()
            })
            .disposed(by: disposeBag)
        
        stopButton.rx.tap
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.webView.stopLoading()
            })
            .disposed(by: disposeBag)
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if let urlStr = accessUrl, let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        webView.rx.canGoBack
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.backButton.isEnabled = $0
            })
            .disposed(by: disposeBag)

        webView.rx.canGoForward
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.forwardButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        webView.rx.loading
            .share(replay: 1)
            .subscribe(onNext: { [unowned self] in
                self.stopButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        webView.rx.title
            .filter {$0 != nil }
            .bind { [unowned self] response in
                self.title = response
            }
            .disposed(by: disposeBag)
    }
    
    func showSharedSheet() {
        guard let title = title,
            let urlStr = accessUrl,
            let url = URL(string: urlStr) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}

extension RepositoryWebViewController: WKNavigationDelegate {}
