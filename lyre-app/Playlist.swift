//
//  ViewController.swift
//  lyre-app
//
//  Created by Denis Hackett on 04/07/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.text = "Lyre - Playlist"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = .white
        detailLabel.text = "Customise your favourite music on the go using the Stem Control Center."
        detailLabel.numberOfLines = 0 // Set number of lines to 0 for unlimited lines (wrapping)
        detailLabel.textAlignment = .center
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            
            detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])

        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let tracks: [Track] = [
        // Populate with your actual tracks data
//        Track(albumArt: UIImage(named: "LYRE.png")!, title: "Sample Track Name", artist: "John Doe", trackURLs: TrackList.refract()),
//        Track(albumArt: UIImage(named: "LYRE.png")!, title: "Sample Track Name", artist: "John Doe", trackURLs: TrackList.letsGroove()),
        Track(albumArt: UIImage(named: "ubiquitos-cover.jpg")!, title: "Ubiquitous", artist: "Albert Kader", trackURLs: TrackList.Ubitquitous())
//        Track(albumArt: UIImage(named: "LYRE.png")!, title: "Sample Track Name", artist: "John Doe", trackURLs: TrackList.whiptails()),
//        Track(albumArt: UIImage(named: "LYRE.png")!, title: "ABCDEFU", artist: "John Doe", trackURLs: TrackList.ABCDEFU())
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: "PlaylistCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // To hide empty cells
        

        viewSetup()
    }
    
    func viewSetup() {
        
        view.addSubview(headerView)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistTableViewCell
        
        let track = tracks[indexPath.row]
        
        cell.albumArtImageView.image = track.albumArt
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //present the music player
        let position = indexPath.row
        //songs

        let player = PlayerView(song: tracks[position])
        
        //passing data to playerViewcontroller class
//        vc.position = position
//        navigationController?.pushViewController(player, animated: true)
        self.present(player, animated: true, completion: nil)
        print("Song: \(tracks[position].title) chosen")
        
    }
}


