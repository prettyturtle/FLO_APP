//
//  LyricsViewController.swift
//  FLOApp
//
//  Created by yc on 2022/01/30.
//

import UIKit
import SnapKit
import AVFoundation

class LyricsViewController: UIViewController {
    
    private let music: Music
    private var lyricsList = [String]()
    private var timeList = [Float]()
    private var player: AVAudioPlayer?
    
    weak var playerViewController: PlayerViewController?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 30.0
        
        return tableView
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
        
        label.text = "--:--"
        label.font = .systemFont(ofSize: 12.0, weight: .light)
        
        return label
    }()
    private lazy var playButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    init(music: Music, playerViewController: PlayerViewController) {
        self.music = music
        self.playerViewController = playerViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        configMusic()
        setupLayout()
        setupView()
    }
}

extension LyricsViewController: PlayerToLyrics {
    func updateProgressSlider(time: TimeInterval) {
        progressSlider.value = Float(time)
        currentTimeLabel.text = formattingTime(time: Int(time))
        guard let player = player else { return }
        if !player.isPlaying {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func getCurrentTime(time: Float) {
        let currentIndex = timeList.lastIndex {
            time > $0
        }.map { Int($0) } ?? 0
        
        // 가사 행마다 시간에 맞춰 색상 변경
        tableView.reloadData()
        tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))?.textLabel?.textColor = .mainColor
        tableView.scrollToRow(at: IndexPath(row: currentIndex, section: 0), at: .middle, animated: true)
    }
}
extension LyricsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = lyricsList[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}

extension LyricsViewController {
    @objc func didTapLeftBarButton() {
        dismiss(animated: true)
    }
    @objc func didTapPlayButton(_ sender: UIButton) {
        guard let playerViewController = playerViewController else { return }
        playerViewController.didTapPlayButton(sender)
    }
    @objc func changedValueProgressSlider(_ sender: UISlider) {
        guard let playerViewController = playerViewController,
              let player = player else { return }
        switch playerViewController.playerStatus {
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
}

private extension LyricsViewController {
    func configMusic() {
        guard let playerViewController = playerViewController else { return }
        player = playerViewController.player
        lyricsList = music.lyrics.removeTimeLyricsString.split(separator: "\n").map { String($0) }
        timeList = music.lyrics.getTimeOfLyrics
        playerViewController.delegate = self
    }
    
    func setupView() {
        guard let playerViewController = playerViewController else { return }
        progressSlider.maximumValue = Float(music.duration)
        progressSlider.value = Float(player?.currentTime ?? 0)
        durationLabel.text = formattingTime(time: music.duration)
        currentTimeLabel.text = formattingTime(time: Int(Double(player?.currentTime ?? 0)))
        switch playerViewController.playerStatus {
        case .play:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case .pause:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func formattingTime(time: Int) -> String {
        let min = time / 60
        let sec = time % 60
        let result = String(format: "%02d:%02d", min, sec)
        return result
    }
    
    func setupNavigationItem() {
        navigationItem.title = music.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapLeftBarButton)
        )
        navigationController?.navigationBar.tintColor = .mainColor
    }
    
    func setupLayout() {
        [
            tableView,
            progressSlider,
            currentTimeLabel,
            durationLabel,
            playButton
        ].forEach { view.addSubview($0) }
        
        let commonInset = 16.0
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        progressSlider.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(commonInset * 2)
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
