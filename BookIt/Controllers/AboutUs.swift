//
//  AboutUs.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-28.
//

import SwiftUI

struct AboutUs: View {
    weak var navigationController: UINavigationController?
    var body: some View {
            VStack {
                HStack {
                    Text("BookIt")
                        .bold()
                        .font(.system(size: 21.0))
                }
                Spacer()
                    .frame(width: 1, height: 74, alignment: .bottom)
                VStack(alignment: .center){
                    Button(action: {
                        navigationController?.popViewController(animated: true)
                    }) {
                        Text("Navigate to Profile")
                            .font(.system(size: 21.0))
                            .bold()
                            .frame(width: UIScreen.main.bounds.width, height: 10, alignment: .center)
                    }
                }
                Spacer()
                    .frame(width: 2, height: 105, alignment: .bottom)
            }.navigationBarHidden(false)
        }
    }
struct AboutUs_Previews: PreviewProvider {
    static var previews: some View {
        AboutUs()
    }
}
