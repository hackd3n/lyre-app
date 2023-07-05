//
//  PlayListTable.swift
//  lyre-app
//
//  Created by Denis Hackett on 04/07/2023.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    let albumArtImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18) // Set the font to bold
        label.lineBreakMode = .byTruncatingTail //title length
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12) // Set the font to bold
        label.lineBreakMode = .byTruncatingTail //title length
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .blue
        return button
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(albumArtImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            albumArtImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumArtImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            albumArtImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            albumArtImageView.widthAnchor.constraint(equalTo: albumArtImageView.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: albumArtImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.5),
            titleLabel.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -8),
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

