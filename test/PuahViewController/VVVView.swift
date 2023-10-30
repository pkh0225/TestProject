//
//  VVVView.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/30/23.
//

import UIKit

class VVVView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setup()
    }

    func setup() {
        self.backgroundColor = .red
    }
}
