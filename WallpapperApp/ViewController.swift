//
//  ViewController.swift
//  WallpapperApp
//
//  Created by Marcello Quarta on 25/09/2018.
//  Copyright © 2018 Marcello Quarta. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var dropView: DropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.layer?.borderColor = NSColor.lightGray.cgColor
        dropView.layer?.borderWidth = 0.3
        dropView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: DestinationViewDelegate {

    func processImageURLs(_ urls: [URL], center: NSPoint) {
        if urls.count > 16 {
            let alert = NSAlert()
            alert.messageText = "Hai selezionato troppe imamgini"
            alert.informativeText = "Puoi selezionare al massimo 16 immagini"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Annulla")
            alert.addButton(withTitle: "Usa le prime 16")
            alert.beginSheetModal(for: self.view.window!) { (result) in
                if result == NSApplication.ModalResponse.alertFirstButtonReturn {
                    return
                } else {
                    let acceptedUrls = Array(urls.prefix(16))
                    let savePanel = NSSavePanel()
                    savePanel.canCreateDirectories = true
                    savePanel.nameFieldStringValue = "output.heic"
                    savePanel.allowedFileTypes = ["heic"]
                    savePanel.beginSheetModal(for: self.view.window!) { (result) in
                        if result == NSApplication.ModalResponse.OK {
                            guard let outputUrl = savePanel.url else { return }
                            
                            guard let baseUrl = acceptedUrls.first?.deletingLastPathComponent() else {
                                return
                            }
                            
                            let infos = acceptedUrls.enumerated().map { (index: Int, url: URL) -> PictureInfo in
                                let filename = url.lastPathComponent
                                return PictureInfo(fileName: filename, isPrimary: true, isForLight: true, isForDark: false, altitude: Double(index) * 10.0, azimuth: Double(index) * 10.0)
                            }
                            
                            let generator = Generator(picureInfos: infos, baseURL: baseUrl, outputUrl: outputUrl)
                            do {
                                try generator.run()
                            } catch {
                                print("Unexpected error: \(error).")
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    func processImage(_ image: NSImage, center: NSPoint) {
        print(image)
    }
    
    func processAction(_ action: String, center: NSPoint){
        print(action)
    }
}

