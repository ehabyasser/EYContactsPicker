//
//  ContactsPickerHandler.swift
//  kfhonline
//
//  Created by Ehab on 19/09/2023.
//

import Foundation
import ContactsUI

class ContactsPickerHandler: NSObject {

    static let shared = ContactsPickerHandler()
    
    func fetchDeviceContacts() -> [CNContact]{
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
    
    private func sortByGivenName(c1: CNContact, c2:CNContact) -> Bool {
        if c1.givenName == c2.givenName {
            return c1.familyName < c2.familyName
        }
        return c1.givenName < c2.givenName
    }

    
    private func sortContactsIntoSections(contacts: [CNContact]) -> (sections: [String], sortedContacts: [CNContact], contactsSortedInSections: [GroupedContacts]) {
        var sortedContacts: [CNContact] = []
        var sortedContactsInSection: [String: [Contact]] = [:]
        let ALL_OTHERS_VALUE = "#"
        sortedContacts = contacts.sorted(by: { sortByGivenName(c1: $0, c2: $1) })
        for contact in sortedContacts {
            sortedContactsInSection = self.addToSortedContacts(sortedContactsInSection, contact: contact, groupBy: {
                if (decideOnLetter(for: contact.givenName) == ALL_OTHERS_VALUE) {
                    return self.decideOnLetter(for: contact.familyName)
                }
                return String(contact.givenName.first!).uppercased()
            })
        }
        
        return ([], sortedContacts, sortWithKeys(sortedContactsInSection))
    }
    
    private func addToSortedContacts(_ sortedContacts: [String: [Contact]], contact: CNContact, groupBy groupingFunction: () -> String) -> [String: [Contact]] {
        var sorted = sortedContacts
        let section = groupingFunction()
        var contactsArray = sortedContacts[section] ?? [Contact]()
        contactsArray.append(Contact(contact: contact))
        sorted[section] = contactsArray
        return sorted
    }
    
    private func decideOnLetter(for word: String, initial: String = "#", returnFull: Bool = false) -> String {
        if (word.isEmpty) { return initial }
        return returnFull ? String(word).uppercased() : String(word.first!).uppercased()
    }
    
    func groupedContacts(contacts:[CNContact]) -> [GroupedContacts]{
        return sortContactsIntoSections(contacts: contacts).contactsSortedInSections
    }
    
    func getContacts(contacts:[CNContact]) -> [Contact]{
        var myContacts:[Contact] = []
        sortContactsIntoSections(contacts: contacts).contactsSortedInSections.forEach { group in
            myContacts.append(contentsOf: group.contacts)
        }
        return myContacts
    }
    
   
    
    func sortWithKeys(_ dict: [String: [Contact]]) -> [GroupedContacts] {
        let sorted = dict.sorted(by: { $0.key < $1.key })
            var newDict: [GroupedContacts] = []
            for sortedDict in sorted {
                let groupeContact = GroupedContacts(section: sortedDict.key, contacts: sortedDict.value)
                newDict.append(groupeContact)
            }
        return newDict
    }
    
    
    func contactImg(phoneNumber:String?) -> Data?{
        guard let phoneNumber = phoneNumber else {return nil}
        let listOfContacts = getContacts(contacts: fetchDeviceContacts())
        if let contact = listOfContacts.first(where: { contact in
            contact.phoneNumber.contains { phone in
                phone == phoneNumber
            }
        }){
            return contact.avatarData
        }
        return nil
    }
    
    
    func fliterByCountry(contacts:[CNContact] , country:ContactCountry) ->[CNContact]{
        if country == .all {
            return contacts
        }
        return contacts.filter { contact in
            contact.phoneNumbers.contains { phone in
                phone.value.stringValue.isValidPhoneNumber(country)
            }
        }
    }
}
