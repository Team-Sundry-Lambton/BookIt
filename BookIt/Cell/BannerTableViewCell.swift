//
//  BannerTableViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-11.
//

import UIKit
import SnapKit

class BannerTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let identifier = "bannerCell"
    let fullSize = UIScreen.main.bounds
    var bannerViews: [UIImageView] {
        var bannerView = [UIImageView]()
        for i in 0...9 {
            let imageView = UIImageView(image: UIImage(named: "\(i)"))
            imageView.frame = CGRect(x: fullSize.width * CGFloat(i), y: 0, width: fullSize.width, height: 240)
            bannerView.append(imageView)
            print(bannerView[i].frame)
        }
        return bannerView
    }
    
    //MARK: - IBOutlets
    
    lazy var myScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentSize = CGSize(width: Int(fullSize.width) * bannerViews.count, height: 240)
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        for banner in bannerViews {
            sv.addSubview(banner)
        }
        return sv
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.backgroundColor = .clear
        pc.currentPageIndicatorTintColor = UIColor.appThemeColor
        pc.pageIndicatorTintColor = .white
        pc.numberOfPages = bannerViews.count
        pc.currentPage = 0
        pc.isUserInteractionEnabled = true
        return pc
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setSubviews()
        setLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Add Subviews
    
    func setSubviews() {
        contentView.addSubview(myScrollView)
        contentView.addSubview(pageControl)
    }
    
    //MARK: - Set Layouts

    func setLayouts() {
        
        myScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom).offset(-10)
            make.height.equalTo(10)
            make.centerX.width.equalTo(self)
        }
        
    }
    
}
