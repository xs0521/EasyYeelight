//
//  ContentView.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/18.
//

import SwiftUI

//struct YeeLight: Identifiable {
//    var id = UUID()
//    var ip: String
//    var bright: Float
//    var isOn: Bool
//}

class YeeLightModel: ObservableObject {
    
    @Published var items: [Device] = []
    @Published var tapAction: GeneralCallBack<Device> = { device in
        "tap device \(device.ip)".p()
        Socket.shared.connect(device)
    }
    @Published var higIp = ""
}

struct MainView: View {
    
    @StateObject var model = YeeLightModel()
    
    var body: some View {
        ZStack {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (spacing: 10) {
                    ForEach ($model.items){ $item in
                        MainCellContainerView(item: $item, tapActionCallBack: $model.tapAction, higIp: $model.higIp)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            if model.items.isEmpty {
                Text("loading...")
            }
        }
        ///cell height 60 space 10
        .frame(width: 500, height: max(CGFloat(min($model.items.count, 4) * 70) + 10, 80))
        .onAppear{
            socketCallBack()
            request()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.reload)) { _ in
            request()
        }
    }
    
}


extension MainView {
    
    func request() -> Void {
        
        DispatchQueue.global().async{
            Socket.shared.reset()
            Socket.shared.config()
            Socket.shared.searchDevice { (devices) in
                model.items = devices
                if let device = devices.first {
                    Socket.shared.connect(device)
                }
            }
            
        }
    }
    
    func socketCallBack() -> Void {
        
        Socket.shared.socketDidConnectCallBack = { (host) in
            let device = model.items.first { device in
                return device.ip == host
            }
            guard let device = device else { return }
            higItem(device)
        }
    }
    
    func higItem(_ item: Device) -> Void {
        model.higIp = item.ip
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
