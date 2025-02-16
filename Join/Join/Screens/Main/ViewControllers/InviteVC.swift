//
//  InviteVC.swift
//  Join
//
//  Created by 홍정민 on 2022/06/28.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift
import FirebaseDynamicLinks
import Moya
import SwiftyJSON
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKTalk
import KakaoSDKCommon


class InviteVC: BaseViewController {
    private let inviteProvider = MoyaProvider<InviteServices>()
    private let inviteImgURL = "https://zoin-bucket.s3.ap-northeast-2.amazonaws.com/D408D8B4-0953-49AB-AC50-65BA5FA6BBD3.png"
    private let inviteTitle = "너만 볼 수 있는 번개, 쪼인할래?"
    private let inviteDescription = "우리끼리 편한번개, 쪼인"
    
    var inviteUserId:String = ""
    
    var popupView = UIView().then{
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayScale900
        $0.layer.cornerRadius = 32
    }
    
    var titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "친구를 초대해 보세요!"
        $0.font = .minsans(size: 24, family: .Bold)
        $0.textColor = .white
    }
    
    var kakaoLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .minsans(size: 14, family: .Medium)
        $0.textColor = .white
        $0.text = "카카오톡"
    }
    
    var linkLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .minsans(size: 14, family: .Medium)
        $0.textColor = .white
        $0.text = "링크 복사"
    }
    
    var kakaoBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 20
        $0.setBackgroundImage(UIImage(named: "icon_kakao_invite"), for: .normal)
    }
    
    var linkBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 20
        $0.setBackgroundImage(UIImage(named: "icon_copy_link"), for: .normal)
    }
    
    var closeBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 20
        $0.setBackgroundImage(UIImage(named: "icon_close"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bind()
    }
    
}



extension InviteVC {
    private func setLayout() {
        self.view.backgroundColor = UIColor(red: 17/255, green: 23/255, blue: 35/255, alpha: 0.8)
        view.add(popupView)
        
        popupView.adds([
            titleLabel,
            closeBtn,
            kakaoLabel,
            linkLabel,
            kakaoBtn,
            linkBtn
        ])
        
        
        popupView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(292)
        }
        
        closeBtn.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.centerX.equalToSuperview()
        }
        
        kakaoBtn.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.width.height.equalTo(72)
            $0.leading.equalToSuperview().offset(80)
        }
        
        linkBtn.snp.makeConstraints {
            $0.width.height.equalTo(72)
            $0.centerY.equalTo(kakaoBtn.snp.centerY)
            $0.trailing.equalToSuperview().offset(-80)
        }
        
        kakaoLabel.snp.makeConstraints {
            $0.top.equalTo(kakaoBtn.snp.bottom).offset(8)
            $0.centerX.equalTo(kakaoBtn.snp.centerX)
        }
        
        linkLabel.snp.makeConstraints {
            $0.top.equalTo(linkBtn.snp.bottom).offset(8)
            $0.centerX.equalTo(linkBtn.snp.centerX)
        }
        
    }
    
    
    private func bind(){
        closeBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated:true)
            })
            .disposed(by: disposeBag)
        
        /* 초대하기 기능 */
        
        // 1) 카카오 공유
        kakaoBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                getInvitorId(type: "kakao")
            })
            .disposed(by: disposeBag)
        
        // 2) 링크 공유
        linkBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                getInvitorId(type: "link")
            })
            .disposed(by: disposeBag)
        
        // JWT 토큰으로 초대자 정보 가져오기
        func getInvitorId(type: String){
            
            inviteProvider.rx.request(.me)
                .asObservable()
                .subscribe(onNext: { [weak self] response in
                    let status = JSON(response.data)["status"]
                    if status == 200 {
                        let data = JSON(response.data)["data"]
                        let userId = data["id"].intValue
                        self?.inviteUserId = "\(userId)"
                        createDynamicLink(userId: userId, type: type)
                        
                    }
                    
                }, onError: { [weak self] _ in
                    print("error occured")
                }, onCompleted: {
                }).disposed(by: disposeBag)
        }
        
        
        func createDynamicLink(userId : Int, type: String) {
            //firebase console에서 생성한 URL prefix
            let dynamicLinksDomainURIPrefix = "https://teambunggae.page.link"
            
            //dynamic link 수신 시 얻는 값
            let link = URL(string: dynamicLinksDomainURIPrefix + "/?userId=\(userId)")!
            print("generate link : \(link)")
            
            let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
            
            // iOS 설정
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.teamBunggae.Join")
            linkBuilder?.iOSParameters?.minimumAppVersion = "1.0.0"
            linkBuilder?.iOSParameters?.appStoreID = "1642760099"
            // referralLink?.iOSParameters?.customScheme = "커스텀 스키마가 설정되어 있을 경우 추가"
            
            // 소셜미디어 미리보기 설정
            linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            
            linkBuilder?.socialMetaTagParameters?.title = inviteTitle
            linkBuilder?.socialMetaTagParameters?.descriptionText = inviteDescription
            linkBuilder?.socialMetaTagParameters?.imageURL = URL(string: inviteImgURL)
            
            // 단축 URL 생성
            linkBuilder?.shorten { (shortURL, warnings, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let sharedURL = shortURL else { return }
                print(sharedURL)
                
                if type == "kakao" {
                    // 카카오톡 공유기능 사용
                    sendKakaoMessage(sharedURL: "\(sharedURL)")
                }else if type == "link" {
                    //클립보드 저장
                    UIPasteboard.general.string = "\(sharedURL)"
                    copyPasteBoard()
                }
            }
        }
        
        // 클립보드 복사 후 토스트 메시지
        func copyPasteBoard(){
            self.showToast(message: "초대 링크가 복사되었습니다!")
        }
        
        // 카카오톡 공유하기
        func sendKakaoMessage(sharedURL: String){
            
            let link = Link(webUrl: URL(string: sharedURL),
                            mobileWebUrl: URL(string: sharedURL))
            
            let appLink = Link(androidExecutionParams: ["key1": "value1", "key2": "value2"],
                               iosExecutionParams: ["isInvited": "true", "inviteUserId": inviteUserId])
            
            let button1 = Button(title: "앱으로 보기", link: appLink)
            
            let content = Content(title: inviteTitle,
                                  imageUrl: URL(string: inviteImgURL)!,
                                  imageWidth: 264,
                                  imageHeight: 130,
                                  description: inviteDescription,
                                  link: link)
            let feedTemplate = FeedTemplate(content: content, buttons: [button1])
            
            //메시지 템플릿 encode
            if let feedTemplateJsonData = (try? SdkJSONEncoder.custom.encode(feedTemplate)) {
                
                //생성한 메시지 템플릿 객체를 jsonObject로 변환
                if let templateJsonObject = SdkUtils.toJsonObject(feedTemplateJsonData) {
                    ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(sharingResult, error) in
                        if let error = error {
                            print("\(error)")
                        }
                        else {
                            print("shareDefault(templateObject:templateJsonObject) success.")
                            
                            //do something
                            guard let sharingResult = sharingResult else { return }
                            UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                            
                            //카카오 공유가 불가능 할 경우
                            if !UserApi.isKakaoTalkLoginAvailable() {
                                let kakaoUrl = URL(string: "https://accounts.kakao.com")
                                UIApplication.shared.open(kakaoUrl!, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    private func showToast(message : String){
        let toastView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .grayScale200
        }
        
        let toastLabel = UILabel().then{
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .minsans(size: 14, family: .Bold)
            $0.text = message
            $0.textColor = .grayScale800
            
        }
        
        let toastIcon = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "icon_link")
        }
        
        toastView.adds([toastLabel, toastIcon])
        popupView.add(toastView)
        
        toastView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(56)
            $0.bottom.equalTo(popupView.snp.top).offset(-20)
        }
        
        toastIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(21)
            $0.width.equalTo(14)
            $0.height.equalTo(18)
            $0.centerY.equalToSuperview()
        }
        
        toastLabel.snp.makeConstraints {
            $0.leading.equalTo(toastIcon.snp.trailing).offset(13)
            $0.centerY.equalTo(toastIcon.snp.centerY)
        }
        
        
        UIView.animate(withDuration: 1.5, delay: 0.01, options: .curveEaseInOut, animations: {
            toastView.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
            
        })
        
    }
    
    
}

extension InviteVC {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first , touch.view == self.view {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
