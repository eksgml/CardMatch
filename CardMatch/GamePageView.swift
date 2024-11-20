import SwiftUI

struct GamePageView: View {
    @State private var cards: [Card] = {
        let imageNames = [
            "card1", "card2", "card3", "card4", "card5",
            "card6", "card7", "card8", "card9", "card10",
            "card11", "card12", "card13", "card14", "card15"
        ]
        let shuffledCards = imageNames.flatMap { name in
            [Card(imageName: name), Card(imageName: name)] // 이미지 2번추가
        }.shuffled()
        return shuffledCards
    }()
    @State private var flippedIndices: [Int] = [] // 뒤집힌 카드
    @State private var matchedIndices: Set<Int> = [] // 매칭된 카드
    @State private var timeLeft: Int = 180
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isGameWon: Bool = false // 게임 완려
    @State private var comboCount: Int = 0
    @State private var isPaused: Bool = false
    @State private var countdown: Int = 3

    let columns = [GridItem(.adaptive(minimum: 60))]
    var difficulty: Difficulty
    
    var body: some View {
        VStack {
            if countdown > 0 {
                Text("\(countdown)")
                    .font(.largeTitle)
                    .bold()
                    .onAppear {
                        startCountdown()
                    }
            } else if isGameWon { // 게임 승리 화면
                VStack {
                    Text("🎉 Congratulations! 🎉")
                        .font(.largeTitle)
                        .bold()
                    Text("Final Score: \(score)")
                        .font(.title)
                        .padding()

                    Button("Play Again") {
                        resetGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Exit") {
                        // 메인 화면으로 이동 (연결)
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            } else {
                VStack {
                    HStack {
                        Text("Time Left: \(timeLeft)s")
                        Spacer()
                        Text("Score: \(score)")
                    }
                    .padding()

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(cards.indices, id: \.self) { index in
                            CardView(card: cards[index], isFlipped: flippedIndices.contains(index) || matchedIndices.contains(index))
                                .onTapGesture {
                                    handleCardFlip(at: index)
                                }
                                .disabled(flippedIndices.count == 3 || matchedIndices.contains(index) || isPaused)
                        }
                    }
                    .padding()

                    HStack {
                        Button("Stop") {
                            isPaused.toggle()
                        }
                        Spacer()
                        Button("Restart") {
                            resetGame()
                        }
                        Spacer()
                        Button("Exit") {
                            // 메인 화면으로 이동 (연결하기)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    startTimer()
                }
                .alert("Game Over", isPresented: $isGameOver) {
                    Button("OK") {
                        resetGame()
                    }
                }
            }
        }
        .padding()
    }
    
    //여기서부터 게임

    func handleCardFlip(at index: Int) {
        guard !flippedIndices.contains(index), flippedIndices.count < 3 else { return }

        flippedIndices.append(index)

        if flippedIndices.count == 2 {
            checkMatch()
        } else if flippedIndices.count == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                flippedIndices.removeAll(where: { !matchedIndices.contains($0) })
            }
        }
    }

    func checkMatch() {
        guard flippedIndices.count == 2 else { return }

        let firstIndex = flippedIndices[0]
        let secondIndex = flippedIndices[1]

        if cards[firstIndex].imageName == cards[secondIndex].imageName { // 매칭 성공
            matchedIndices.insert(firstIndex)
            matchedIndices.insert(secondIndex)
            score += 1000 + comboCount * 300
            comboCount += 1
            flippedIndices.removeAll()

            // 모든 카드 매칭 확인
            if matchedIndices.count == cards.count {
                isGameWon = true
            }
        } else { // 매칭 실패
            comboCount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                flippedIndices.removeAll()
            }
        }
    }

    func startTimer() {
        let interval = difficulty.timeLimit
        timeLeft = interval
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard !isPaused else { return }
            timeLeft -= 1
            if timeLeft <= 0 {
                timer.invalidate()
                isGameOver = true
            }
        }
    }

    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
            }
        }
    }

    func resetGame() {
        cards = {
            let imageNames = [
                "card1", "card2", "card3", "card4", "card5",
                "card6", "card7", "card8", "card9", "card10",
                "card11", "card12", "card13", "card14", "card15"
            ]
            let shuffledCards = imageNames.flatMap { name in
                [Card(imageName: name), Card(imageName: name)]
            }.shuffled()
            return shuffledCards
        }()
        flippedIndices.removeAll()
        matchedIndices.removeAll()
        score = 0
        comboCount = 0
        isPaused = false
        isGameOver = false
        isGameWon = false
        countdown = 3
        startTimer()
    }
}

struct CardView: View {
    let card: Card
    let isFlipped: Bool

    var body: some View {
        ZStack {
            if isFlipped {
                Rectangle()
                    .fill(Color.white) // 카드의 배경색
                    .frame(width: 60, height: 80)
                    .shadow(radius: 4)
                Image(card.imageName) // 카드 이미지 표시
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 70) // 이미지 크기 조정
            } else {
                Rectangle()
                    .fill(Color.yellow) // 카드 뒷면
                    .frame(width: 60, height: 80)
            }
        }
        .cornerRadius(8)
    }
}

struct Card: Identifiable {
    let id: String = UUID().uuidString // 고유한 카드 ID
    let imageName: String // 카드에 표시할 이미지 이름

    init(imageName: String) {
        self.imageName = imageName
    }
}

enum Difficulty {
    case easy
    case normal
    case hard

    var timeLimit: Int {
        switch self {
        case .easy: return 180
        case .normal: return 120
        case .hard: return 60
        }
    }
}

struct GamePageView_Previews: PreviewProvider {
    static var previews: some View {
        GamePageView(difficulty: .easy)
    }
}
