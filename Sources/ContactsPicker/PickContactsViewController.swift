//
//  PickContactsViewController.swift
//  kfhonline
//
//  Created by Ehab on 19/09/2023.
//


import UIKit
import ContactsUI
import SnapKit

public enum PickerSelectionType{
    case list
    case sigle
}

public enum ContactCountry{
    case KW
    case all
}


public struct PickerTheme{
    let doneBtnFont:UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    let titleFont:UIFont = UIFont.systemFont(ofSize: 26, weight: .bold)
    let countFont:UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    let subTitleFont:UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    let searchFont:UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    let sectionFont:UIFont = UIFont.systemFont(ofSize: 13, weight: .bold)
    let tintColor:UIColor = .orange
}

@available(iOS 13.0, *)
public class PickContactsViewController: UIViewController {
    
    
    private let pageTitle:String
    private let pageDescription:String
    private let pickerType:PickerSelectionType
    private var selectedContacts:[Contact]
    private let callback:(([Contact]) -> ())?
    private let totalSelection:Int
    private let country:ContactCountry
    private let isRTL:Bool
    private let theme:PickerTheme
    public init(title: String, description: String, pickerType: PickerSelectionType = .list , country:ContactCountry = .all , totalSelection:Int = 20 , theme:PickerTheme? = nil , isRTL:Bool, selectedContacts: [Contact] = [], callback: (([Contact]) -> Void)?) {
        self.pageTitle = title
        self.pageDescription = description
        self.pickerType = pickerType
        self.selectedContacts = selectedContacts
        self.callback = callback
        self.totalSelection = totalSelection
        self.country = country
        self.isRTL = isRTL
        self.theme = theme ?? PickerTheme()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var backBtn:UIButton = {
       let btn = UIButton()
        btn.setImage(isRTL ? UIImage(systemName: "arrow.forward") : UIImage(systemName: "arrow.backward"), for: .normal)
        btn.tintColor = theme.tintColor
        return btn
    }()
    
    
    private lazy var doneBtn:UIButton = {
        let btn = UIButton()
        btn.setTitleColor(theme.tintColor, for: .normal)
        btn.setTitle(isRTL ? "تم" : "Done", for: .normal)
        btn.titleLabel?.font = theme.doneBtnFont
        return btn
    }()
    
    private lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = theme.titleFont
        if isRTL {
            lbl.textAlignment = .right
        }else{
            lbl.textAlignment = .left
        }
    
        return lbl
    }()
    
    private lazy var subTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black.withAlphaComponent(0.68)
        lbl.font = theme.subTitleFont
        if isRTL {
            lbl.textAlignment = .right
        }else{
            lbl.textAlignment = .left
        }
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private lazy var countLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = theme.countFont
        lbl.textColor = .black.withAlphaComponent(0.46)
        return lbl
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.searchTextField.font = theme.searchFont
        search.placeholder = isRTL ? "بحث" : "Search"
        return search
    }()
    
    
    private lazy var selectedContactsCV: UICollectionView = {
        let layout = isRTL ? RTLCollectionViewFlowLayout() : UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    private lazy var contactsTV:UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.sectionIndexColor = theme.tintColor
        return table
    }()
    
    private let stack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let formatter =  CNContactFormatter()
    private var contacts:[CNContact] = []
    private var filteredContacts:[GroupedContacts] = []
    private var contactsHandler = ContactsPickerHandler()
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.isModalInPresentation = true
        self.titleLbl.text = pageTitle
        self.subTitleLbl.text = pageDescription
        self.formatter.style = .fullName
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor : theme.tintColor , .font: theme.searchFont], for: .normal)
        hideShowSelectedContactsList()
        stack.addArrangedSubview(selectedContactsCV)
        stack.addArrangedSubview(contactsTV)
        selectedContactsCV.delegate = self
        selectedContactsCV.dataSource = self
        selectedContactsCV.register(SelectedContactCell.self, forCellWithReuseIdentifier: "SelectedContactCell")
        contactsTV.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        contactsTV.delegate = self
        contactsTV.dataSource = self
        searchBar.delegate = self
        searchBar.searchTextField.doneAccessory = true
        if isRTL {
            searchBar.semanticContentAttribute = .forceRightToLeft
            searchBar.searchTextField.textAlignment = .right
            contactsTV.semanticContentAttribute = .forceRightToLeft
        }else{
            searchBar.semanticContentAttribute = .forceLeftToRight
            searchBar.searchTextField.textAlignment = .left
            contactsTV.semanticContentAttribute = .forceLeftToRight
        }
        [backBtn , doneBtn , titleLbl , subTitleLbl , countLbl , searchBar , stack].forEach {
            self.view.addSubview($0)
        }
        backBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(done), for: .touchUpInside)
        setupConstaints()
        doneBtn.isHidden = pickerType == .sigle
        doneBtn.isUserInteractionEnabled = pickerType == .list
        selectedContactsCV.isHidden = (pickerType == .list && selectedContacts.isEmpty) || pickerType == .sigle
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        requestAccess { isGranted in
            if isGranted {
                DispatchQueue.main.async {
                    DispatchQueue.global(qos: .background).async {
                        self.contacts = self.contactsHandler.fliterByCountry(contacts: self.contactsHandler.fetchDeviceContacts(), country: self.country)
                        let sectionedContacts = self.contactsHandler.groupedContacts(contacts: self.contacts)
                        DispatchQueue.main.async {
                            self.filteredContacts = sectionedContacts
                            self.reselectItems()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func close(){
        self.dismiss(animated: true)
    }
    
    
    @objc private func done(){
        if selectedContacts.isEmpty {
            //display error message
        }else{
            callback?(selectedContacts)
            self.dismiss(animated: true)
        }
        
    }
    
    private func setupConstaints(){
        backBtn.snp.makeConstraints { make in
            if isRTL {
                make.trailing.equalToSuperview().offset(-18)
            }else{
                make.leading.equalToSuperview().offset(21)
            }
            make.top.equalToSuperview().offset(31)
            make.width.height.equalTo(25)
        }
        
        
        doneBtn.snp.makeConstraints { make in
            if isRTL {
                make.leading.equalToSuperview().offset(21)
            }else{
                make.trailing.equalToSuperview().offset(-21)
            }
            make.top.equalToSuperview().offset(31)
        }
        
        titleLbl.snp.makeConstraints { make in
            if isRTL {
                make.trailing.equalToSuperview().offset(-21)
            }else{
                make.leading.equalToSuperview().offset(21)
            }
            make.top.equalTo(backBtn.snp.bottom).offset(32)
        }
        
        subTitleLbl.snp.makeConstraints { make in
            if isRTL {
                make.trailing.equalToSuperview().offset(-21)
                make.leading.equalToSuperview().offset(21)
            }else{
                make.trailing.equalToSuperview().offset(-21)
                make.leading.equalToSuperview().offset(21)
            }
            make.top.equalTo(titleLbl.snp.bottom).offset(15)
        }
        
        countLbl.snp.makeConstraints { make in
            if isRTL {
                make.leading.equalToSuperview().offset(21)
            }else{
                make.trailing.equalToSuperview().offset(-21)
            }
            make.centerY.equalTo(titleLbl.snp.centerY)
        }
        
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(36)
            make.trailing.equalToSuperview().offset(-36)
            make.top.equalTo(subTitleLbl.snp.bottom).offset(16)
        }
        
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(16)
        }
        
        selectedContactsCV.snp.makeConstraints { make in
            make.height.equalTo(110)
        }
    }
    
    
    private func isToDisplaySelected() -> Bool{
        return !selectedContacts.isEmpty
    }
    
    private func hideShowSelectedContactsList(){
        self.countLbl.text = "\(selectedContacts.count)/\(totalSelection)"
        if pickerType == .list {
            if self.isToDisplaySelected() {
                UIView.animate(withDuration: 0.35,
                               delay: 0,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 1,
                               options: [],
                               animations: {
                    self.selectedContactsCV.isHidden = false
                    UIView.performWithoutAnimation {
                        self.selectedContactsCV.reloadData()
                    }
                },completion: nil)
            }else{
                self.selectedContactsCV.isHidden = true
                UIView.performWithoutAnimation {
                    self.selectedContactsCV.reloadData()
                }
            }
        }
    }
    
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        @unknown default:
            print("unkown")
        }
    }

    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                    completionHandler(false)
                    UIApplication.shared.open(settings)
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
}
@available(iOS 13.0, *)
extension PickContactsViewController:UITableViewDelegate , UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return filteredContacts.count
    }
    

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        let key = filteredContacts[section].section
        let title: UILabel = UILabel()
        title.font = theme.sectionFont
        title.textColor = .black.withAlphaComponent(0.45)
        title.text = key
        title.textAlignment = isRTL ? .right : .left
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if isRTL {
                make.trailing.equalToSuperview().offset(-34)
            }else{
                make.leading.equalToSuperview().offset(34)
            }
        }
        return view
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts[section].contacts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.selectionStyle = .none
        let contact = filteredContacts[indexPath.section].contacts[indexPath.row]
        cell.contact = contact
        cell.country = self.country
        cell.isRTL = self.isRTL
        cell.pickerTintColor = self.theme.tintColor
        cell.radioBtn.isHidden = self.pickerType == .sigle
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = filteredContacts[indexPath.section].contacts[indexPath.row]
        self.view.endEditing(true)
        if !contact.hasValidNumber(for: country) {
            if pickerType == .list {
               // Toast.shared.show(message: "\("Unable to add".appLocalized) \(contact.name ?? "") \("to the group due to wrong mobile number".appLocalized)" , boldPart: contact.name ?? "")
            }else{
                //Toast.shared.show(message: "\("Unable to add".appLocalized) \(contact.name ?? "") \("due to wrong mobile number".appLocalized)" , boldPart: contact.name ?? "")
            }
            return
        }
        if pickerType == .list {
            if contact.isSelected  {
               // Toast.shared.show(message: "contact_selected".appLocalized)
            }else{
                if self.selectedContacts.count >= totalSelection {
                    //Toast.shared.show(message: "exceed_contacts_count".appLocalized)
                    return
                }
                if self.selectedContacts.firstIndex(of: contact) == nil {
                    self.selectedContacts.append(contact)
                    filteredContacts[indexPath.section].contacts[indexPath.row].isSelected = !filteredContacts[indexPath.section].contacts[indexPath.row].isSelected
                    UIView.performWithoutAnimation {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }else{
                    //Toast.shared.show(message: "contact_selected".appLocalized)
                }
                self.hideShowSelectedContactsList()
            }
        }else{
            callback?([contact])
            self.dismiss(animated: true)
        }
        
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return filteredContacts.map{ $0.section }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

}
@available(iOS 13.0, *)
extension PickContactsViewController:UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedContacts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedContactCell", for: indexPath) as! SelectedContactCell
        cell.contact = selectedContacts[indexPath.row]
        cell.callback = {
            for (section , _) in self.filteredContacts.enumerated() {
                let contacts = self.filteredContacts[section].contacts
                if let row = contacts.firstIndex(of: self.selectedContacts[indexPath.row]){
                    self.filteredContacts[section].contacts[row].isSelected = false
                    UIView.performWithoutAnimation {
                        self.contactsTV.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
                    }
                    break
                }
            }
            self.selectedContacts.remove(at: indexPath.row)
            self.hideShowSelectedContactsList()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 95)
    }
    
}
@available(iOS 13.0, *)
extension PickContactsViewController:UISearchBarDelegate{
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        if let text = searchBar.text , text.isEmpty {
            filteredContacts = contactsHandler.groupedContacts(contacts: contacts)
            self.reselectItems()
        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let filtredOptions  = contacts.filter({ (item) -> Bool in
            let fullName = formatter.string(from: item) ?? ""
            var exist = false
            if fullName.lowercased().contains(searchText.lowercased()) {
                exist = true
            }
            if searchText == "" {
                exist = true
            }
            return exist
        })

        if(filtredOptions.count == 0 ){
            filteredContacts.removeAll()
            self.contactsTV.reloadData()
        } else {
            filteredContacts.removeAll()
            filteredContacts = contactsHandler.groupedContacts(contacts: filtredOptions)
            self.reselectItems()
        }

        
    }
    
    private func reselectItems(){
        for contact in selectedContacts {
            for (section , _) in filteredContacts.enumerated() {
                let contacts = filteredContacts[section].contacts
                if let row = contacts.firstIndex(of: contact) {
                    self.filteredContacts[section].contacts[row].isSelected = true
                    break
                }
                
            }
        }
        self.contactsTV.reloadData()
    }
}

class RTLCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }

    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return UIUserInterfaceLayoutDirection.rightToLeft
    }
}
