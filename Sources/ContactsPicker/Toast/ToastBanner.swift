//
//  ToastBanner.swift
//  ToolTip
//
//  Created by Ihab yasser on 13/07/2023.
//

import UIKit

@available(iOS 13.0, *)
public protocol BannerTheme {
    var icon : UIImage? {get}
    var backgorundColor:UIColor {get}
    var iconColor:UIColor {get}
    var textColor:UIColor {get}
    var messageFont:UIFont {get}
    var titleFont:UIFont {get}
    var time:Int {get}
    var iconSize:CGFloat {get}
    var style:BannerStyle{ get set }
}
@available(iOS 13.0, *)
public enum BannerStyle{
    case error
    case warning
    case info
    case success
    case noInternet
}

@available(iOS 13.0, *)
public enum BannerPosition{
    case Top
    case Bottom
}

@available(iOS 13.0, *)
public struct BannerSettings{
    public var theme:BannerTheme
    var position:BannerPosition = .Bottom
    
    public init(theme: BannerTheme) {
        self.theme = theme
    }
}

@available(iOS 13.0, *)
public class ToastBanner {
    public static let shared:ToastBanner = ToastBanner()
    public var settings:BannerSettings?
    private var workItem: DispatchWorkItem?
    private let stack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let icon:UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let iconView:UIView = {
        let img = UIView()
        img.backgroundColor = .clear
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let contentStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let contentView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLbl:LocalizedLable = {
        let lbl = LocalizedLable()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let messageLbl:LocalizedLable = {
        let lbl = LocalizedLable()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private var banner:UIView? = nil
    public func show(title:String = "" , message:String , style:BannerStyle , position:BannerPosition){
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                guard let window = self.getWindowView() else {return}
                if self.settings == nil {
                    self.settings = BannerSettings(theme: DefaultBannerStyle())
                }
                self.settings?.position = position
                self.settings?.theme.style = style
                if self.banner != nil {
                    self.banner?.removeFromSuperview()
                }
                self.banner = self.design()
                window.addSubview(self.banner!)
                self.banner!.leadingAnchor.constraint(equalTo: window.leadingAnchor , constant: 20).isActive = true
                self.banner!.trailingAnchor.constraint(equalTo: window.trailingAnchor , constant: -20).isActive = true
                self.banner!.heightAnchor.constraint(equalToConstant: 70).isActive = true
                if title.isEmpty {
                    self.titleLbl.isHidden = true
                }
                if message.isEmpty {
                    self.messageLbl.isHidden = true
                }
                switch self.settings?.position {
                case .Bottom:
                    self.banner!.bottomAnchor.constraint(equalTo: window.bottomAnchor , constant: 120).isActive = true
                    break
                case .Top:
                    self.banner!.topAnchor.constraint(equalTo: window.topAnchor , constant: -120).isActive = true
                    break
                case .none:
                    break
                }
                let swipGes = UISwipeGestureRecognizer(target: self, action: #selector(self.bannerSwipeGes))
                swipGes.direction = self.settings?.position == .Bottom ? .down : .up
                self.banner?.addGestureRecognizer(swipGes)
                let generator = UINotificationFeedbackGenerator()
                switch style {
                case .error:
                    generator.notificationOccurred(.error)
                    break
                case .info:
                    generator.notificationOccurred(.warning)
                    break
                case .warning:
                    generator.notificationOccurred(.warning)
                    break
                case .success:
                    generator.notificationOccurred(.success)
                    break
                case .noInternet:
                    generator.notificationOccurred(.warning)
                    break
                }
                
                let haptic =  UIImpactFeedbackGenerator(style: .medium)
                haptic.impactOccurred()
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.banner!.transform = CGAffineTransform(translationX: 0, y: self.settings!.position == .Bottom ?  self.banner!.frame.origin.y - 190 : self.banner!.frame.origin.y + 190)
                        
                        self.workItem = DispatchWorkItem {
                            self.dismiss()
                        }
                        let time = DispatchTimeInterval.seconds(self.settings?.theme.time ?? 3)
                        DispatchQueue.main.asyncAfter(deadline: .now() + time , execute: self.workItem!)
                    })
                self.titleLbl.text = title
                self.messageLbl.text = message
            }
        }
    }
    
    @objc private func bannerSwipeGes(){
        self.dismiss()
    }
    
    public func dismiss(){
        workItem?.cancel()
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                self.banner!.transform = CGAffineTransform(translationX: 0, y: self.banner!.frame.origin.y)
            }) { isEnded in
                if isEnded{
                    self.banner?.removeFromSuperview()
                }
            }
        
    }
    
    fileprivate func getWindowView() -> UIView?{
        if var topController = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).last(where: { $0.isKeyWindow })?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController.view
        }
        return nil
    }
    
    fileprivate func design() -> UIView{
        //design banner useing settings theme
        let view = UIView()
        view.backgroundColor = settings?.theme.backgorundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.dropShadow()
        view.addSubview(stack)
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 10).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor , constant: -10).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stack.addArrangedSubview(iconView)
        iconView.widthAnchor.constraint(equalToConstant: settings?.theme.iconSize ?? 32).isActive = true
        
        iconView.addSubview(icon)
        icon.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: settings?.theme.iconSize ?? 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: settings?.theme.iconSize ?? 24).isActive = true
        
        stack.addArrangedSubview(contentView)
        contentView.addSubview(contentStack)
        contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor , constant: -6).isActive = true
        contentStack.topAnchor.constraint(equalTo: contentView.topAnchor , constant: 6).isActive = true
        contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor , constant: -6).isActive = true
        
        contentStack.addArrangedSubview(titleLbl)
        contentStack.addArrangedSubview(messageLbl)
        titleLbl.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        icon.image = settings?.theme.icon?.withRenderingMode(.alwaysTemplate).withTintColor(settings?.theme.iconColor ?? .label)
        icon.tintColor = settings?.theme.iconColor ?? .label
        titleLbl.textColor = settings?.theme.textColor
        titleLbl.font = settings?.theme.titleFont
        messageLbl.textColor = settings?.theme.textColor
        messageLbl.font = settings?.theme.messageFont
        return view
    }
    
    class LocalizedLable: UILabel {
        override func layoutSubviews() {
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                textAlignment = .right
            }else{
                textAlignment = .left
            }
        }
    }
    
    
}




