# EYContactsPicker
![CocoaPods](https://img.shields.io/cocoapods/v/EYContactsPicker) [![codebeat badge](https://codebeat.co/badges/cd7df8d3-4e12-4c57-9d28-ff9e78c21420)](https://codebeat.co/projects/github-com-ehabyasser-eycontactspicker-main) ![contributions](https://img.shields.io/badge/contributions-welcome-informational.svg)

A modern, highly customisable contact picker with multi-selection options that closely resembles the behaviour of the ContactsUI's CNContactPickerViewController.

# Preview
|![Single Deselect Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.15.23.png)|![Single Reselect Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.17.47.png)|![Multiple Select Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.17.59.png)||![Single Deselect Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.18.12.png)|![Single Reselect Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.18.18.png)|![Multiple Select Mode](https://github.com/ehabyasser/EYContactsPicker/blob/main/images/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202023-11-13%20at%2019.18.44.png)|
|---|---|---|
|Single Deselect|Single Reselect|Multi Select|

# Installation

## CocoaPods
Add this to your podfile for the latest version
```
pod 'EYContactsPicker'
```
Or specify desired version
```
pod 'EYContactsPicker', '~> 1.0.0'
```


## Manual Installation
Download and include the `EYContactsPicker` folder and files in your codebase.

## Requirements
 - iOS 12+
 - Swift 5
 
# Features
    EYContactsPicker is a modern, customisable and easy to use Contacts Picker similar to the stock CNContactPickerViewController. It does improve in a couple of area for a better UX.


Make sure your app (the host app) has provided a `Privacy - Contacts Usage Description` in your `Info.plist`. 
It's also recommended that you check that contact authorisation is granted. 

## How to use
```swift
// This is in your application
        var theme = PickerTheme()
        theme.tintColor = .green
        let vc = PickContactsViewController(title: "test", description: "test description", pickerType: .list, country: .all , totalSelection: 100, theme: theme ,  isRTL: false) { contacts in
            for conatact in contacts {
                print(conatact.name ?? "")
                print(conatact.phoneNumber)
            }
        }
        self.present(vc, animated: true)
```
