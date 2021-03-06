//
//  RatingBar.swift
//  BaseProject
//
//  Created by 小二黑挖土 on 2018/5/3.
//  Copyright © 2018年 Lemon. All rights reserved.
//

import UIKit

class RatingBar: UIView {
    //星星个数,默认为5
    var starNumber:Int = 5
    //星星之间的间距，默认为5
    var starMagin:CGFloat = 5.0
    //只读的，手势无效
    var readable:Bool = false
    
    private let backStarView = UIView()
    private let frontStarView = UIView()
    private lazy var frameShapeLayer:CAShapeLayer = {
        let shapelayer = CAShapeLayer()
        let path = UIBezierPath(rect: CGRect.zero)
        shapelayer.path = path.cgPath
        return shapelayer
    }()
    private var drawn:Bool = false
    //评分值
    private var value:Float = 0
    //星星的分段区间
    private var segements:Array<(CGFloat,CGFloat)> = []
    private var starWid:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialViews()
    }
    
    func initialViews() {
        self.addSubview(backStarView)
        self.addSubview(frontStarView)
        //通过添加遮罩来显示上层星星数量
        frontStarView.layer.mask = frameShapeLayer
        //如果未引入snapKit，可在layoutSubview中设置frame
        backStarView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        frontStarView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        //添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(gesture:)))
        self.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !drawn {//只添加一次
            starWid = floor((self.frame.size.width-starMagin*(CGFloat)(starNumber-1))/(CGFloat)(starNumber))
            let starHeight = min(starWid, self.frame.size.height)
            let darkStar = UIImage(named: "ic_ratingbar_star_dark")
            let lightStar = UIImage(named: "ic_ratingbar_star_light")
            for i in 0..<starNumber {
                let darkImgView = UIImageView(frame: CGRect(x: (starWid+starMagin)*(CGFloat)(i), y: 0, width: starWid, height: starHeight))
                darkImgView.image = darkStar
                darkImgView.contentMode = .scaleAspectFit
                backStarView.addSubview(darkImgView)
                
                let lightImgView = UIImageView(frame: CGRect(x: (starWid+starMagin)*(CGFloat)(i), y: 0, width: starWid, height: starHeight))
                lightImgView.image = lightStar
                lightImgView.contentMode = .scaleAspectFit
                frontStarView.addSubview(lightImgView)
            }
            drawn = true
            //初始化分段区间
            for i in 0..<starNumber {
                let minX = (starWid+starMagin)*CGFloat(i)
                let maxX = minX+starWid
                segements.append((minX,maxX))
            }
        }
        if readable {
            if value < 0 || value > Float(starNumber) {return}
            let intValue = Int(value)
            let dotValue = value - Float(intValue)
            var ptx:CGFloat = 0
            if intValue == starNumber {
                ptx = segements[starNumber-1].1
            }else {
                ptx = segements[intValue].0+starWid*CGFloat(dotValue)
            }
            //构造路径
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: ptx, y: 0))
            path.addLine(to: CGPoint(x: ptx, y: self.frame.size.height))
            path.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
            path.close()
            self.frameShapeLayer.path = path.cgPath
        }
    }
    
    @objc func tapAction(gesture:UITapGestureRecognizer) {
        if readable {return}
        let pt = gesture.location(in: self)
        //构造路径
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: pt.x, y: 0))
        path.addLine(to: CGPoint(x: pt.x, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
        path.close()
        self.frameShapeLayer.path = path.cgPath
        //计算评分
        for i in 0..<starNumber {
            let (a,b) = segements[i]
            if pt.x > b {continue}
            value = Float(i)//整数位
            if pt.x > a {
                let dot = (pt.x-a)/starWid//小数位
                value += Float(dot)
            }
//            print("i == \(i),dot == \(value-Float(i)),value == \(value)")
            break
        }
    }
    
    func getValue()->Float {
        return value
    }
    //通过评分来显示星星
    func setRatingValue(value:Float) {
        self.value = value
        self.setNeedsLayout()
    }
}
