import FirebaseFirestore
import Combine

class RankingViewModel: ObservableObject {
    @Published var rankings: [Ranking] = []

    private var db = Firestore.firestore()

    func fetchRankings() {
        db.collection("TopScores")
            .order(by: "score", descending: true) // 점수 내림차순 정렬
            .limit(to: 10) // 최대 10개만 가져옴
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching rankings: \(error)")
                    return
                }

                self.rankings = snapshot?.documents.compactMap { document in
                    try? document.data(as: Ranking.self)
                } ?? []
            }
    }
}
