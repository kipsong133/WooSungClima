//
//  GenderManager.swift
//  Clima
//
//  Created by 김우성 on 2020/12/27.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol GenderManagerDelegate {
    func didUpdateGenderImage(_ genderManger: GenderManager, gender: GenderModel)
    
}


struct GenderManager {
    
    var delegate: GenderManagerDelegate?
    
    func fetchGenderImage(gender: GenderModel) {
        self.delegate?.didUpdateGenderImage(self, gender: gender)
    }
    
    
}
