//
//  AlarmPulleyContainerViewController.swift
//  Safelet
//
//  Created by Alexandru Motoc on 21/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

import UIKit
import Pulley
import Foundation

@objc public class AlarmPulleyContainerViewController: PulleyViewController {
    var alarmActionsVC: AlarmActionsViewController!
    var alarmVC: AlarmViewController!
    var isControllerLoaded = false
    
// MARK: - viewcontroller lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDrawer()
    }
    
    @objc required public init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        setupDrawer()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let alarmActionsVC = alarmActionsVC, let drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView {
            drawerBackgroundVisualEffectView.frame.size.height -= alarmActionsVC.blurViewYPos
            drawerBackgroundVisualEffectView.frame.origin.y += alarmActionsVC.blurViewYPos
        }
    }

    
    public override func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        if progress <= 0.8 { alarmActionsVC.view.endEditing(true) }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if drawerContentViewController is AlarmActionsViewController {
            alarmActionsVC = drawerContentViewController as! AlarmActionsViewController
            alarmActionsVC.actionsDelegate = self
            
            if let objId1 = alarmActionsVC.alarm.objectId, let objId2 = SLAlarmManager.shared().alarm?.objectId {
                if objId1 == objId2 {
                    alarmActionsVC.hideAlarmActionButtons()
                }
            }
        }
        
        if primaryContentViewController is AlarmViewController {
            alarmVC = primaryContentViewController as! AlarmViewController
        }
        
        isControllerLoaded = true
    }
    
// MARK: - Logic
    
    func setupDrawer() {
//        topInset = 20
        backgroundDimmingOpacity = 0
        shadowOpacity = 0
        initialDrawerPosition = .collapsed
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(alarmChatControllerDidLoadExistingMessages(_:)),
                                               name: Notification.Name(SLAlarmChatHasContentNotification),
                                               object: nil)
    }
    
    @objc public func alarmChatControllerDidLoadExistingMessages(_ notification: Notification) {
        if isControllerLoaded && drawerPosition != .open && drawerPosition != .partiallyRevealed {
            setDrawerPosition(position: .partiallyRevealed)
        } else {
            initialDrawerPosition = .partiallyRevealed
        }
    }
}

// MARK: - PulleyDrawerViewControllerDelegate
// implement the delegate here because in the objc file we cant conform to PulleyDrawerViewControllerDelegate
// this happens because PulleyDrawerViewControllerDelegate is implemented without @objc directives and we can't "see" it
extension AlarmActionsViewController: PulleyDrawerViewControllerDelegate {
    public func collapsedDrawerHeight() -> CGFloat {
        return collapsedHeight
    }
    
    public func partialRevealDrawerHeight() -> CGFloat {
        return 0.5 * UIScreen.main.bounds.height // 40% of the screen
    }
    
    public func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed, .open]
    }
}

extension AlarmPulleyContainerViewController {
    public func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat) {
        alarmActionsVC.view.endEditing(true)
    }
}

// MARK: - AlarmActionsDelegate

extension AlarmPulleyContainerViewController: AlarmActionsDelegate {
    public func alarmActionsControllerDidSelectJoinAlarm(_ controller: AlarmActionsViewController!) {
        alarmVC.handleUserJoinAlarmAction { success in
            if success == true {
                controller.disableJoinAlarmButton()
            }
        }
    }
    
    public func alarmActionsControllerDidSelectPlayRecording(_ controller: AlarmActionsViewController!) {
        alarmVC.handleUserPlayAlarmAction { isPlaying in
            controller.updatePlayAudioButton(isPlaying)
        }
    }
    
    public func alarmActionsControllerDidSelectCallEmergency(_ controller: AlarmActionsViewController!) {
        alarmVC.handleUserCallEmergencyAction()
    }
    
    public func alarmActionsControllerDidSelectShowChat(_ controller: AlarmActionsViewController!) {
        setDrawerPosition(position: .open)
    }
}
