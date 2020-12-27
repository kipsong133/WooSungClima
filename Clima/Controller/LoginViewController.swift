//
//  LoginViewController.swift
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
import WebKit

class LoginViewController: UIViewController {
    // 카카오 Outlet Variables
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    
    // 네이버 Outlet Variables
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var naverProfileImageView: UIImageView!
    
    // 네이버 로그인 구현 관련 인스턴스 생성
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    @IBAction func login(_ sender: Any) {
        
        loginInstance?.requestThirdPartyLogin()
    }
    
    @IBAction func logout(_ sender: Any) {
        loginInstance?.requestDeleteToken()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginInstance?.delegate = self

    }
    
    
    
 
}

//MARK: - Kakao login logic
extension LoginViewController {
    
    //앱으로 로그인
    @IBAction func onKakaoLoginByAppTouched(_ sender: Any) {
        // 카카오톡 설치 여부 확인
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    // 예외 처리 (로그인 취소 등)
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    // do something
                    _ = oauthToken
                    // 어세스토큰
                    let accessToken = oauthToken?.accessToken
                    
                    //카카오 로그인을 통해 사용자 토큰을 발급 받은 후 사용자 관리 API 호출
                    self.setUserInfo()
                }
            }
        }
        
    }
    
    
    //폰(시뮬레이터)에 앱이 안깔려 있을때 웹 브라우저를 통해 로그인
    @IBAction func onKakaoLoginByWebTouched(_ sender: Any) {
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
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                //do something
                _ = user
                self.infoLabel.text = user?.kakaoAccount?.profile?.nickname
                
                let gender = (user?.kakaoAccount?.gender)!.rawValue
                self.genderLabel.text? = gender
                self.changeCharacter(gender)
                
                if let url = user?.kakaoAccount?.profile?.profileImageUrl,
                    let data = try? Data(contentsOf: url) {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    
    func changeCharacter(_ gender: String) {
        let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "") as? WeatherViewController
        if gender == "female" {
            print("female")
            // add profileImage to sideBarImage
            // add female CharacterImage to WeatherMainView
            
            
        } else {
            print("male")
            // add profileImage to sideBarImage
            // add male CharacterImage to WeatherMainView
    
        }
    }
    
}


//MARK: - Naver login logic
extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {

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
            self.naverProfileImageView.image = UIImage(data: data)
        }
    
        self.nameLabel.text = "\(name)"
        self.emailLabel.text = "\(email)"
        self.id.text = "\(id)"
      }
    }
    
}
