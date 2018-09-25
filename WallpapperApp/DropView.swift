//
//  DropView.swift
//  WallpapperApp
//
//  Created by Marcello Quarta on 25/09/2018.
//  Copyright © 2018 Marcello Quarta. All rights reserved.
//

import Cocoa

protocol DestinationViewDelegate {
    func processImageURLs(_ urls: [URL], center: NSPoint)
    func processImage(_ image: NSImage, center: NSPoint)
    func processAction(_ action: String, center: NSPoint)
}

class DropView: NSView {

    enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }
    
    var delegate: DestinationViewDelegate?
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    var acceptableTypes: Set<NSPasteboard.PasteboardType> { return [
        NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String)
        ] }
    
    func setup() {
        registerForDraggedTypes(Array(acceptableTypes))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = Appearance.lineWidth
            path.stroke()
        }
    }
    
    //we override hitTest so that this view which sits at the top of the view hierachy
    //appears transparent to mouse clicks
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
    
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]

    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard

        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        let point = convert(draggingInfo.draggingLocation, from: nil)
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.processImageURLs(urls, center: point)
            return true
        }
        return false
        
    }
    
}
