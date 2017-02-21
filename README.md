# WJWheel
####轻量级无限循环重用机制的轮播

##使用方法
1.初始化WheelImageView
使用本地图片:

```
init(frame: CGRect, imageArray:[UIImage], frequency:CGFloat)
```
使用网络图片：
```
init(frame: CGRect, imageUrlArray:[String], placehold:UIImage?, frequency:CGFloat)
```
2.遵守代理和代理方法
WheelImageViewDelegate
```
func wheelImageViewDidSelected(index: Int) {
        print("点了图片：\(index)")
    }
 ```
 
 
