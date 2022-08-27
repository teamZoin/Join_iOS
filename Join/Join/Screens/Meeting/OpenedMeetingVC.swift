//
//  OpenedMeetingVC.swift
//  Join
//
//  Created by 이윤진 on 2022/06/16.
//

import UIKit

import SnapKit
import SwiftyJSON
import Then
import RxCocoa
import RxSwift
import Moya

class OpenedMeetingVC: BaseViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .grayScale900
        collectionView.register(OpenedMeetingCVCell.self, forCellWithReuseIdentifier: OpenedMeetingCVCell.identifier)
        return collectionView
    }()

    private let emptyView = UIView().then {
        $0.backgroundColor = .grayScale900
    }
    private let emptyStatusLabel = UILabel().then {
        $0.text = "보관함이 비어있어요."
        $0.textColor = .grayScale300
        $0.font = .minsans(size: 18, family: .Medium)
    }
    private let emptySubLabel = UILabel().then {
        $0.text = "친구들과 번개활동을 해보세요."
        $0.textColor = .grayScale600
        $0.font = .minsans(size: 16, family: .Medium)
    }
    private let emptyImage = UIImageView().then {
        $0.image = Image.thinking
    }
    let listProvider = MoyaProvider<ProfileServices>()
    var meetingInfo = [meetingData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        getMeetingList()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(isHidden: false)
        setUpNavigation()
        setTabBarHidden(isHidden: true)
    }
}

extension OpenedMeetingVC {
    private func setLayout() {
        view.backgroundColor = .grayScale900
        view.isOpaque = true
        view.adds([
            collectionView,
            emptyView
        ])
        emptyView.adds([
            emptyStatusLabel,
            emptySubLabel,
            emptyImage
        ])
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(160)
            make.centerX.equalToSuperview()
            make.size.equalTo(115)
        }
        emptyStatusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImage.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        emptySubLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyStatusLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func setUpNavigation() {
        title = "모집 중"
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationBar.isTranslucent = false

    }


    @objc func getMeetingList() {
        listProvider.rx.request(.getCreatedHistory(isClosed: "false"))
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                if response.statusCode == 200 {
                    let arr = JSON(response.data)["data"]
                    if(arr.count == 0) {
                        self?.emptyView.isHidden = false
                    } else {
                        self?.emptyView.isHidden = true
                    }
                    print(arr)
                    self?.meetingInfo = []
                    for item in arr.arrayValue {
                        let createrId = item["creator"]["id"].intValue
                        let createrServiceId = item["creator"]["serviceId"].stringValue
                        let userName = item["creator"]["userName"].stringValue
                        let email = item["creator"]["email"].stringValue
                        let profileImage = item["creator"]["profileImgUrl"].stringValue
                        let createdAt = item["creator"]["createdAt"].stringValue
                        let updatedAt = item["creator"]["updatedAt"].stringValue
                        let createdInfo = creater(id: createrId, serviceId: createrServiceId, userName: userName, email: email, profileImgUrl: profileImage, createdAt: createdAt, updatedAt: updatedAt)

                        let id = item["id"].intValue
                        let title = item["title"].stringValue
                        let location = item["location"].stringValue
                        let appointmentTime = item["appointmentTime"].stringValue
                        let requiredParticipatedCount = item["requiredParticipantsCount"].intValue
                        let cAt = item["createdAt"].stringValue
                        let uAt = item["updatedAt"].stringValue
                        let participatedCnt = item["participantCnt"].intValue
                        let description = item["description"].stringValue
                        self?.meetingInfo.append(meetingData(
                            id: id,
                            creater: createdInfo,
                            title: title,
                            location: location,
                            appointmentTime: appointmentTime,
                            requiredParticipantsCount: requiredParticipatedCount,
                            createdAt: cAt,
                            updatedAt: uAt,
                            participantCnt: participatedCnt,
                            description: description
                        ))
                    }
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }

                }
            }, onError: {[weak self] err in
                print(err)
            }, onCompleted: {

            }).disposed(by: disposeBag)
    }
}

extension OpenedMeetingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetingInfo.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OpenedMeetingCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenedMeetingCVCell.identifier, for: indexPath) as! OpenedMeetingCVCell
        cell.profileImageView.image = Image.profile
        cell.userNameLabel.text = meetingInfo[indexPath.item].creater.userName
        cell.userIdLabel.text = meetingInfo[indexPath.item].creater.serviceId
        cell.titleLabel.text = meetingInfo[indexPath.item].title
        cell.dateLabel.text = meetingInfo[indexPath.item].appointmentTime
        cell.locationLabel.text = meetingInfo[indexPath.item].location
        cell.memberCountLabel.text = "\(meetingInfo[indexPath.item].participantCnt)/\(meetingInfo[indexPath.item].requiredParticipantsCount)"
        return cell
    }
}

extension OpenedMeetingVC: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 110)
    }
}
