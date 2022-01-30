//
//  LyricsViewController.swift
//  FLOApp
//
//  Created by yc on 2022/01/30.
//

import UIKit
import SnapKit

class LyricsViewController: UIViewController {
    
    var lyrics: String?
    var lyricsList = [String]()
    var timeList = [Float]()
    var index = 0
    
    weak var playerViewController: PlayerViewController?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 30.0
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapLeftBarButton)
        )
        navigationController?.navigationBar.tintColor = .mainColor
        
        if let lyrics = lyrics,
           let playerViewController = playerViewController {
            lyricsList = lyrics.removeTimeLyricsString.split(separator: "\n").map { String($0) }
            timeList = lyrics.getTimeOfLyrics
            playerViewController.delegate = self
        }
        setupLayout()
    }
}

extension LyricsViewController: CurrentTime {
    func getCurrentTime(time: Float) {
        let currentIndex = timeList.lastIndex {
            time > $0
        }.map { Int($0) } ?? 0
        
        // 가사 행마다 시간에 맞춰 색상 변경
        if currentIndex >= 1 {
            tableView.cellForRow(at: IndexPath(row: currentIndex - 1, section: 0))?.textLabel?.textColor = .label
        }
        tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))?.textLabel?.textColor = .mainColor
        
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
}

private extension LyricsViewController {
    func setupLayout() {
        [
            tableView
        ].forEach { view.addSubview($0) }
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
