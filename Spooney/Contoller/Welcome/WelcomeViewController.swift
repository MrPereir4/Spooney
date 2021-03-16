//
//  WelcomeViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 26/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{
    
    let titles = ["A first glance", "No worries", "Ready, set, goal", "From the first step, a journey begins"]
    let aboutText = ["Welcome to Spooney, your new\nplatform to control your spendings!", "Put your monthly expenses and let\nSpooney organize them for you!", "Add your goals, and discover\nthe best way to achieve them!", "This is a beta version of Spooney,\nand more content are been developed!"]
    
    //MARK: - Properties
    
    private let welcomeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.isPrefetchingEnabled = false
        return cv
    }()
    
    private let controllersHolder: UIView = {
        let view = UIView()
        return view
    }()
    
    
    let image: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "logo"))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = titles.count
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .lightGray
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 25
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureImage()
    }
    
    //MARK: - Selector
    @objc private func handleNext(){
        
        let nextIndex = min(pageControl.currentPage + 1, titles.count - 1)
        
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        welcomeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        configGetReadyButton(screen: nextIndex)
        
    }
    
    @objc private func handleGetReady(){
        let nav = UINavigationController(rootViewController: CreateAccountViewController())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func configGetReadyButton(screen: Int){
        if screen == titles.count - 1{
            actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
            actionButton.setTitle("Get ready", for: .normal)
            actionButton.addTarget(self, action: #selector(handleGetReady), for: .touchUpInside)
        }else {
            actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
            actionButton.setTitle("Next", for: .normal)
            actionButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        }
    }
    
    //MARK: - Helper functions
    
    private func configure(){
        configureView()
        configurePageControllers()
        configureColletionView()
    }
    
    private func configureImage(){
        view.addSubview(image)
        image.anchor(top: view.topAnchor, paddingTop: 100, height: 80)
        image.centerX(inView: view)
    }
    
    private func configureView(){
        view.backgroundColor = .white
    }
    
    private func configurePageControllers(){
        view.addSubview(controllersHolder)
        
        controllersHolder.anchor(right: view.rightAnchor,
                                 bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                 left: view.leftAnchor,
                                 height: 100)
        
        
        
        controllersHolder.addSubview(actionButton)

        actionButton.anchor(right: controllersHolder.rightAnchor,
                            bottom: controllersHolder.safeAreaLayoutGuide.bottomAnchor,
                            left: controllersHolder.leftAnchor,
                            paddingRight: 64,
                            paddingBottom: 20,
                            paddingLeft: 64,
                            height: 50)
        
        controllersHolder.addSubview(pageControl)
        
        pageControl.anchor(right: controllersHolder.rightAnchor, bottom: actionButton.topAnchor, left: controllersHolder.leftAnchor)
    }
    
    private func configureColletionView(){
        view.addSubview(welcomeCollectionView)
        welcomeCollectionView.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: controllersHolder.topAnchor, left: view.leftAnchor)
        welcomeCollectionView.delegate = self
        welcomeCollectionView.dataSource = self
        welcomeCollectionView.backgroundColor = .white
        welcomeCollectionView.register(WelcomeViewCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    //MARK: - Configure colletion
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! WelcomeViewCell
        cell.title.text = titles[indexPath.item]
        cell.about.text = aboutText[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: welcomeCollectionView.frame.width, height: welcomeCollectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        let index = Int(x/view.frame.width)
        pageControl.currentPage = index
        configGetReadyButton(screen: index)
    }
}
