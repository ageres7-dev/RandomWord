//
//  SettingsView.swift
//  RandomWord
//
//  Created by Sergey Dolgikh on 03.07.2022.
//

import SwiftUI

struct SettingsView: View {
    enum FocusedField {
            case newWord, minNumber, maxNumber
        }
    
    @Environment(\.managedObjectContext) var moc
    @FocusState private var focusedField: FocusedField?
    
    @State private var newWord = ""
    
    @State private var minNumber: Int64 = 0
    @State private var maxNumber: Int64 = 100
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "name == %@", "default"))
    private var numberRanges: FetchedResults<RandomNumberRange>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: false)],
        predicate: nil,
        animation: .default)
    private var words: FetchedResults<Word>
    
    var body: some View {

        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Min:")
                        
                        TextField("Min", value: $minNumber, format: .number )
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .minNumber)
                            .onSubmit {
                                handleChangeNumbers()
                            }
                    }
                    HStack {
                        Text("Max:")
                        TextField("Max", value: $maxNumber, format: .number)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maxNumber)
                            .onSubmit {
                                handleChangeNumbers()
                            }
                    }
                }  header: {
                    Text("Random number range")
                }
                
                Section {
//                    HStack {
                        TextField("New word...", text: $newWord)
                            .focused($focusedField, equals: .newWord)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .newWord
                                saveNewWord()
                            }
//                        if newWord.count > 0 {
//                            Button(action: saveNewWord) {
//                                Image(systemName: "plus.circle.fill")
//                                    .foregroundColor(.green)
//                                    .imageScale(.large)
//                            }
//                        }
//                    }.animation(.default, value: newWord)
                } header: {
                    Text("Add new word")
                }
                if !words.isEmpty {
                    Section {
                        ForEach(words, id: \.id) { word in
                            Text(word.text ?? "")
                        }
                        .onDelete(perform: deleteWords)
                    } header: {
                        Text("All word")
                    }
                }
                
            }
            .onAppear {
                setNumbersFromDatastore()
            }
            .navigationTitle("Settings")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !words.isEmpty {
                        EditButton()
                    }
                }
            
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        switch focusedField {
                        case .maxNumber, .minNumber:
                            handleChangeNumbers()
                        case .newWord:
                            saveNewWord()
                        case .none:
                            return
                        }
                        focusedField = nil
                    }
                }
            }
        }
    }
}

extension SettingsView {

    private func saveNewWord() {
        withAnimation {
            guard !newWord.isEmpty else { return }
            
            let newWordItem = Word(context: moc)
            newWordItem.id = UUID()
            newWordItem.text = newWord
            newWordItem.timestamp = Date()
            
            do {
                try moc.save()
            } catch {
                print("Failed save managed object context. Error: \(error.localizedDescription)")
            }
            
            print(newWord)
            newWord = ""
        }
    }
    
    private func deleteWords(offsets: IndexSet) {
        withAnimation {
            offsets.map { words[$0] }.forEach(moc.delete)
            
            do {
                try moc.save()
            } catch {
                print("Failed save managed object context. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleChangeNumbers() {
        withAnimation {
            if minNumber > maxNumber {
                let maxNumberTemp = maxNumber
                maxNumber = minNumber
                minNumber = maxNumberTemp
            }
            
            if let numberRange = numberRanges.first {
                numberRange.min = minNumber
                numberRange.max = maxNumber
                try? moc.save()
            } else {
                createNewNumberRange()
            }
        }
    }
    
    private func createNewNumberRange() {
        let numberRange = RandomNumberRange(context: moc)
        numberRange.name = "default"
        numberRange.min = minNumber
        numberRange.max = maxNumber
        
        try? moc.save()
    }
    
    private func setNumbersFromDatastore() {
        if let numberRange = numberRanges.first {
            minNumber = numberRange.min
            maxNumber = numberRange.max
        } else {
            createNewNumberRange()
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
