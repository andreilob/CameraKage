//
//  UIView+LayoutToFill.swift
//  CameraKage
//
//  Created by Lobont Andrei on 21.05.2023.
//

import UIKit

extension UIView {
    func layoutToFill(inView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([topAnchor.constraint(equalTo: inView.topAnchor),
                                     leadingAnchor.constraint(equalTo: inView.leadingAnchor),
                                     bottomAnchor.constraint(equalTo: inView.bottomAnchor),
                                     trailingAnchor.constraint(equalTo: inView.trailingAnchor)])
    }
}
