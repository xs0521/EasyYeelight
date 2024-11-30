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
        "tap device \(device.host)".p()
        Socket.shared.connect(device)
    }
    @Published var colorTapAction: GeneralCallBack<Device> = { device in
        "tap color device \(device.host)".p()
        YeeLightManager.shared.model?.showColorPick = !(YeeLightManager.shared.model?.showColorPick ?? true)
    }
    @Published var temperatureTapAction: GeneralCallBack<Device> = { device in
        "tap color device \(device.host)".p()
        YeeLightManager.shared.model?.showTemperaturePick = !(YeeLightManager.shared.model?.showTemperaturePick ?? true)
        let ct: Double = Double(YeeLightManager.shared.model?.curItem?.ct ?? Int(Device.kMaxColorTemp))
        YeeLightManager.shared.model?.tempProgress = ct
    }
    @Published var higIp = ""
    @Published var showColorPick: Bool = false
    @Published var showTemperaturePick: Bool = false
    @Published var currentColor = Color.red
    @Published var progress = 120.0
    @Published var tempProgress = 1700.0
    @Published var curItem: Device?
}

struct MainView: View {
    
    @StateObject var model = YeeLightModel()
    
    var body: some View {
        ZStack {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (spacing: 10) {
                    ForEach ($model.items){ $item in
                        MainCellContainerView(item: $item, tapActionCallBack: $model.tapAction, colorActionCallBack: $model.colorTapAction, temperatureActionCallBack: $model.temperatureTapAction, higIp: $model.higIp)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            if model.showColorPick {
                ZStack {
                    CircularSliderView(value: $model.progress, in: 0...360) { _ in
                        guard let item = YeeLightManager.shared.model?.curItem else { return }
                        Socket.shared.changeColor(item, Int(model.progress))
                    }
                    .frame(width: 100, height: model.items.count <= 1 ? 80 : 100)
                }
                .frame(width: 500, height: max(CGFloat(min($model.items.count, 4) * 70) + 10, 80))
                .background(Color.init(hex: "#323232"))
                .onTapGesture {
                    YeeLightManager.shared.model?.showColorPick = !(YeeLightManager.shared.model?.showColorPick ?? true)
                }
            }
            
            if model.showTemperaturePick {
                ZStack {
                    VStack (spacing: 1) {
                        Text("\(Int(model.tempProgress))")
                            .foregroundStyle(Color.white)
                        Slider(value: $model.tempProgress, in: Device.kMinColorTemp ... Device.kMaxColorTemp, label: {
                                        Image(systemName: "thermometer.transmission")
                                                .foregroundStyle(Color.white)
                        }) { value in
                            if value == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                    guard let item = YeeLightManager.shared.model?.curItem else { return }
                                    Socket.shared.changeTemperature(item, Int(model.tempProgress))
                                    YeeLightManager.shared.model?.curItem?.ct = Int(model.tempProgress)
                                })
                            }
                        }
                        .tint(Color.white)
                        .frame(width: 400, height: 30)
//                        .background(Color.red)
                    }
                    .frame(width: 500, height: model.items.count <= 1 ? 80 : 100)
                }
                .frame(width: 500, height: max(CGFloat(min($model.items.count, 4) * 70) + 10, 80))
                .background(Color.init(hex: "#323232"))
                .onTapGesture {
                    YeeLightManager.shared.model?.showTemperaturePick = !(YeeLightManager.shared.model?.showTemperaturePick ?? true)
                }
            }
            if model.items.isEmpty {
                Text("loading...")
            }
        }
        ///cell height 60 space 10
        .frame(width: 500, height: max(CGFloat(min($model.items.count, 4) * 70) + 10, 80))
        .background(Color.init(hex: "323232"))
        .onAppear{
            socketCallBack()
            request()
            YeeLightManager.shared.model = model
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
//                model.items = [devices.first!]
                if let device = devices.first {
                    Socket.shared.connect(device)
                }
            }
            
        }
    }
    
    func socketCallBack() -> Void {
        
        Socket.shared.socketDidConnectCallBack = { (host) in
            let device = model.items.first { device in
                return device.host == host
            }
            guard let device = device else { return }
            higItem(device)
            YeeLightManager.shared.model?.curItem = device
        }
    }
    
    func higItem(_ item: Device) -> Void {
        model.higIp = item.host
    }
}

extension MainView {
    
    static func autoReConnect() -> Void {
        Socket.shared.autoReConnect()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
