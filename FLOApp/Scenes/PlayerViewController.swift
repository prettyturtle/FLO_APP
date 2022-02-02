//
//  PlayerViewController.swift
//  FLOApp
//
//  Created by yc on 2022/01/25.
//

import UIKit
import SnapKit
import Kingfisher
import AVFoundation

/// 가사 뷰 컨과 연결하는 프로토콜
protocol PlayerToLyrics: AnyObject {
    /// 재생되고 있는 음악의 현재 시간을 전달함
    func getCurrentTime(time: Float)
    func updateProgressSlider(time: TimeInterval)
}

enum PlayerStatus {
    case play
    case pause
}

class PlayerViewController: UIViewController {
    
    private var music: Music?
    var playerStatus: PlayerStatus = .pause
    var player: AVAudioPlayer?
    private var timer: Timer?
    
    weak var delegate: PlayerToLyrics?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
        label.textAlignment = .center
        
        return label
    }()
    private lazy var albumLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 14.0, weight: .thin)
        label.textColor = .secondaryLabel
        
        return label
    }()
    private lazy var singerLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16.0, weight: .regular)
        
        return label
    }()
    private lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    private lazy var lyricsLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16.0, weight: .regular)
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLyricsLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        
        slider.minimumTrackTintColor = .mainColor
        slider.addTarget(self, action: #selector(changedValueProgressSlider(_:)), for: .valueChanged)
        
        return slider
    }()
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        
        label.text = "00:00"
        label.font = .systemFont(ofSize: 12.0, weight: .light)
        
        return label
    }()
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 12.0, weight: .light)
        
        return label
    }()
    private lazy var playButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchMusicDataManager().fetchMusicData { [weak self] music in
            guard let self = self else { return }
            self.music = music
            self.configMusicPlayer()
            DispatchQueue.main.async {
                self.setupLayout()
                self.setupView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch playerStatus {
        case .play:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case .pause:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
}

// MARK: - @objc func
extension PlayerViewController {
    @objc func didTapPlayButton(_ sender: UIButton) {
        guard let player = player else { return }
        
        switch playerStatus {
        case .play:
            player.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playerStatus = .pause
        case .pause:
            player.play()
            startProgressSlider()
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playerStatus = .play
        }
    }
    @objc func changedValueProgressSlider(_ sender: UISlider) {
        guard let player = player else { return }
        switch playerStatus {
        case .play:
            player.pause()
            player.currentTime = TimeInterval(sender.value)
            currentTimeLabel.text = formattingTime(time: Int(player.currentTime))
            player.play()
        case .pause:
            player.currentTime = TimeInterval(sender.value)
            currentTimeLabel.text = formattingTime(time: Int(player.currentTime))
        }
    }
    @objc func setProgress() {
        guard let player = player else { return }
        progressSlider.value = Float(player.currentTime)
        currentTimeLabel.text = formattingTime(time: Int(player.currentTime))
        delegate?.getCurrentTime(time: Float(player.currentTime))
        delegate?.updateProgressSlider(time: player.currentTime)
        
        if !player.isPlaying {
            playerStatus = .pause
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            timer?.invalidate()
        }
    }
    @objc func didTapLyricsLabel() {
        guard let music = music else { return }
        let lyricsViewController = LyricsViewController(music: music, playerViewController: self)
        let lyricsNavigationController = UINavigationController(rootViewController: lyricsViewController)
        lyricsNavigationController.modalPresentationStyle = .fullScreen
        present(lyricsNavigationController, animated: true)
    }
}

private extension PlayerViewController {
    func formattingTime(time: Int) -> String {
        let min = time / 60
        let sec = time % 60
        let result = String(format: "%02d:%02d", min, sec)
        return result
    }
    func startProgressSlider() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
    }
    func configMusicPlayer() {
        guard let music = music,
              let musicFile = music.musicFile else { return }
        do {
            let data = try Data(contentsOf: musicFile)
            player = try AVAudioPlayer(data: data)
        } catch {
            print("ERROR - PlayerViewController - configMusicPlayer - \(error.localizedDescription)")
        }
    }
    func setupView() {
        guard let music = music else { return }
        titleLabel.text = music.title
        albumLabel.text = music.album
        singerLabel.text = music.singer
        albumImageView.kf.setImage(with: music.imageURL)
        lyricsLabel.text = music.lyrics.removeTimeLyricsString
        progressSlider.value = 0.0
        progressSlider.maximumValue = Float(music.duration)
        durationLabel.text = formattingTime(time: music.duration)
    }
    func setupLayout() {
        [
            titleLabel,
            albumLabel,
            singerLabel,
            albumImageView,
            lyricsLabel,
            progressSlider,
            currentTimeLabel,
            durationLabel,
            playButton
        ].forEach { view.addSubview($0) }
        
        let commonInset = 16.0
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(commonInset)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(commonInset * 2)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        albumLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(commonInset / 2.0)
        }
        singerLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(albumLabel.snp.bottom).offset(commonInset / 2.0)
        }
        albumImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(commonInset * 2)
            $0.top.equalTo(singerLabel.snp.bottom).offset(commonInset)
            $0.trailing.equalToSuperview().inset(commonInset * 2)
            $0.height.greaterThanOrEqualTo(250.0)
        }
        lyricsLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(commonInset * 2)
            $0.top.greaterThanOrEqualTo(albumImageView.snp.bottom).offset(commonInset * 2)
            $0.trailing.equalToSuperview().inset(commonInset * 2)
        }
        progressSlider.snp.makeConstraints {
            $0.top.equalTo(lyricsLabel.snp.bottom).offset(commonInset * 2)
            $0.leading.equalToSuperview().inset(commonInset)
            $0.trailing.equalToSuperview().inset(commonInset)
        }
        currentTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(progressSlider.snp.leading)
            $0.top.equalTo(progressSlider.snp.bottom).offset(commonInset / 4.0)
        }
        durationLabel.snp.makeConstraints {
            $0.trailing.equalTo(progressSlider.snp.trailing)
            $0.top.equalTo(progressSlider.snp.bottom).offset(commonInset / 4.0)
        }
        playButton.snp.makeConstraints {
            $0.top.equalTo(progressSlider.snp.bottom).offset(commonInset)
            $0.width.height.equalTo(50.0)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(commonInset)
        }
    }
}
