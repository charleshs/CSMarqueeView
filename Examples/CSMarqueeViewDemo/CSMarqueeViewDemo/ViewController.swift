// ViewController.swift
// CSMarqueeViewDemo
// Copyright © 2020 Charles Hsieh. All rights reserved.

import UIKit
import CSMarqueeView

final class ViewController: UIViewController {
    @IBOutlet var topMarqueeView: CSMarqueeView!
    @IBOutlet var bottomMarqueeView: CSMarqueeView!

    override func viewDidLoad() {
        super.viewDidLoad()

        var labels = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."].map(makeLabel(text:))
        topMarqueeView.pointsPerSecond = 30
        topMarqueeView.spacing = 24
        topMarqueeView.contentViews = labels

        labels = ["Gravida", "Tristique", "Nisl", "Volutpat", "At erat"].map(makeLabel(text:))
        bottomMarqueeView.pointsPerSecond = 30
        bottomMarqueeView.direction = .right
        bottomMarqueeView.contentViews = labels
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        topMarqueeView.startMarquee()
        bottomMarqueeView.startMarquee()
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .darkText
        return label
    }
}
