//
//  BaseNavViewController.swift
//  CloudscmSwift
//
//  Created by Darren on 17/5/2.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

class CLBaseImagePickerViewController: UIViewController {
    
    // 自定义导航栏
    @objc lazy var customNavBar: CustomNavgationView = {
        let nav = CustomNavgationView()
        nav.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KNavgationBarHeight)
        return nav
    }()
    // 右边第一个按钮
    @objc lazy var rightBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: KScreenWidth-64, y: 20, width: 64, height: 44);
        btn.adjustsImageWhenHighlighted = false
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(CLBaseImagePickerViewController.rightBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    // 标题
    @objc var navTitle = "" {
        didSet{
            customNavBar.titleLable.text = navTitle
        }
    }
    // 返回按钮
    @objc lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 20, width: 50, height: 44);
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        btn.setImage(UIImage(named: "btn_back2", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for:UIControlState())
        btn.addTarget(self, action: #selector(CLBaseImagePickerViewController.backBtnclick), for: .touchUpInside)
        return btn
    }()
    
    @objc lazy var toobar: UIToolbar = {
        // 添加磨玻璃
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KNavgationBarHeight))
        toolBar.barStyle = .default
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.setupNav()
    }
    
    // 先不要写在initview中，因为如果写在initview中就需要在子类中必须实现initView方法，并且调用super.initView()
    fileprivate func setupNav(){
        // 添加导航栏
        self.view.addSubview(self.customNavBar)
        // 右边按钮
        self.customNavBar.addSubview(self.rightBtn)
        
        // 毛玻璃效果
        self.customNavBar.addSubview(self.toobar)
        self.customNavBar.sendSubview(toBack: self.toobar)
        
        self.customNavBar.addSubview(self.backBtn)
        self.backBtn.isHidden = true
        
        // 设置位置，适配iphonex
        let titleY: CGFloat = UIDevice.current.isX() == true ? 40:20
        self.rightBtn.cl_y = titleY
        self.backBtn.cl_y = titleY
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CLPickersTools.instence.navColor == nil {
            self.toobar.isHidden = false
            self.customNavBar.backgroundColor = UIColor.clear
        } else {
            self.customNavBar.backgroundColor = CLPickersTools.instence.navColor
            self.toobar.isHidden = true
        }
        
        if CLPickersTools.instence.navTitleColor != nil {
            self.backBtn.imageView?.tintColor = CLPickersTools.instence.navTitleColor
            let img = self.backBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            self.backBtn.setImage(img, for: .normal)
            
            self.customNavBar.titleLable.textColor = CLPickersTools.instence.navTitleColor
            self.rightBtn.setTitleColor(CLPickersTools.instence.navTitleColor, for: .normal)
        } else {
            self.backBtn.imageView?.tintColor = UIColor.black
            let img = self.backBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            self.backBtn.setImage(img, for: .normal)
            
            self.customNavBar.titleLable.textColor = UIColor.black
            self.rightBtn.setTitleColor(UIColor.black, for: .normal)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if  CLPickersTools.instence.statusBarType == .black {
            return .default
        }
        return .lightContent
    }
    @objc func rightBtnClick(){
        
    }
    @objc func backBtnclick(){
        
    }
}

