struct RankingsView: View {
    @State private var rankings: [[String: Any]] = []
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Text("Top 10 Rankings")
                .font(.title)
                .padding()
            
            List(rankings, id: \.self) { ranking in
                HStack {
                    Text(ranking["name"] as? String ?? "Unknown")
                    Spacer()
                    Text("\(ranking["score"] as? Int ?? 0)")
                }
            }
        }
        .onAppear(perform: fetchRankings)
    }
    
    func fetchRankings() {
        db.collection("rankings")
            .order(by: "score", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching rankings: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                rankings = documents.map { $0.data() }
            }
    }
}
