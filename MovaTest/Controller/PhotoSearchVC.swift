//
//  ViewController.swift
//  MovaTest
//
//  Created by Danil Shchegol on 21.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import UIKit
import RealmSwift

final class PhotoSearchVC: UIViewController {
    
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search images"
        searchBar.returnKeyType = .done
        return searchBar
    }()
    
    private var notificationToken: NotificationToken?
    private let history = RealmManager.default.objects(PhotoQuery.self).sorted(byKeyPath: "date", ascending: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        observeRealm()
        
        [searchBar, collectionView].forEach { view.addSubview($0) }
        
        searchBar.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
                
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //automatic updating collection view when PhotoQuery object collection modifies
    private func observeRealm() {
        notificationToken = history.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial: self.collectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.performBatchUpdates(deletions: deletions, insertions: insertions, modifications: modifications)
            case .error(let err): fatalError("\(err)")
            }
        }
    }
}

extension PhotoSearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.count > 0 else { return }
        NetworkingManager.shared.searchGIF(with: text) { [weak self] (result, error) in
            if let result = result {
                RealmManager.add(objects: [result])
            } else if let error = error {
                let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                self?.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension PhotoSearchVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.configure(with: history[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
    }
    
    func performBatchUpdates(deletions: [Int], insertions: [Int], modifications: [Int]) {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
            collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
            collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
        }, completion: nil)
    }
}

