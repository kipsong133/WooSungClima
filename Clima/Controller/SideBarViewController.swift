//
//  SideBarViewController.swift
//  Clima
//
//  Created by 김우성 on 2020/12/27.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import Foundation
import NaverThirdPartyLogin
import Alamofire

class SideBarViewController: UITableViewController {
    
    
    

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // 네이버 로그인 구현 관련 인스턴스 생성
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    
    override func awakeFromNib() {
        super.viewDidLoad()
        self.loginInstance?.delegate = self
        
    }
    
    
    
    
    @IBAction func kakaoLogin(_ sender: Any) {
        AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                _ = oauthToken
                // 어세스토큰
                let accessToken = oauthToken?.accessToken
                
                //카카오 로그인을 통해 사용자 토큰을 발급 받은 후 사용자 관리 API 호출
                self.setUserInfo()

                
            }
        }
    }
    func setUserInfo() {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController else {
            print("VC Instant error")
            return
        }
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                //do something
                _ = user
                self.nameLabel.text = user?.kakaoAccount?.profile?.nickname
                
                // 이메일 가져오는거 다시 승인요청했으니 시간 지난후 안되면, 키 재발급할 것.
                // 2020.12.27 17:42
                //print(user?.kakaoAccount?.email)
//                if let email = user?.kakaoAccount?.email {
//                    self.emailLabel.text = email
//                    print(email)
//                }

                
//                Variables.gender = user?.kakaoAccount?.gender?.rawValue 
//                
//                if Variables.gender != nil {
//                    vc.userCharacter?.image = UIImage(named: "밤")
//                    print("male")
//                } else {
//                    print("female")
//                }
                

                
                if let url = user?.kakaoAccount?.profile?.profileImageUrl,
                   let data = try? Data(contentsOf: url) {
                    self.profileImage.image = UIImage(data: data)
                }
            }
        }
    }
    
    @IBAction func naverLogin(_ sender: Any) {
        loginInstance?.requestThirdPartyLogin()
    }
    
    
    
}

extension SideBarViewController: NaverThirdPartyLoginConnectionDelegate {
    // 로그인에 성공한 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        getInfo()
    }
    
    // referesh token
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        loginInstance?.accessToken
    }
    
    // 로그아웃
    func oauth20ConnectionDidFinishDeleteToken() {
        print("log out")
    }
    
    // 모든 error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("error = \(error.localizedDescription)")
    }
    
    // RESTful API, id가져오기
    func getInfo() {
      guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
      
      if !isValidAccessToken {
        return
      }
      
      guard let tokenType = loginInstance?.tokenType else { return }
      guard let accessToken = loginInstance?.accessToken else { return }
        
      let urlStr = "https://openapi.naver.com/v1/nid/me"
      let url = URL(string: urlStr)!
      
      let authorization = "\(tokenType) \(accessToken)"
      
      let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
      
      req.responseJSON { response in
        guard let result = response.value as? [String: Any] else { return }
        guard let object = result["response"] as? [String: Any] else { return }
        guard let name = object["name"] as? String else { return }
        guard let email = object["email"] as? String else { return }
        guard let id = object["id"] as? String else {return}
        guard let profileImage = object["profile_image"] as? String else {return}
        
        //let profileImageURL = URL(string: profileImage)
        
        print(email)
        
        
        if let profileImageURL = URL(string: profileImage),
            let data = try? Data(contentsOf: profileImageURL) {
            self.profileImage.image = UIImage(data: data)
        }
    
        self.nameLabel.text = "\(name)"
        self.emailLabel.text = "\(email)"
//        self.id.text = "\(id)"
      }
    }
    
}
