import SwiftUI
import FirebaseFirestore

struct RankingView: View {
    @State private var nickname: String = ""
    @State private var isNicknameValid: Bool = true
    @State private var rankings: [(name: String, score: Int)] = []
    @State private var isScoreRecorded: Bool = false
    @State private var isTopTen: Bool = false
    @Binding var score: Int // 이전 화면에서 전달받은 점수
    @Environment(\.presentationMode) var presentationMode

    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            if isTopTen {
                VStack {
                    Text("🎉 Top 10 Score! 🎉")
                        .font(.largeTitle)
                        .bold()
                    Text("Your Score: \(score)")
                        .font(.title)
                        .padding()

                    TextField("Enter your nickname", text: $nickname)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isNicknameValid ? Color.gray : Color.red, lineWidth: 1)
                        )
                        .onChange(of: nickname) { newValue in
                            validateNickname(newValue)
                        }

                    Button(action: saveScore) {
                        Text("Submit")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isNicknameValid || nickname.isEmpty)

                    if isScoreRecorded {
                        Text("Score Recorded!")
                            .foregroundColor(.green)
                            .bold()
                    }
                }
                .padding()
            } else {
                VStack {
                    Text("Your Score: \(score)")
                        .font(.title)
                        .padding()

                    Text("Sorry, your score did not make the Top 10.")
                        .font(.headline)
                        .foregroundColor(.red)

                    Button("Restart Game") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Go to Main Page") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }

            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
                .padding()

            List(rankings, id: \.name) { entry in
                HStack {
                    Text(entry.name)
                    Spacer()
                    Text("\(entry.score)")
                }
            }
        }
        .onAppear(perform: fetchRankings)
    }

    private func validateNickname(_ nickname: String) {
        let nicknameRegex = "^[가-힣a-zA-Z0-9]{0,10}$"
        isNicknameValid = NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
    }

    private func fetchRankings() {
        db.collection("ranking")
            .order(by: "score", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching rankings: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                rankings = documents.compactMap { doc in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let score = data["score"] as? Int else { return nil }
                    return (name: name, score: score)
                }

                isTopTen = rankings.count < 10 || rankings.last?.score ?? 0 < score
            }
    }

    private func saveScore() {
        guard isTopTen else { return }
        let newEntry = ["name": nickname, "score": score] as [String : Any]

        db.collection("ranking").addDocument(data: newEntry) { error in
            if let error = error {
                print("Error saving score: \(error)")
                return
            }
            fetchRankings()
            isScoreRecorded = true
        }
    }
}
