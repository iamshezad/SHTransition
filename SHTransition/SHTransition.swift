//
//  SHTransitionAnimation.swift
//  SHTransitionUI
//
//  Created by Focaloid Technologies on 17/08/17.
//  Copyright © 2017 Focaloid Technologies. All rights reserved.
//

import Foundation
import UIKit

private var fromViews = [UIView]()
private var toViews = [UIView]()
private var toFrame : CGRect?
private var fromFrame : CGRect?
private var fTag : Int?
private var tTag : Int?
private var tagArray = [[Int]]()
private var frameArray = [[CGRect]]()
private var isTransition : Bool?
private var transitionDelay : Float = 1
private var vcArray = [[String:Any]]()
private var delay : Float = 1
private let customPresentAnimationController = SHCustomPresentAnimationTransition()
extension UIView {
    
    /** This is the function to get subViews of a view of a particular type
     */
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        var count = 0
        func getSubview(view: UIView) {
            if let aView = view as? T{
                view.tag = count
                all.append(aView)
                count += 1
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
    
    @IBInspectable var SHID: String {
        get {
            return self.accessibilityIdentifier!
        }
        set {
           self.accessibilityIdentifier = newValue
        }
    }
}

extension UIViewController:UINavigationControllerDelegate,UIViewControllerTransitioningDelegate{
    
    
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers{
            let n = controllersOnNavStack.count
            //if self is still on Navigation stack
            if controllersOnNavStack.last === self, n > 1{
                return controllersOnNavStack[n - 2]
            }else if n > 0{
                return controllersOnNavStack[n - 1]
            }
        }
        return nil
    }

    @IBInspectable var transitionTime: Float {
        get {
            return transitionDelay
        }
        set {
            transitionDelay = newValue
            setVC()
        }
    }
    
    @IBInspectable public var SHTransition: Bool {
        get { return isTransition! }
        set {
            if newValue == true{
                isTransition = newValue
            }else {
                isTransition = false
        
            }
        }
    }
    func setVC() {
        self.navigationController?.delegate = self
        var flag = 0
        for item in vcArray {
            if item["VC"] as? String == self.nibName {
                flag = 1
            }
        }
        if flag == 0 {
            vcArray.append(["VC":self.nibName!,"isTransition":self.SHTransition,"transitionDelay":self.transitionTime])
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            for item in vcArray {
                if item["VC"] as? String == toVC.nibName {
                    if item["isTransition"] as? Bool == true {
                        delay = item["transitionDelay"] as! Float
                        let toViewController = toVC as UIViewController
                        toViews = (toViewController.view.allSubViewsOf(type: UIView.self))
                        let fromViewController = fromVC as UIViewController
                        fromViews = (fromViewController.view.allSubViewsOf(type: UIView.self))
                        applyTransition(fromViewController: fromVC, toViewController: toVC)
                        toVC.view.isUserInteractionEnabled = false
                        fromVC.view.isUserInteractionEnabled = false
                        return customPresentAnimationController
                        
                    }else {
                        return nil
                    }
                }
            }
        }
       
        if toVC.SHTransition == true {
            delay = toVC.transitionTime
            let toViewController = toVC as UIViewController
            toViews = (toViewController.view.allSubViewsOf(type: UIView.self))
            let fromViewController = fromVC as UIViewController
            fromViews = (fromViewController.view.allSubViewsOf(type: UIView.self))
            applyTransition(fromViewController: fromVC, toViewController: toVC)
            toVC.view.isUserInteractionEnabled = false
            fromVC.view.isUserInteractionEnabled = false
            return customPresentAnimationController

        }else {
            return nil
        }
        
    }

    
    func applyTransition(fromViewController:UIViewController,toViewController:UIViewController){
        
        for fViews in fromViews {
            for TViews in toViews {
                if TViews.accessibilityIdentifier != nil && fViews.accessibilityIdentifier != nil {
                if fViews.accessibilityIdentifier == TViews.accessibilityIdentifier{
                    
                    for views in (fromViewController.view.subviews){
                        if views.accessibilityIdentifier == TViews.accessibilityIdentifier && views.accessibilityIdentifier == fViews.accessibilityIdentifier {
                            fTag = views.tag
                            fromFrame = views.frame
                        }
                    }
                    for views in (toViewController.view.subviews){
                        if views.accessibilityIdentifier == TViews.accessibilityIdentifier && views.accessibilityIdentifier == fViews.accessibilityIdentifier {
                            tTag = views.tag
                            toFrame = views.frame
                        }
                    }
                    tagArray.append([fTag!,tTag!])
                    frameArray.append([fromFrame!,toFrame!])
                    for index in 0..<tagArray.count{
                        if tagArray[index][0] == fViews.tag && tagArray[index][1] == TViews.tag {
                            for viewIndex in 0..<(toViewController.view.subviews.count) {
                                if toViewController.view.subviews[viewIndex].tag == tagArray[index][1]
                                {
                                     toViewController.view.subviews[viewIndex].frame = (frameArray[index][0])
                                }
                            }
                        }
                    }
                   
                }
            }
            }
        }
       let tagCount = tagArray.count
        
        UIView.animate(withDuration: TimeInterval(delay), animations: {

            for fViews in fromViews {
                for TViews in toViews {
                    if TViews.accessibilityIdentifier != nil && fViews.accessibilityIdentifier != nil {
                        if fViews.accessibilityIdentifier == TViews.accessibilityIdentifier{
                            for index in 0..<tagCount{
                                if tagArray[index][0] == fViews.tag && tagArray[index][1] == TViews.tag {
                                    for viewIndex in 0..<(toViewController.view.subviews.count) {
                                        if toViewController.view.subviews[viewIndex].tag == tagArray[index][1]
                                        {
                                            toViewController.view.subviews[viewIndex].frame = (frameArray[index][1])
                                        }
                                    }
                                    for viewIndex in 0..<(fromViewController.view.subviews.count) {
                                        if fromViewController.view.subviews[viewIndex].tag == tagArray[index][0]
                                        {
                                            fromViewController.view.subviews[viewIndex].frame = (frameArray[index][1])
                                        }
                                    }
                                }
                            }
                           
                        }
                    }
                }
            }
           
        }, completion: {
            finished in
            for fViews in fromViews {
                for TViews in toViews {
                    if TViews.accessibilityIdentifier != nil && fViews.accessibilityIdentifier != nil {
                        if fViews.accessibilityIdentifier == TViews.accessibilityIdentifier{
                            for index in 0..<tagCount{
                                if tagArray[index][0] == fViews.tag && tagArray[index][1] == TViews.tag {
                                    for viewIndex in 0..<(fromViewController.view.subviews.count) {
                                        if fromViewController.view.subviews[viewIndex].tag == tagArray[index][0]
                                        {
                                            fromViewController.view.subviews[viewIndex].frame = (frameArray[index][0])
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            fromViewController.view.isUserInteractionEnabled = true
            toViewController.view.isUserInteractionEnabled = true
            tagArray = [[Int]]()
            frameArray = [[CGRect]]()
            
        })
    }

}

class SHCustomPresentAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewcontroller = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewcontroller = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewcontroller)
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewcontroller.view)
        //toViewController.view.alpha = 0.0
        UIView.animate(withDuration: TimeInterval(delay), animations: {
            //fromViewController.view.alpha = 0.5
            toViewcontroller.view.frame = finalFrameForVC
            //toViewController.view.alpha = 1.0
            
        }, completion: {
            finished in
            transitionContext.completeTransition(true)
            fromViewcontroller.view.alpha = 1.0
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        })
    }
    
}
