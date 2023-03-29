//
//  AboutUs.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-28.
//

import SwiftUI

struct AboutUs: View {
//    weak var navigationController: UINavigationController?
    var version = "App Version : " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
    var aboutUs = "About Us : "
    var aboutUsURL  = "https://www.freeprivacypolicy.com/live/5edf96ed-0b84-4fc0-955e-bc578ff82da4"
    var contactUs = " Contact Us : \n teamsundry@gmail.com"
    var privacy = "Privacy Policy :"
    var privacyURL =  "https://www.freeprivacypolicy.com/live/5edf96ed-0b84-4fc0-955e-bc578ff82da4"
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Image("AppIconImage").resizable().frame(width: 150 , height: 150, alignment: .center).padding(.top, 15)
                Text("BookIt").font(.system(size: 40.0)).bold().foregroundColor(Color(UIColor.appThemeColor)).padding(.bottom, 20)
                Text("Hi! we're TeamSundry").font(.system(size: 20.0)).foregroundColor(.gray)
                Text(version).font(.system(size: 20.0)).foregroundColor(.gray).padding(.bottom, 20)
                Text(contactUs).font(.system(size: 18.0))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(Color.white).padding(.bottom, 15).multilineTextAlignment(.center)
//                Text(aboutUs).font(.system(size: 18.0))
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray)
//                    .foregroundColor(Color.white).multilineTextAlignment(.center).padding(.bottom, 15)
                VStack(alignment: .center) {
                    Text(aboutUs).font(.system(size: 18.0))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center).padding(.top, 15)
                    Link(aboutUsURL, destination: URL(string: aboutUsURL)!)
                        .font(.system(size: 16.0)).underline(true, color: .white)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center).padding(.bottom, 15)
                }.background(Color.gray).frame(maxWidth: .infinity).padding(.bottom, 15)
                VStack(alignment: .center) {
                    Text(privacy).font(.system(size: 18.0))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center).padding(.top, 15)
                    Link(privacyURL, destination: URL(string: privacyURL)!)
                        .font(.system(size: 16.0)).underline(true, color: .white)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center).padding(.bottom, 15)
                }.background(Color.gray).frame(maxWidth: .infinity)
                
                Spacer()
            }
            .font(.title)
        }.navigationBarTitle(Text("About Us"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(false)
    }
}
struct AboutUs_Previews: PreviewProvider {
    static var previews: some View {
        AboutUs()
    }
}
