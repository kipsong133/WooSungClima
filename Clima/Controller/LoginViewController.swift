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
    // 카카오/네이버 Outlet Variables
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundView2: UIView!
    let separatorView = UIView()


    
    // 네이버 로그인 구현 관련 인스턴스 생성
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    @IBAction func login(_ sender: Any) {
        Variables.loginStatusIndex = 1
        loginInstance?.requestThirdPartyLogin()
    }
    
    @IBAction func logout(_ sender: Any) {
        Variables.loginStatusIndex = 0
        self.infoLabel.text = ""
        loginInstance?.requestDeleteToken()
        self.profileImageView.image = UIImage(named: "default.png")
        Variables.userName = ""
        Variables.userGender = ""
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadow()
        // 기본값을 넣었는데 왜안되는지?? 의문,,,
        self.profileImageView.image = UIImage(named: "default.png")
        
        self.loginInstance?.delegate = self
        
        self.infoLabel.text = Variables.userName
        self.profileImageView.image = Variables.userProfileImage
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if Variables.loginStatusIndex == 0 {
            self.profileImageView.image = UIImage(named: "default.png")
        }
    }
    
 
    
    
    
    
    func addShadow() {
        // 프로필 원형으로 잡기
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2 //프레임을 원으로 만들기
        profileImageView.contentMode = UIView.ContentMode.scaleAspectFill //이미지 비율 바로잡기
        profileImageView.clipsToBounds = true //이미지를 뷰 프레임에 맞게 clip하기
        
        // 배경 그림자효과
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        backgroundView.layer.shadowRadius = 3
        backgroundView.layer.shadowOpacity = 0.8
        
        backgroundView2.layer.shadowColor = UIColor.black.cgColor
        backgroundView2.layer.shadowOffset = CGSize(width: 1, height: 1)
        backgroundView2.layer.shadowRadius = 3
        backgroundView2.layer.shadowOpacity = 0.8
    }
    
}






//MARK: - Kakao login logic
extension LoginViewController {
    
    //앱으로 로그인
    @IBAction func onKakaoLoginByAppTouched(_ sender: Any) {
        Variables.loginStatusIndex = 1
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
        Variables.loginStatusIndex = 1
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
                Variables.userName = user?.kakaoAccount?.profile?.nickname
                
                Variables.userGender = (user?.kakaoAccount?.gender?.rawValue) 
                
                if let url = user?.kakaoAccount?.profile?.profileImageUrl,
                    let data = try? Data(contentsOf: url) {
                    self.profileImageView.image = UIImage(data: data)
                    Variables.userProfileImage = UIImage(data: data)
                }
            }
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
        self.profileImageView.image = UIImage(named: "default.png")
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
        guard let gender = object["gender"] as? String else {return}
        
        Variables.userGender = gender
        
        //let profileImageURL = URL(string: profileImage)
        
        print(email)
        
        
        if let profileImageURL = URL(string: profileImage),
            let data = try? Data(contentsOf: profileImageURL) {
            self.profileImageView.image = UIImage(data: data)
            Variables.userProfileImage = UIImage(data: data)
        }
        Variables.userName = "\(name)"
        self.infoLabel.text = "\(name)"
        //self.emailLabel.text = "\(email)"
        //self.id.text = "\(id)"
      }
    }
    
}
