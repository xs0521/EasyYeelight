//
//  MainCellContainerView.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/19.
//

import SwiftUI
import Combine

struct MainCellContainerView: View {
    
    @Binding var item: Device
    @Binding var tapActionCallBack: GeneralCallBack<Device>
    @Binding var colorActionCallBack: GeneralCallBack<Device>
    @Binding var temperatureActionCallBack: GeneralCallBack<Device>
    @Binding var higIp: String
    
    @State var editName: String = ""
    @State var enbleEditName: Bool = false
    
    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                HStack {
                    Image(systemName: "network")
                        .foregroundStyle(Color.theme([Color.white, Color.black])!)
                        .opacity(higIp == item.host ? 1.0 : 0.5)
                    if enbleEditName && higIp == item.host ? true : false {
                        ZStack {
                            if editName.isEmpty {
                                HStack {
                                    Text("empty is the default")
                                        .foregroundStyle(Color.theme([Color.white, Color.black])!)
                                        .opacity(0.6)
                                    Spacer()
                                }
                            }
                            TextField("", text: $editName)
                                .textFieldStyle(.plain)
                                .foregroundStyle(Color.theme([Color.white, Color.black])!)
                        }
                        .frame(width: 150)
                        Button {
                            enbleEditName = !enbleEditName
                            UserDefaults.set(editName, forKey: item.id)
                            item.update()
                        } label: {
                            Image(systemName: "location.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.theme([Color.white, Color.black])!)
                                .opacity(higIp == item.host ? 1.0 : 0.5)
                        }
                        .buttonStyle(.plain)
                        Button {
                            enbleEditName = !enbleEditName
                        } label: {
                            Image(systemName: "xmark.square")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.theme([Color.white, Color.black])!)
                                .opacity(higIp == item.host ? 1.0 : 0.5)
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        Button {
                            enbleEditName = !enbleEditName
                        } label: {
                            Text(item.nickEnble() ? item.nickName! : item.host)
                                .foregroundStyle(Color.theme([Color.white, Color.black])!)
                        }
                        .buttonStyle(.plain)
                        .disabled(higIp == item.host ? false : true)
                    }
                    
                }
                Spacer(minLength: 5)
                Toggle("", isOn: $item.open) // 2
                    .tint(Color.theme([Color.green, Color.blue]))
                .padding()
                .toggleStyle(.switch)
                .onChange(of: item.open) { newValue in
                    DispatchQueue.global().async{
                        if item.open {
                            Socket.shared.switchOn(item)
                        } else {
                            Socket.shared.switchOff(item)
                        }
                    }
                }
                .controlSize(.small)
                .disabled(higIp == item.host ? false : true)
                Button {
                    colorActionCallBack(item)
                } label: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(Color.theme([Color.white, Color.blue])!)
                }
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                .disabled(higIp == item.host ? false : true)
                Button {
                    temperatureActionCallBack(item)
                } label: {
                    Image(systemName: "thermometer.transmission")
                        .foregroundStyle(Color.theme([Color.white, Color.blue])!)
                }
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                .disabled(higIp == item.host ? false : true)
            }
            .frame(height: 20)
            VStack (alignment: .center) {
                HStack {
                    Slider(value: $item.bright, in: 0 ... 100, label: {
                                    Image(systemName: "sun.min")
                                        .foregroundStyle(Color.theme([Color.white, Color.black])!)
                    }) { value in
                        print(value)
                        if value == false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                Socket.shared.changeBrightness(item, Int(item.bright))
                            })
                        }
                    }
                    .tint(Color.theme([Color.green, Color.blue]))
                    .disabled(higIp == item.host ? false : true)
                    Text("\(item.bright, specifier: "%.0f")")
                                    .foregroundStyle(Color.theme([Color.white, Color.black])!)
                                    .opacity(higIp == item.host ? 1.0 : 0.5)
                                    .padding()
                }
            }
            .frame(height: 20)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 1))
        .frame(height: 60)
        .background(
            Rectangle()
                .fill(Color.theme([Color.init(hex: "1E1E1E"), Color.init(hex: "FAFAFA")])!)
                .cornerRadius(10)
                            
        )
        .onTapGesture {
            tapActionCallBack(item)
        }
        .onReceive(Just(higIp)) { newValue in
            let enbleHig = higIp == item.host
            if enbleEditName && !enbleHig {
                enbleEditName = false
            }
        }
    }
}
