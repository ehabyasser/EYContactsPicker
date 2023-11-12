//
//  ContactCell.swift
//  kfhonline
//
//  Created by Ehab on 19/09/2023.
//  Copyright © 2023 KFH. All rights reserved.
//

import UIKit
import SnapKit

@available(iOS 13.0, *)
class ContactCell: UITableViewCell {
    
    private let contactImg:UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "photo.artframe.circle.fill")
        img.clipsToBounds = true
        img.layer.cornerRadius = 26
        return img
    }()
    
    var country:ContactCountry = .all
    var isRTL:Bool = false {
        didSet{
            contactNameLbl.textAlignment = isRTL ? .right : .left
            contactNumLbl.textAlignment = isRTL ? .right : .left
        }
    }
    var contactNameFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    var contactNumFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    var pickerTintColor: UIColor = .orange
    
    private lazy var contactNameLbl:UILabel = {
        let lbl = UILabel()
        lbl.font = contactNameFont
        lbl.textAlignment = isRTL ? .right : .left
        lbl.textColor = .black
        return lbl
    }()
    
    private lazy var contactNumLbl:UILabel = {
        let lbl = UILabel()
        lbl.font = contactNumFont
        lbl.textColor = .black.withAlphaComponent(0.68)
        return lbl
    }()
    
    
    private let signetureBG:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 26
        view.clipsToBounds = true
        view.backgroundColor = .black.withAlphaComponent(0.06)
        return view
    }()
    
    
    private lazy var signetureLbl:UILabel = {
        let lbl = UILabel()
        lbl.font = contactNameFont
        lbl.textColor = .black
        return lbl
    }()
    
    lazy var radioBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.setImage(UIImage(systemName: "record.circle"), for: .selected)
        btn.tintColor = pickerTintColor
        return btn
    }()
    
    private let separator:UIView = {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        return separator
    }()
    
    
    var contact:Contact? {
        didSet{
            guard let contact = contact else {return}
            contactNameLbl.text = contact.name
            contactNumLbl.text = contact.getValidNumber(country: country)
            signetureLbl.text = contact.getContactSigneture()
            if let imgData = contact.avatarData{
                self.contactImg.image = UIImage(data: imgData)
                self.contactImg.isHidden = false
                self.signetureBG.isHidden = true
            }else{
                self.contactImg.isHidden = true
                self.signetureBG.isHidden = false
            }
            radioBtn.isSelected = contact.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addViews()
        setupConstraints()
    }
    
    
    private func addViews(){
        [contactImg , contactNameLbl , contactNumLbl , radioBtn , separator , signetureBG].forEach { view in
            self.contentView.addSubview(view)
        }
    }
    
    private func setupConstraints(){
        contactImg.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        
        radioBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-27)
            make.width.height.equalTo(20)
        }
        
        contactNumLbl.snp.makeConstraints { make in
            make.leading.equalTo(contactImg.snp.trailing).offset(11)
            make.trailing.equalTo(radioBtn.snp.leading).offset(-8)
            make.top.equalTo(contactNameLbl.snp.bottom).offset(1)
        }
        
        contactNameLbl.snp.makeConstraints { make in
            make.leading.equalTo(contactImg.snp.trailing).offset(11)
            make.trailing.equalTo(radioBtn.snp.leading).offset(-8)
            make.top.equalTo(contactImg.snp.top).offset(11)
        }
        
        separator.snp.makeConstraints { make in
            make.trailing.equalTo(radioBtn.snp.centerX)
            make.leading.equalTo(contactNameLbl.snp.leading)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
        signetureBG.snp.makeConstraints{ make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        signetureBG.isHidden = true
        signetureBG.addSubview(signetureLbl)
        signetureLbl.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
}
