//
//  NewSymptomViewModel.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/13/26.
//

import Foundation
import Combine

class NewSymptomViewModel: ObservableObject{
    @Published var title = ""
    @Published var severityString = ""
    @Published var severity = 0
    
    init() {
    }
    
    func save() {
        
    }
}
