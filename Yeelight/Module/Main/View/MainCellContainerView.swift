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
                        .foregroundStyle(Color.white)
                    if enbleEditName && higIp == item.host ? true : false {
                        TextField("empty is the default", text: $editName)
                            .frame(width: 150)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            enbleEditName = !enbleEditName
                            UserDefaults.set(editName, forKey: item.id)
                            item.update()
                        } label: {
                            Text("save")
                                .foregroundStyle(Color.blue)
                                .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                                .background(Color.init(hex: "#B5C1D8"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        Button {
                            enbleEditName = !enbleEditName
                        } label: {
                            Text("cancel")
                                .foregroundStyle(Color.blue)
                                .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                                .background(Color.init(hex: "#B5C1D8"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        Button {
                            enbleEditName = !enbleEditName
                        } label: {
                            Text(item.nickEnble() ? item.nickName! : item.host)
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)
                        .disabled(higIp == item.host ? false : true)
                    }
                    
                }
                Spacer(minLength: 5)
                Toggle("", isOn: $item.open) // 2
                    .tint(Color.green)
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
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                .disabled(higIp == item.host ? false : true)
                Button {
                    temperatureActionCallBack(item)
                } label: {
                    Image(systemName: "thermometer.transmission")
                        .foregroundStyle(Color.white)
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
                                        .foregroundStyle(Color.white)
                    }) { value in
                        print(value)
                        if value == false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                Socket.shared.changeBrightness(item, Int(item.bright))
                            })
                        }
                    }
                    .tint(Color.white)
                    .disabled(higIp == item.host ? false : true)
                    Text("\(item.bright, specifier: "%.0f")")
                                    .foregroundStyle(Color.white)
                                    .padding()
                }
            }
            .frame(height: 20)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 1))
        .frame(height: 60)
        .background(
            Rectangle()
//                .fill(higIp == item.host ? Color.init(hex: "1E1E1E").opacity(0.2) : Color.init(hex: "1E1E1E"))
                .fill(Color.init(hex: "1E1E1E"))
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
