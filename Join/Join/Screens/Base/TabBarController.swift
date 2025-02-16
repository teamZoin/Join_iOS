//
//  TabBarController.swift
//  Join
//
//  Created by 이윤진 on 2022/04/20.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var isLinkAccess:Bool?
    var inviteUserId:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
      
        setTabBar()
        // 임시로 만들어놓은 탭바 컨트롤러
        // 보통 탭바 커스텀시에 코드를 많이 사용하길래
        // 스토리보드 대신 코드로 연결을 해놓았습니다.
        let scene = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
        
        if scene.isInvited {
            self.selectedIndex = 2
        }

    }
    
    @objc func getInviteUserId(notification: Notification) {
           // notification.userInfo 값을 받아온다.
        if let item = notification.object as? String{
            print("\(item)")
        }
       }
    
    
}

extension TabBarController {
    
    @objc func menuButtionAction(sender: UIButton){
        self.selectedIndex = 1
    }
    
    private func setTabBar() {
        let tabBar = { () -> TabBarVC in
            let tabBar = TabBarVC()
            tabBar.delegate = self
            return tabBar
        }()
        self.setValue(tabBar, forKey: "tabBar")
        
        
        let middleButton = UIButton(frame: CGRect(x: self.view.bounds.width/2-25, y: -20, width: 62, height: 62)).then{
            $0.layer.cornerRadius = 20
            $0.setBackgroundImage(UIImage(named: "icon_center_btn"), for: .normal)
            $0.addTarget(self, action: #selector(menuButtionAction), for: .touchUpInside)
        }
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        lineView.backgroundColor = UIColor.grayScale800
        self.tabBar.addSubview(lineView)
        
        self.tabBar.addSubview(middleButton)
        self.view.layoutIfNeeded()
        
        let mainView = MainVC()
        let mainViewTabItem = UITabBarItem(
            title: "",
            image: UIImage(named: "home"),
            selectedImage:  UIImage(named: "home_selected")?.withRenderingMode(.alwaysOriginal)
        )
        mainView.tabBarItem = mainViewTabItem
        let mainViewController = UINavigationController(rootViewController: mainView)
        
        let makeView = MakeVC()
        let makeViewTabItem = UITabBarItem()
        makeView.tabBarItem = makeViewTabItem
        let makeViewcontroller = UINavigationController(rootViewController: makeView)
        
        
        let profileView = ProfileVC()
        let profileViewTabItem = UITabBarItem(
            title: "",
            image: UIImage(named: "mypage"),
            selectedImage: UIImage(named: "mypage_selected")?.withRenderingMode(.alwaysOriginal)
        )
        profileView.tabBarItem = profileViewTabItem
        let profileViewController = UINavigationController(rootViewController: profileView)
        
        viewControllers = [mainViewController, makeViewcontroller, profileViewController]
        
       
    }
}
