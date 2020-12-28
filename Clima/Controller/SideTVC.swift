//
//  SideVC.swift
//  Clima
//
//  Created by 김우성 on 2020/12/28.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

class SideTVC: UITableViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 프로필 원형으로 잡기
        profileImage.layer.cornerRadius = profileImage.frame.width / 2 //프레임을 원으로 만들기
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill //이미지 비율 바로잡기
        profileImage.clipsToBounds = true //이미지를 뷰 프레임에 맞게 clip하기
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if Variables.loginStatusIndex == 1 {
            self.profileImage.image = Variables.userProfileImage
            nameLabel.text = "\(Variables.userName!)님 좋은 하루 보내세요."
            statusLabel.text = "현재 로그인 중"
        } else {
            self.profileImage.image = nil
            nameLabel.text = "로그인이 필요합니다."
            statusLabel.text = "현재 로그아웃 중"
        }
        
        

    }
    
}
