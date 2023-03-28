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
        ZStack {
                VStack(spacing: 25) {
                    Image(systemName: "AppIconImage").font(.largeTitle)
                    Text("BookIt").font(.largeTitle).bold().foregroundColor(Color(UIColor.appThemeColor))
                    Text("Hi we're TeamSundry").font(.system(size: 21.0)).foregroundColor(.gray)
                    Text("Contact Us").font(.system(size: 21.0))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray)
                                        .foregroundColor(Color.white)
                                    
                                    Spacer()
                                }
                                .font(.title)
                                .padding(.top, 10)
//                Spacer()
//                    .frame(width: 1, height: 74, alignment: .top)
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
            }.navigationBarTitle(Text("About Us"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            // Hide the system back button
            .navigationBarBackButtonHidden(true)
        }
    }
struct AboutUs_Previews: PreviewProvider {
    static var previews: some View {
        AboutUs()
    }
}
