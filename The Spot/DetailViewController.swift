//
//  DetailViewController.swift
//  The Spot
//
//  Created by Giorgia Marenda on 9/19/17.
//  Copyright © 2017 Giorgia Marenda. All rights reserved.
//

import UIKit
import GooglePlaces
import ContactsUI
import MessageUI

class DetailViewController: UIViewController {

    var spot: GMSPlace? {
        didSet {
            loadPhoto()
            titleLabel.text = spot?.name.uppercased()
            addressLabel.text = spot?.formattedAddress
        }
    }
    var selectedContact: CNContact?
    
    var placesClient = { GMSPlacesClient.shared() } ()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.image = #imageLiteral(resourceName: "default")
        return imageView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("SHARE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .black)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(showContactPicker), for: .touchUpInside)
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✖", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .black)
        label.sizeToFit()
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.sizeToFit()
        return label
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(contentView)
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        
        contentView.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true

        contentView.addSubview(addressLabel)
        addressLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true

        contentView.addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true

        view.addSubview(sendButton)
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    func fetchMeContact() -> String {
        // Assuming to know the user name from the login ???
        return "Giorgia"
    }
    
    @objc func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        present(contactPicker, animated: true, completion: nil)
    }

    func loadPhoto() {
        guard let spot = spot else { return }
        placesClient.lookUpPhotos(forPlaceID: spot.placeID) { (metadata, error) in
            if let error = error {
                print("An error occured: \(error)")
                return
            }
            if let results = metadata?.results, let firstImage = results.first {
                self.placesClient.loadPlacePhoto(firstImage, callback: { (image, error) in
                    if let error = error {
                        print("An error occured: \(error)")
                    }
                    self.imageView.image = image ?? #imageLiteral(resourceName: "default")
                })
            }
        }
    }
    
    func sendEmail(to address: String?) {
        guard let address = address else { return }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([address])
        composeVC.setSubject("Check out this spot!")
        composeVC.setMessageBody(deelLink(), isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func sendMessage(to number: String?) {
        guard let number = number else { return }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [number]
        composeVC.body = "Check out this \(deelLink())"
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func deelLink() -> String {
        return "spot://detail/?spot=\(spot?.placeID ?? "unknown")&from=\(fetchMeContact())"
    }
}

extension DetailViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        print(contactProperty.value ?? "Unknown")
        selectedContact = contactProperty.contact
        switch contactProperty.key {
        case "emailAddresses":
            if MFMailComposeViewController.canSendMail() {
                let delay = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.sendEmail(to: contactProperty.value as? String)
                }
                return
            }
        case "phoneNumbers":
            if MFMessageComposeViewController.canSendText() {
                let delay = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.sendMessage(to: (contactProperty.value as? CNPhoneNumber)?.stringValue)
                }
                return
            }
        default: break
        }
    }
}

extension DetailViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            if let placeID = spot?.placeID, let contact = selectedContact {
                let fullName = "\(contact.givenName) \(contact.familyName)"
                Store.addSentMessage(to: fullName, placeID: placeID)
            }
        default: break
        }
        controller.dismiss(animated: true, completion: { [weak self] in
            self?.dismissController()
        })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            if let placeID = spot?.placeID, let contact = selectedContact {
                let fullName = "\(contact.givenName) \(contact.familyName)"
                Store.addSentMessage(to: fullName, placeID: placeID)
            }
        default: break
        }
        controller.dismiss(animated: true, completion: { [weak self] in
            self?.dismissController()
        })
    }
}


