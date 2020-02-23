//
//  PhotoCell.swift
//  MovaTest
//
//  Created by Danil Shchegol on 21.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemBackground
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.text = "Hello there!"
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .lightGray
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(historyLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            historyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            historyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            historyLabel.heightAnchor.constraint(equalToConstant: 16),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 20)
        ])
    }
    
    override func prepareForReuse() {
        historyLabel.text = nil
        self.imageView.image = nil
        activityIndicator.stopAnimating()
    }
    
    func configure(with query: PhotoQuery) {
        
        let text = NSMutableAttributedString(string: "Your query: ",
                                             attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        text.append(NSAttributedString(string: query.query ?? "",
                                       attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 15)]))
        historyLabel.attributedText = text
                
        guard let url = URL(string: query.url ?? "") else { return }
        ImageDownloader.shared.download(url: url, activityIndicator: self.activityIndicator) { [weak self] (image) in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
