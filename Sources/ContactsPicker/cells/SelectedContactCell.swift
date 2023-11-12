//
//  SelectedContactCell.swift
//  kfhonline
//
//  Created by Ehab on 19/09/2023.
//  Copyright © 2023 KFH. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SelectedContactCell: UICollectionViewCell {
    
    private let contactImg:UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "photo.artframe.circle.fill")
        img.clipsToBounds = true
        img.layer.cornerRadius = 26
        return img
    }()
    
    
    private lazy var contactNameLbl:UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = contactNameFont
        return lbl
    }()
    
    
    private let deleteBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .darkGray
        btn.layer.cornerRadius = 11
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = .white
        return btn
    }()
    
    
    private let signetureBG:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 26
        view.clipsToBounds = true
        view.backgroundColor = .black.withAlphaComponent(0.06)
        return view
    }()
    var contactNameFont:UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    var signetureFont:UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    private lazy var signetureLbl:UILabel = {
        let lbl = UILabel()
        lbl.font = signetureFont
        lbl.textColor = .black
        return lbl
    }()
    
    
    var contact:Contact? {
        didSet{
            guard let contact = contact else {return}
            contactNameLbl.text = contact.name
            signetureLbl.text = contact.getContactSigneture()
            if let imgData = contact.avatarData{
                self.contactImg.image = UIImage(data: imgData)
                self.signetureBG.isHidden = true
            }else{
                self.contactImg.image = nil
                self.signetureBG.isHidden = false
            }
        }
    }
    
    var callback:(() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [contactImg , contactNameLbl , signetureBG , deleteBtn].forEach { view in
            self.contentView.addSubview(view)
        }
        setupConstraints()
    }
    
    
    private func setupConstraints(){
        contactImg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(52)
        }
        
        contactNameLbl.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.top.equalTo(contactImg.snp.bottom).offset(4)
        }
        
        signetureBG.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(52)
        }
        signetureBG.isHidden = true
        signetureBG.addSubview(signetureLbl)
        signetureLbl.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.leading.equalTo(contactImg.snp.trailing).offset(-22)
            make.top.equalTo(contactImg.snp.top).offset(-5)
        }
        deleteBtn.addTarget(self, action: #selector(deleteBtnDidTapped), for: .touchUpInside)
    }
    
    
    @objc private func deleteBtnDidTapped(){
        callback?()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }
    
    
}
