//
//  SpeciesPhenologyCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import Charts

class SpeciesPhenologyCell: UITableViewCell {
    
    @IBOutlet var phenologyLabel: UILabel?
    @IBOutlet var lineChartView: LineChartView?
    @IBOutlet var chartBackground: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        chartBackground?.backgroundColor = UIColor.INat.SpeciesPhenlogyBackground
        chartBackground?.layer.cornerRadius = 5.0
        chartBackground?.clipsToBounds = true
        
        lineChartView?.isUserInteractionEnabled = false
        
    }


    func displayChartDataSet(_ chartDataSet: LineChartDataSet, max: Int) {
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.2
        chartDataSet.colors = [UIColor.white]
        chartDataSet.lineWidth = 3.0
        
        // gradient fill
        let gradientColors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor] as CFArray
        let colorLocations: [CGFloat] = [1.0, 0.3, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient.init(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations) {
            chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
            chartDataSet.drawFilledEnabled = true
        }
        
        lineChartView?.xAxis.labelPosition = .bottom
        lineChartView?.xAxis.drawGridLinesEnabled = false
        lineChartView?.xAxis.labelTextColor = UIColor.white
        if let font = UIFont(name: "Whitney-Book", size: 12) {
            lineChartView?.xAxis.labelFont = font
        }
        lineChartView?.xAxis.axisLineColor = UIColor.white
        
        lineChartView?.chartDescription?.enabled = false
        lineChartView?.legend.enabled = false
        lineChartView?.rightAxis.enabled = false
        
        lineChartView?.leftAxis.enabled = true
        lineChartView?.leftAxis.drawGridLinesEnabled = false
        lineChartView?.leftAxis.axisMinimum = 0
        lineChartView?.leftAxis.axisMaximum = Double(max) * 1.1
        lineChartView?.leftAxis.axisLineColor = UIColor.white
        lineChartView?.leftAxis.labelTextColor = UIColor.white
        if let font = UIFont(name: "Whitney-Book", size: 12) {
            lineChartView?.leftAxis.labelFont = font
        }
        
        let xAxisLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        lineChartView?.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        lineChartView?.data = chartData

    }
}
