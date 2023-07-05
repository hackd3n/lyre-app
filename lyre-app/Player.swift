//
//  Player.swift
//  lyre-app
//
//  Created by Denis Hackett on 04/07/2023.
//

import AVFoundation
import UIKit

class PlayerView : UIViewController {
    
    var song: Track
    var trackPlayer: TrackPlayer
    var displayLink: CADisplayLink?

    var isScrubbing: Bool = false
    
    init(song: Track) {
        self.song = song
        self.trackPlayer = TrackPlayer(tracks: self.song.trackURLs)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        trackPlayer.stopPlayback()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var audioEngine: AVAudioEngine?
    
    //init playerview

    var artworkView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 8
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    // Outer view for shadow and corner radius
    let artworkContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 120, height: 12)
        view.layer.shadowColor = UIColor.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var songTitle: UILabel = {
        let label = UILabel()
        label.text = "Track Unknown"
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.textAlignment = .center
        label.numberOfLines = 0 //line wrap
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var artistName: UILabel = {
        let label = UILabel()
        label.text = "Unknown Artist"
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let controlsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.borderWidth = 1
        return view
    }()
    
    let scrubber: UISlider = {
        let slider = UISlider()
        slider.value = 0.0
        slider.maximumValue = 1.0
        slider.minimumTrackTintColor = .red
        slider.layer.cornerRadius = 10
        slider.setThumbImage(UIImage(), for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(scrubbingBegan), for: .touchDown)
        slider.addTarget(self, action: #selector(scrubberPosition), for: .valueChanged)
        return slider
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let playButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        btn.tintColor = .lightGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)

        return btn
    }()
    
    let toggleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("STEMS", for: .normal)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(toggleButtonPressed), for: .touchUpInside)
        return btn
    }()

    // view to show stem buttons
    let stemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stemButtons: [UIButton] = {
        var buttons = [UIButton]()
        
        let groupCount = 3 // 3 tracks in a TrackList group
        let groups = song.trackURLs.count
        
        let totalNumTracks = groupCount * groups
        
        for index in 0 ..< totalNumTracks {
            let btn = UIButton()
            btn.backgroundColor = .red
            btn.layer.borderColor = UIColor.black.cgColor // Set the border color to CGColor
            btn.layer.cornerRadius = 16
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.tag = index
            btn.addTarget(self, action: #selector(stemButtonPressed(sender:)), for: .touchUpInside)
            buttons.append(btn)
        }
        
        return buttons
    }()
    
    let volume: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.maximumValue = 1.0
        slider.minimumValue = 0.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        setupView()
        
        // Enable safe area insets
        edgesForExtendedLayout = .all
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        trackPlayer.startPlayback()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateScrubber))
        self.displayLink?.add(to: .current, forMode: .common)
        
        let songDetails = song
        artworkView.image = songDetails.albumArt
        songTitle.text = songDetails.title
        artistName.text = songDetails.artist
        

        // Add artworkView as a subview of artworkContainerView
        artworkContainerView.addSubview(artworkView)

        // Add artworkContainerView to the view hierarchy
        view.addSubview(artworkContainerView)
        view.addSubview(songTitle)
        view.addSubview(artistName)
        
        view.addSubview(toggleButton)
        
        view.addSubview(controlsView)
        controlsView.addSubview(scrubber)
        controlsView.addSubview(timeLabel)
        controlsView.addSubview(playButton)
        controlsView.addSubview(volume)
        
        view.addSubview(stemView)
        
        stemView.isHidden = true
        
        view.backgroundColor = .white

        
        
        // Create a stack view to manage the layout of the stem buttons
        let stackView = UIStackView(arrangedSubviews: stemButtons)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Calculate the number of buttons per row based on the track count
        let buttonsPerRow = song.trackURLs.count
        let numberOfRows = Int(ceil(Double(stemButtons.count) / Double(buttonsPerRow)))
        
        // Loop through the buttons and add them to the stack view row by row
        for row in 0..<numberOfRows {
            let startIndex = row * buttonsPerRow
            let endIndex = min(startIndex + buttonsPerRow, stemButtons.count)
            
            let rowButtons = Array(stemButtons[startIndex..<endIndex])
            let rowStackView = UIStackView(arrangedSubviews: rowButtons)
            rowStackView.axis = .horizontal
            rowStackView.spacing = 16
            rowStackView.alignment = .center
            rowStackView.distribution = .fillEqually
            stackView.addArrangedSubview(rowStackView)
        }
            
        
        stemView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            artworkContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.1),
//            artworkContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.2),
            artworkContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.width * 0.1),
            artworkContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.1),
            artworkContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            artworkContainerView.widthAnchor.constraint(equalTo: artworkContainerView.heightAnchor),
            
            artworkView.leadingAnchor.constraint(equalTo: artworkContainerView.leadingAnchor),
            artworkView.topAnchor.constraint(equalTo: artworkContainerView.topAnchor),
            artworkView.trailingAnchor.constraint(equalTo: artworkContainerView.trailingAnchor),
            artworkView.bottomAnchor.constraint(equalTo: artworkContainerView.bottomAnchor),

            songTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            songTitle.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 16),
            songTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            artistName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            artistName.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: 8),
            artistName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            toggleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 128),
            toggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -128),
//            toggleButtonTopConstraint,
            toggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),

            controlsView.topAnchor.constraint(equalTo: artistName.bottomAnchor, constant: 8),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: toggleButton.topAnchor, constant: -8),
//            controlsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),

            playButton.centerXAnchor.constraint(equalTo: controlsView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            scrubber.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor, constant: 32),
            scrubber.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: 18),
          //  scrubber.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -8),
            
            scrubber.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: -32),

            timeLabel.leadingAnchor.constraint(equalTo: scrubber.trailingAnchor, constant: -42),
            timeLabel.topAnchor.constraint(equalTo: scrubber.bottomAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: scrubber.trailingAnchor),
            
            volume.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor, constant: 32),
//            volume.topAnchor.constraint(greaterThanOrEqualTo: playButton.bottomAnchor, constant: 8),
            volume.bottomAnchor.constraint(greaterThanOrEqualTo: controlsView.bottomAnchor, constant: -18),
            volume.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: -32),
            //stem view
            
            stemView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stemView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stemView.topAnchor.constraint(equalTo: artistName.bottomAnchor, constant: 8),
            stemView.bottomAnchor.constraint(equalTo: volume.topAnchor, constant: -8),
            
            stackView.leadingAnchor.constraint(equalTo: stemView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stemView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: stemView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: stemView.bottomAnchor, constant: -16)


        ])
        startMetering()
            
            print("Controls View Height: \(controlsView.bounds.height)")

    }
    
    @objc func playButtonPressed() {
        
        //display
        let isPlaying = trackPlayer.isPlaying
        
        if isPlaying {
            displayLink?.isPaused = false
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            displayLink?.isPaused = true
            playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        //audio engine
        trackPlayer.playOrPause()
    }
    
    @objc func scrubbingBegan(){
        isScrubbing = true
        
        displayLink?.isPaused = true
    }
    
    @objc func scrubberPosition(){

        let newPosition = scrubber.value
        isScrubbing = false
        if(!isScrubbing){
            trackPlayer.setPlaybackPosition(newPosition)
        }
        
        
        
        displayLink?.isPaused = false 
    }
    
    @objc func updateScrubber() {
        let progress = trackPlayer.getPlaybackProgress()
        // Update your scrubber using the progress value
        scrubber.value = Float(progress)
        
        print("Time Value: \(progress)")
        
        let totalDuration: Float = 100.0 // Set the total duration based on your needs
           let currentTime = progress * totalDuration
           
           // Format the time as MM:SS
           let minutes = Int(currentTime) / 60
           let seconds = Int(currentTime) % 60
           let timeString = String(format: "%02d:%02d", minutes, seconds)
           
           // Update the timeLabel with the formatted time
           timeLabel.text = timeString
        
        print(timeString)
    }
    
    @objc func toggleButtonPressed() {
        controlsView.isHidden.toggle()
        stemView.isHidden.toggle()
        if !controlsView.isHidden {
            toggleButton.backgroundColor = .clear
            toggleButton.setTitleColor(.gray, for: .normal)
            
            // Activate constraints for larger artworkView
//            artworkView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
            
        } else {
            toggleButton.backgroundColor = .gray
            toggleButton.setTitleColor(.white, for: .normal)
            
            // Deactivate constraints for larger artworkView
//            artworkView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

        }
    }
    
    @objc func stemButtonPressed(sender: UIButton){
        
        let trackNum = sender.tag
        trackPlayer.toggleMute(index: trackNum)
    }
    


    func startMetering() {
        for (index, button) in stemButtons.enumerated() {
            trackPlayer.connectTap(index: index) { meterLevel in
                DispatchQueue.main.async {
                    // Convert meterLevel to CGFloat
                    let normalizedLevel = CGFloat(meterLevel)
                    // Update the button color based on the meterLevel value
                    button.backgroundColor = UIColor(red: normalizedLevel, green: 0.0, blue: 0.0, alpha: 1.0)
                }
            }
        }
    }





}
