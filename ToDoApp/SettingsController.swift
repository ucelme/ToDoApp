import UIKit
import MessageUI

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
        switch indexPath.row {
              case 0: feedback()
              case 1: review()
              case 2: share()
              default: break
              }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            myApps()
        }
    }
    
    func review() {
        guard let url = URL(string: "https://itunes.apple.com/app/id\(AppInfo.appID)?action=write-review") else {return}
        UIApplication.shared.open(url)
    }

    func share() {
        let url = "https://itunes.apple.com/app/id\(AppInfo.appID)"
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
      if let popoverController = vc.popoverPresentationController {
          popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
          popoverController.sourceView = self.view
          popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
      }

        present(vc, animated: true)
    }
    
    func feedback() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["takirs@list.ru"])
            mail.setSubject("\(AppInfo.appName)")
            present(mail, animated: true)
        }
    
    func myApps() {
        guard let url = URL(string: "https://apps.apple.com/us/developer/maria-abramova/id1545047801") else {return}
        UIApplication.shared.open(url)

    }
}

