//
//  ViewController.swift
//  UIRandomScroll
//
//  Created by Felipe Montoya on 2/6/22.
//

import UIKit

fileprivate enum ViewControllerConstants {
    static let scrollViewScale = 1.01
    static let stackViewYOffsetProportion = -0.23
    static let imageViewHeight = 300.0
    static let buttonTitle = "Ver imagen"
    static let defaultImageSystemName = "photo.fill"
    static let buttonImageSystemName = "arrowtrinagle.right.fill"
}

class ViewController: UIViewController {
   
    //MARK: - Properties -
    
    fileprivate weak var stackView: UIStackView!
    fileprivate weak var imageView: UIImageView!
    fileprivate weak var buttonView: UIButton!
    
    fileprivate var image: UIImage? {
        didSet {
            image != nil ? (self.imageView.image = image!) :
            (self.imageView.image = UIImage(systemName: ViewControllerConstants.defaultImageSystemName))
        }
    }

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height:self.view.frame.height * ViewControllerConstants.scrollViewScale)
        scrollView.backgroundColor = .quaternaryLabel
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .primaryActionTriggered)
        return scrollView
    }()
    
    fileprivate var addCenteredStackTo: (UIView) -> (UIStackView) -> Void {
        return { view in
            { [weak self] stack in
                guard let self = self else { return }
                stack.alignment = .center
                stack.axis = .vertical
                stack.translatesAutoresizingMaskIntoConstraints = false
                stack.spacing = 95.0
                let centerConstraints: [NSLayoutConstraint] = [
                    stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    stack.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: self.view.frame.height * ViewControllerConstants.stackViewYOffsetProportion),
                ]
                view.addSubview(stack)
                NSLayoutConstraint.activate(centerConstraints)
                self.stackView = stack
            }
        }
    }
    
    
    fileprivate var addImageViewTo: (UIStackView) -> (UIImageView) -> Void {
        return { stack in
            { [weak self] imageView in
                imageView.contentMode = .scaleAspectFill
                self?.addViewTo(stack)(imageView)
                self?.imageView = imageView
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                let centerConstraints: [NSLayoutConstraint] = [
                    stack.heightAnchor.constraint(equalToConstant: ViewControllerConstants.imageViewHeight)
                ]
                self?.image = UIImage(systemName: ViewControllerConstants.defaultImageSystemName)
                NSLayoutConstraint.activate(centerConstraints)
                
            }
        }
    }
    
    fileprivate var addButtonTo: (UIStackView) -> (UIButton) -> Void {
        return { stack in
            { [weak self] button in
                button.setImage(UIImage(systemName: ViewControllerConstants.buttonImageSystemName), for: .normal)
                button.setTitle(ViewControllerConstants.buttonTitle, for: .normal)
                self?.addViewTo(stack)(button)
                self?.buttonView = button
                
            }
        }
    }
    
    fileprivate var addViewTo: (UIStackView) -> (UIView) -> Void {
        return { stack in
            { newView in
                stack.addArrangedSubview(newView)
            }
        }
    }
    
    //MARK: - Methods -
    
    @objc func refreshControlAction() {
        ImageService.download(size: 350) { [weak self] result in
            guard let data = try? result.get() else {
                return
            }
            DispatchQueue.main.async {
                self?.image = UIImage(data: data)
                self?.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    func composeUI(on view: UIView) {
        addCenteredStackTo(view)(UIStackView())
        addImageViewTo(stackView)(UIImageView())
        addButtonTo(stackView)(UIButton(type: .system))
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        composeUI(on: self.scrollView)
        ImageService.download(size: 350) { [weak self] result in
            guard let data = try? result.get() else {
                print("error loading image")
                return
            }
            DispatchQueue.main.async {
                self?.image = UIImage(data: data)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(scrollView)
    }


}

