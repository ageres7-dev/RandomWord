//
//  RandomeView.swift
//  RandomWord
//
//  Created by Sergey Dolgikh on 03.07.2022.
//

import SwiftUI

struct RandomeView: View {
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: nil,
        animation: .default)
    private var words: FetchedResults<Word>
    
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "name == %@", "default"))
    private var numberRanges: FetchedResults<RandomNumberRange>
    
    @State private var randomNumber = "Tap me"
    @State private var randomWord = "Tap me"
    
    var minNumber: Int64 {
        numberRanges.first?.min ?? 0
    }
    
    var maxNumber: Int64 {
        numberRanges.first?.max ?? 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button {
                        let range = minNumber < maxNumber
                        ? (minNumber...maxNumber)
                        : (maxNumber...minNumber)
                        
                        guard let randomNumber = range.randomElement() else { return }
                        self.randomNumber = String(randomNumber)
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        HStack {
                            Spacer()
                            Text(randomNumber)
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Number")
                }
                
                Section {
                    Button {
                        if words.isEmpty {
                            randomWord = "Need add words!"
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        } else if let word = words.randomElement()?.text {
                            randomWord = word
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }
                        
                    } label: {
                        HStack {
                            Spacer()
                            Text(randomWord)
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                } header: {
                    Text("Word")
                }
            }
            .navigationTitle("Randome")
        }
    }
}

struct RandomeView_Previews: PreviewProvider {
    static var previews: some View {
        RandomeView()
    }
}
