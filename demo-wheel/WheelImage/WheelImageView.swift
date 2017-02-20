//
//  WheelImageView.swift
//  WheelImageView
//
//  Created by 汪俊 on 2016/12/28.
//  Copyright © 2016年 Codans. All rights reserved.
//

import UIKit


@objc protocol WheelImageViewDelegate {
    @objc optional func wheelImageViewDidSelected(index:Int)
}


enum Distance {
    case right
    case left
}

enum TimerStatus {
    case run
    case stop
}

class WheelImageView: UIView {
    var delegate:WheelImageViewDelegate?
    
    private var imageManager = loadImageManager()               // 网络图片本地缓存管理对象
    var mainScrollerView = UIScrollView()                       // 总的滑动View
    var mainLongView = UIView()                                 // 3个imageView下的长View
    var pageVT = UIPageControl()                                // 指示点
    var View_Width:CGFloat = 0                                  // 自身宽度
    var View_height:CGFloat = 0                                 // 自身高度
    var imageViewArray = [UIImageView]()                        // 3个用于展示的imageView数组
    var imageArray:[UIImage] = [UIImage]()                      // 用于展示的图片数组
    var imageUrlArray = [String]()                              // 网络图片urlString数组
    var imageLoadType:Int = 0                                   // 图片加载的形式: 0-本地加载  1-网络加载
    var imageIndex:Int = 0                                      // 标记现在所显示的下标
    var lastImageIndex:Int!
    var nextImageIndex:Int!
    
    
    var timer:Timer!                                            // 定时器
    var timerFrequency:CGFloat = 3                              // 定时时间
    

    /**
     *  滑动方向：默认右划
     */
    var scrollDistance:Distance = Distance.right
    
    
    /**
     *  定时器默认开启
     */
    var scrollStatus:TimerStatus = TimerStatus.run {
        didSet {
            if scrollStatus == .run {
                creatAutoTimer()
            }else{
                removeTimer()
            }
        }
    }
    
    
    
    
    init(frame: CGRect, imageUrlArray:[String], placehold:UIImage?, frequency:CGFloat) {
        super.init(frame: frame)
        imageManager.delegate = self
        self.imageUrlArray = imageUrlArray
        var placeholdImage = UIImage()
        if placehold == nil {
            placeholdImage = #imageLiteral(resourceName: "wheelImagePlaceHold.png")
        }
        imageManager.downLoadImages(WithUrlArray: imageUrlArray, placehold: placeholdImage)
        imageLoadType = 1
        timerFrequency = frequency
        initAction()
    }
    
    init(frame: CGRect, imageArray:[UIImage], frequency:CGFloat) {
        super.init(frame: frame)
        self.imageArray = imageArray
        imageLoadType = 0
        timerFrequency = frequency
        initAction()
    }
    
    func initAction() {
        View_Width = frame.size.width
        View_height = frame.size.height
        mainScrollerView.delegate = self
        creatView()
        creatAutoTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension WheelImageView:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == View_Width*2 {
            scrollView.contentOffset.x = View_Width
            resetImages(isRight: true)
        }else if scrollView.contentOffset.x == 0 {
            scrollView.contentOffset.x = View_Width
            resetImages(isRight: false)
        }else{
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if timer != nil {
           removeTimer()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if timer == nil {
            creatAutoTimer()
        }
    }
    
    func beTouches() {
        if self.delegate != nil {
            self.delegate?.wheelImageViewDidSelected!(index: imageIndex + 1)
        }
    }

    // MARK: - 重新设置图片
    func resetImages(isRight:Bool) {
        
        imageIndex = isRight ? imageIndex + 1 : imageIndex - 1
        
        if imageIndex <= -1 {
            imageIndex = imageArray.count - 1
        }else if imageIndex >= imageArray.count {
            imageIndex = 0
        }
        

        lastImageIndex = imageIndex - 1 < 0 ? imageArray.count - 1 : imageIndex - 1

        nextImageIndex = imageIndex + 1 > imageArray.count - 1 ? 0 : imageIndex + 1

        imageViewArray[0].image = imageArray[lastImageIndex]
        imageViewArray[1].image = imageArray[imageIndex]
        imageViewArray[2].image = imageArray[nextImageIndex]

        pageVT.currentPage = imageIndex
    }
}

extension WheelImageView {
    // MARK: - 创建页面
    func creatView() {
        mainLongView.frame = CGRect(x: 0, y: 0, width: View_Width*3, height: View_height)
        mainScrollerView.frame = CGRect(x: 0, y: 0, width: View_Width, height: View_height)
        mainScrollerView.contentSize = CGSize(width: mainLongView.bounds.size.width, height: 0)
        mainScrollerView.contentOffset.x = View_Width
        mainScrollerView.isPagingEnabled = true
        mainScrollerView.bounces = false
        mainScrollerView.showsVerticalScrollIndicator = false
        mainScrollerView.showsHorizontalScrollIndicator = false
        
        let tag = UITapGestureRecognizer(target: self, action: #selector(beTouches))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tag)
        
        
        pageVT.frame = CGRect(x: 0, y: View_height - 20, width: View_Width, height: 20)
        pageVT.numberOfPages = imageArray.count
        pageVT.pageIndicatorTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        pageVT.currentPageIndicatorTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        pageVT.currentPage = imageIndex
        
        for i in 0..<3 {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i)*View_Width, y: 0, width: View_Width, height: View_height))
            imageView.image = imageArray[i]
            imageViewArray.append(imageView)
            mainLongView.addSubview(imageView)
        }
        mainScrollerView.addSubview(mainLongView)
       
        self.addSubview(mainScrollerView)
        self.addSubview(pageVT)
    }
    
    // MARK: - 创建定时器
    func creatAutoTimer() {
        timer = Timer(timeInterval: TimeInterval(timerFrequency), target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
   // MARK: - 移除定时器
    func removeTimer() {
        timer.invalidate()
        timer = nil
    }
    
    func updateTimer(timer:Timer) {
        switch scrollDistance {
        case .left:
            self.mainScrollerView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        default:
            self.mainScrollerView.setContentOffset(CGPoint(x: View_Width*2, y: 0), animated: true)
        }
    }
    
    
}

extension WheelImageView:managerDelegate {
    func loadImageManagerReloadImageArray(imageArray: [UIImage]) {
        self.imageArray = imageArray
    }
}


