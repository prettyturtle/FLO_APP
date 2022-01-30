# FLO 앱
## (프로그래머스 과제 중)

### 결과
![](/FLOAPPImage.gif)

### 외부 라이브러리
- SnapKit
- Kingfisher

### 내장 라이브러리
- AVFoundation

### 기능 구현
1. `LaunchScreen`으로 스플래시 스크린 구현
2. [https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json](https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json) 에서 음악 정보를 JSON 형식으로 받아오기
3. `PlayViewController`에서 음악의 제목, 앨범명, 가수명, 앨범이미지, 가사, 재생바, 재생/정지 버튼 구현
    - `AVAudioPlayer`로 받아온 음악을 컨트롤할 수 있다 
    - `Timer` 객체를 생성하여 0.1 초마다 음악의 현재 재생시간을 체크하여 현재 재생 시간 라벨 또는 재생바의 위치 등을 설정함
4. `PlayViewController`에서 가사를 탭하면 `LyricsViewController`를 `present`
    - `present` 했을 때, 음악이 재생 중이라면
    - `delegate`로 음악의 현재 재생 시간을 전달한다
5. `LyricsViewController`에서 현재 재생 시간을 확인하여 가사 한 줄씩 색상을 변경한다

### 앞으로 구현해야할 것
- `PlayViewController`에서 음악의 현재 재생 시간에 맞춰 가사 색상 변경
- `LyricsViewController`에서도 슬라이더, 재생\정지 버튼을 만들어 음악을 컨트롤할 수 있게 만들기
- `LyricsViewController`에서 가사 한줄을 탭했을 때, 그 가사로 음악이 넘어가는 기능

### 반성
- 너무 코드를 막 짠 느낌이 든다
- viewDidLoad에 막 써놓은 것들을 기능별로 함수를 만들어 정리를 해야겠다
- `AVFoundation`, `Timer`를 다뤄본 적이 없어서 초반에 많이 힘들었다
- 좀 더 다양한 라이브러리, 기능들을 구현하도록 노력해야겠다
