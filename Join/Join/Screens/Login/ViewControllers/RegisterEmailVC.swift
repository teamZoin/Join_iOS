//
//  RegsiterEmailVC.swift
//  Join
//
//  Created by 이윤진 on 2022/04/25.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift
import RxKeyboard
import SwiftUI

class RegisterEmailVC: BaseViewController {

    private let titleFirstLabel = UILabel().then {
        $0.text = "로그인할 때 필요한"
        $0.textColor = .grayScale100
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }

    private let titleSecondLabel = UILabel().then {
        $0.text = "이메일을 입력해 주세요. ✉️"
        $0.textColor = .grayScale100
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }

    private let guideLabel = UILabel().then {
        $0.text = "이메일"
        $0.textColor = .grayScale100
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    private let emailTextField = UITextField().then {
        $0.placeholder = "bungae@buangae.com"
        $0.setPlaceHolderColor(.grayScale600)
        $0.tintColor = .yellow200
        $0.textColor = .yellow200
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .grayScale800
        $0.borderStyle = .roundedRect
        $0.addLeftPadding()
    }

    private let statusLabel = UILabel().then {
        $0.text = "사용가능한 이메일입니다."
        $0.textColor = .blue100
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        // 사용불가 이메일 -> red100, "사용할 수 없는 이메일입니다"
    }

    private let guideButton = UIButton().then {
        $0.backgroundColor = .yellow200
        $0.setTitleColor(.grayScale900, for: .normal)
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        // 사용가능한 이메일일때
        // isEnabled, isSelected 설정해놓기
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bind()
        emailTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(isHidden: false)
        setUpNavigation()
    }
}

extension RegisterEmailVC {
    private func setLayout() {
        view.backgroundColor = .grayScale900
        view.isOpaque = true
        view.adds([
            titleFirstLabel,
            titleSecondLabel,
            guideLabel,
            emailTextField,
            statusLabel,
            guideButton
        ])
        titleFirstLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(250)
            make.top.equalToSuperview().offset(8)
        }
        titleSecondLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleFirstLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleFirstLabel.snp.leading)
        }
        guideLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleSecondLabel.snp.leading)
            make.top.equalTo(titleSecondLabel.snp.bottom).offset(25)
            make.width.equalTo(50)
        }
        emailTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(guideLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(guideLabel.snp.bottom).offset(9)
            make.width.equalTo(327)
            make.height.equalTo(56)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(41)
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.width.equalTo(200)
        }
        guideButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(-30)
            // make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
            // 15버전부터만 사용가능한거 실화니..
            make.width.equalTo(327)
            make.height.equalTo(56)
        }
    }

    private func setUpNavigation() {
        title = "회원가입"
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationBar.isHidden = false
        navigationBar.isTranslucent = false
    }

    private func bind() {
        guideButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let viewController = VerifyEmailVC()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight.drive(onNext: {[weak self] keyboardHeight in
            guard let self = self else { return }
            UIView.animate(withDuration: 0) {
                if keyboardHeight == 0 {
                    self.guideButton.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().offset(-30)
                    }
                } else {
                    let totalHeight = keyboardHeight - self.view.safeAreaInsets.bottom
                    self.guideButton.snp.updateConstraints { (make) in
                        make.bottom.equalToSuperview().offset(-totalHeight+(-30))
                    }
                }
                self.view.layoutIfNeeded()
            }
        })
            .disposed(by: disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension RegisterEmailVC: UITextFieldDelegate {

}
