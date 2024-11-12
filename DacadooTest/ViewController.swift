//
//  ViewController.swift
//  DacadooTest
//
//  Created by Milika Delic on 15.5.24..
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    var currentImage: UnsplashImageResult? = nil
    
    let imageViewSequeName = "goToImageView"
    
    @IBAction func searchButtonTouched(_ sender: Any) {
        hideError()
        Networking.shared.result.clear()
        self.tableView.reloadData()
        if let text = searchTextField.text, text.count > 0 {
            setInteraction(false)
            Networking.shared.delegate = self
            Networking.shared.search(text)
        } else {
            showError("No search text entered!")
        }
    }
    
    func setInteraction(_ state:Bool) {
        DispatchQueue.main.async {
            self.searchTextField.isEnabled = state
            self.searchButton.isEnabled = state
            self.tableView.isUserInteractionEnabled = state
        }
    }
    
    func showError(_ text:String) {
        DispatchQueue.main.async {
            var text = text
            if let oldText = self.errorLabel.text {
                text = oldText + "\n" + text
            }
            self.errorLabel.text = text
            self.errorLabel.sizeToFit()
            self.errorLabel.isHidden = false
        }
    }
    
    func hideError() {
        DispatchQueue.main.async {
            self.errorLabel.text = ""
            self.errorLabel.sizeToFit()
            self.errorLabel.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imageViewSequeName {
            guard let vc = segue.destination as? ImageViewController else { return }
            if let image = currentImage {
                vc.currentImage = image.image
                image.image = nil
            }
        }
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Networking.shared.result.images.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.item
        if let image = Networking.shared.result.getImageResized(index) {
            return image.size.height + 16
        } else {
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        if let image = Networking.shared.result.getImage(index) {
            image.loadImage()
            currentImage = image
            performSegue(withIdentifier: imageViewSequeName, sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell") as! ImageViewCell
        if let image = Networking.shared.result.getImage(index) {
            cell.customize(image.imageResized, description: image.imageDescription)
        }
        return cell
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let delta = scrollView.contentSize.height-scrollView.contentOffset.y-scrollView.visibleSize.height
        if delta < (scrollView.visibleSize.height*2.0) {
            Networking.shared.loadNextPage()
        }
        
    }
}


class ImageViewCell : UITableViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    
    func customize(_ image: UIImage?, description:String) {
        if let image = image {
            cellImageView.image = image
            cellImageView.sizeToFit()
        } else {
            cellImageView.image = UIImage(systemName: "photo")
            cellImageView.sizeToFit()
        }
        cellImageView.accessibilityLabel = description
        cellImageView.isAccessibilityElement = description.count > 0
    }
}

extension ViewController: NetworkingDelegate {
    func pageLoaded() {
        DispatchQueue.main.async {
           
            let tableRows = self.tableView.numberOfRows(inSection: 0)
            let imagesCount = Networking.shared.result.images.count
            if (tableRows == 0) || (imagesCount == 0) || (tableRows > imagesCount) {
                self.tableView.reloadData()
            } else {
                if tableRows < imagesCount {
                    self.tableView.beginUpdates()
                    var indexPaths:[IndexPath] = []
                    for i in tableRows..<imagesCount {
                        let indexPath = IndexPath(row: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                }
            }
           
        }
        self.setInteraction(true)
    }
    
    func errorHandle(error: any Error) {
        var description = "\(error)"
        let error = error as NSError
        if error.domain == Networking.errorDomain {
            if let errorInfo = error.userInfo[Networking.errorInfoKey] as? String {
                description = errorInfo
            }
        }
        self.showError(description)
        self.setInteraction(true)
    }
    
    func updatedImage(index: Int) {
        DispatchQueue.main.async {
            let tableRows = self.tableView.numberOfRows(inSection: 0)
            let imagesCount = Networking.shared.result.images.count
            if (tableRows == imagesCount) && (tableRows > index) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
