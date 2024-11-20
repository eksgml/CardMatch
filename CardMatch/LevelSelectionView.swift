//
//  levelSelectionView.swift
//  CardMach
//
//  Created by 김단희 on 11/6/24.
//

import SwiftUI

struct LevelSelectionView: View {
    var body: some View {
        ZStack{
            Image("images/background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select Level")
                    .font(.largeTitle)
                    .padding(50)
                
                // 난이도 선택
                Button("EASY") {
                    // 쉬움 버튼 클릭 시 수행할 작업
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding()
                
                Button("NORMAL") {
                    // 보통 버튼 클릭 시 수행할 작업
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding()
                
                Button("HARD") {
                    // 어려움 버튼 클릭 시 수행할 작업
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding()
            }
            .offset(y: -50)
        }
    }
}
