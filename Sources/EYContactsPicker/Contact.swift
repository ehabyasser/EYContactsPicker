//
//  Contact.swift
//  kfhonline
//
//  Created by Ehab on 19/09/2023.
//

import Foundation
import ContactsUI


public class Contact: Equatable , Codable{
    public var name: String?
    public var avatarData: Data?
    public var phoneNumber: [String] = [String]()
    public var email: [String] = [String]()
    public var isSelected: Bool = false
    
    init(contact: CNContact) {
        name        = String(contact.givenName + " " + contact.familyName)
        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }
    
    
    init(name: String , avatarData: Data? ,  phoneNumber: [String] = [String]()){
        self.name = name
        self.avatarData = avatarData
        self.phoneNumber = phoneNumber
    }
    
    
    public func hasValidNumber(for country:ContactCountry) -> Bool {
        let phone = phoneNumber.first?.removeCountryCode()
        return phone?.isValidPhoneNumber(country) ?? false
    }
    
    public func getValidNumber(country:ContactCountry) -> String? {
        return phoneNumber.first { phone in
            phone.isValidPhoneNumber(country)
        }?.removeCountryCode().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    
    public func avatar() -> String?{
        guard let contactAvatar = avatarData else{return nil}
        return String(data: contactAvatar, encoding: .utf8)
    }
    
    public func getContactSigneture() -> String{
        if name?.split(separator: " ").count ?? 0 > 1 , let firstChar = name?.split(separator: " ").first?.prefix(1) , let secondChar = name?.split(separator: " ").last?.prefix(1) {
            return "\(firstChar)\(secondChar)".uppercased()
        }else if let firstChar = name?.split(separator: " ").first?.prefix(1){
            return "\(firstChar)".uppercased()
        }
        return ""
    }
    
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return !lhs.phoneNumber.intersection(with: rhs.phoneNumber).isEmpty
    }

}

struct GroupedContacts {
    let section:String
    let contacts:[Contact]
}

extension String {
    
    func isValidPhoneNumber(_ country: ContactCountry) -> Bool {
        switch country {
        case .KW:
            guard self.count == 8 else {
                return false
            }
            let validStartDigits = ["4", "5", "6", "9"]
            guard let firstDigit = self.first, validStartDigits.contains(String(firstDigit)) else {
                return false
            }
            return true
        case .all:
            return true
        }
    }
    
    func removeCountryCode() -> String {
        let countryCodePattern = #"^\+(\d{1,4})"#
        if let range = self.range(of: countryCodePattern, options: .regularExpression) {
            return String(self[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

extension Array where Element: Hashable {
    func intersection(with otherArray: [Element]) -> [Element] {
        let set1 = Set(self)
        let set2 = Set(otherArray)
        let intersectionSet = set1.intersection(set2)
        return Array(intersectionSet)
    }
    
    mutating func removeFirst(_ element:Element){
        if let index = self.firstIndex(where: { item in
            item == element
        }){
            self.remove(at: index)
        }
    }
}
