//
//  ViewController.swift
//  AdjustExample-Swift
//
//  Created by Aditi Agrawal on 22/08/22.
//

import UIKit
import Adjust

class ViewController: UIViewController {

    let features = ["Event tracking", "Revenue Tracking", "Go Online", "Go Offline", "Enable SDK", "Disable SDK",]

    @IBOutlet var featuresTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        featuresTableView.delegate = self
        featuresTableView.dataSource = self
    }
}

// MARK: - Tableview Datasource and Delegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Adjust's Features List"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.features[indexPath.row]
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("You selected cell #\(indexPath.section), \(indexPath.row)!")

        if (indexPath.section == 0) {
            switch(indexPath.row)
            {
            case 0:
                eventTracking()
                break;
            case 2:
                goOnline()
                break;
            case 3:
                goOffline()
                break;
            case 4:
                enableSDK()
                break;
            case 5:
                disableSDK()
                break;
            default:
                break;
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Actions

    func eventTracking() {
        let event = ADJAdjustEvent(eventToken: "7j4kwr")
        ADJAdjust.instance().trackEvent(event)
    }

    func goOnline() {
        ADJAdjust.instance().switchBackToOnlineMode()
    }

    func goOffline() {
        ADJAdjust.instance().switchToOfflineMode()
    }

    func enableSDK() {
        ADJAdjust.instance().reactivateSdk()
    }

    func disableSDK() {
        ADJAdjust.instance().inactivateSdk()
    }

}

