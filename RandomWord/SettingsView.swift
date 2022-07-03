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
                        Text("From:")
                        
                        TextField("Start number", value: $minNumber, format: .number )
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .minNumber)
                            .onSubmit {
                                handleChangeNumbers()
                            }
                    }
                    HStack {
                        Text("To:")
                        TextField("End number", value: $maxNumber, format: .number)
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                            .multilineTextAlignment(.trailing)
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
                    TextField("New word...", text: $newWord)
                        .focused($focusedField, equals: .newWord)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .newWord
                            saveNewWord()
                        }
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
                            focusedField = nil
                        case .newWord:
                            saveNewWord()
                            focusedField = nil
                        case .none:
                            return
                        }
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
        if let numberRange = numberRanges.first {
            numberRange.min = minNumber
            numberRange.max = maxNumber
            try? moc.save()
        } else {
            createNewNumberRange()
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
