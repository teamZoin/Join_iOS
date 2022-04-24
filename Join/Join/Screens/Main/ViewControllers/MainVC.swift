//
//  MainVC.swift
//  Join
//
//  Created by 이윤진 on 2022/04/20.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

class MainVC: BaseViewController {
    var collectionView: UICollectionView = {
          
          let layout = UICollectionViewFlowLayout()
          layout.minimumLineSpacing = 0
          layout.scrollDirection = .horizontal
          layout.sectionInset = .zero
          
          let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
          return cv
      }()
     
    var mainEffectImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "mainEft")
        
    }
    
    var statusLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "번개가 요동치는 중"
    }
    
    var mentLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "현재 기다리고 있어요"
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    var searchJoinListBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("전체보기 >", for: .normal)
        $0.setTitleColor(UIColor.gray, for: .normal)
    }
    
    var alarmBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "alarm"), for: .normal)
    }
    
    var storageBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "storage"), for: .normal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setLayout()
    }
    

}


extension MainVC {
    private func setLayout() {
        view.addSubview(collectionView)
        view.addSubview(mainEffectImageView)
        view.addSubview(statusLabel)
        view.addSubview(mentLabel)
        view.addSubview(searchJoinListBtn)
        view.addSubview(alarmBtn)
        view.addSubview(storageBtn)
        
        collectionView.snp.makeConstraints {
                      $0.edges.equalTo(view.safeAreaLayoutGuide)
                          .inset(UIEdgeInsets(top: 130, left: 0, bottom: 0, right: 0))
                  }
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "mainCell")
        
        mainEffectImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.width.height.equalTo(56)
        }
        
        statusLabel.snp.makeConstraints{
            $0.leading.equalTo(mainEffectImageView.snp.leading)
            $0.top.equalTo(mainEffectImageView.snp.bottom).offset(16)
        }
        
        mentLabel.snp.makeConstraints{
            $0.leading.equalTo(mainEffectImageView.snp.leading)
            $0.top.equalTo(statusLabel.snp.bottom)
        }
        
        searchJoinListBtn.snp.makeConstraints{
            $0.centerY.equalTo(mentLabel.snp.centerY)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        
        alarmBtn.snp.makeConstraints{
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(storageBtn.snp.centerY)
            $0.trailing.equalTo(storageBtn.snp.leading).offset(-24)
        }
        
        storageBtn.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)

        }

    }
}

extension MainVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemSpacing : CGFloat = 56
            
            let myWidth : CGFloat = (self.view.frame.width - itemSpacing * 2)
            let myHeight : CGFloat = self.view.frame.height / 2
            
            
            return CGSize(width: myWidth, height: myHeight)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 56
    }
}
