//
//  loadImageManager.swift
//  WheelImageView
//
//  Created by 汪俊 on 2016/12/29.
//  Copyright © 2016年 Codans. All rights reserved.
//

import UIKit

protocol managerDelegate {
   func loadImageManagerReloadImageArray(imageArray:[UIImage])
}

class loadImageManager:NSObject {
    var delegate : managerDelegate?
    
    private var loadUrlArray = [String]()
    private var loadImageArray = [UIImage]()
    private var copyImageArray = [UIImage]()
    private var placeHoldImage = UIImage()
    
    
    // 处理下载任务
    func downLoadImages(WithUrlArray:[String], placehold:UIImage) {
        loadUrlArray = WithUrlArray
        placeHoldImage = placehold
        for _ in loadUrlArray {
            loadImageArray.append(placeHoldImage)
        }
        reloadCopyImageArray()
        
        for (index,urlString) in loadUrlArray.enumerated() {
            DispatchQueue.global().async {
                var imageData = Data()
                do {
                    imageData = try Data(contentsOf: URL(string: urlString)!)
                }catch{
                    print(error)
                    return
                }
                if imageData.count == 0 {
                    print("图片加载失败-url:\(urlString)")
                    return
                }else{
                    DispatchQueue.main.async {
                        let loadImage = UIImage(data: imageData )
                        self.loadImageArray[index] = loadImage!
                        self.reloadCopyImageArray()
                    }
                }
            }
        }
    }
    
    // MARK: - 刷新本地拷贝数组
    func reloadCopyImageArray() {
        copyImageArray = loadImageArray
        if delegate != nil {
            delegate?.loadImageManagerReloadImageArray(imageArray: copyImageArray)
        }
    }
    
    
    

}
