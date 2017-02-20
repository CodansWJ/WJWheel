//
//  ViewController.swift
//  demo-wheel
//
//  Created by 汪俊 on 2016/12/30.
//  Copyright © 2016年 Codans. All rights reserved.
//

import UIKit
let WIDTH = UIScreen.main.bounds.size.width
let HEIGHT = UIScreen.main.bounds.size.height


class ViewController: UIViewController, WheelImageViewDelegate {
    
    var imageURL = ["https://ossweb-img.qq.com/upload/qqtalk/news/201612/162008545314673_480.jpg", "https://ossweb-img.qq.com/upload/qqtalk/news/201612/191140058588366_480.jpg", "https://ossweb-img.qq.com/upload/qqtalk/news/201612/211745006255650_480.jpg", "https://ossweb-img.qq.com/upload/qqtalk/news/201612/26181556688493_480.jpg"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let myView = WheelImageView(frame: CGRect(x: 10, y: 50, width: WIDTH - 20, height: 200), imageUrlArray: imageURL, placehold:nil, frequency:2)
        myView.delegate = self
        self.view.addSubview(myView)
    }

    func wheelImageViewDidSelected(index: Int) {
        print("点了图片：\(index)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

