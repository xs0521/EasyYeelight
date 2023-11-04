//
//  MainCellContainerView.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/19.
//

import SwiftUI

struct MainCellContainerView: View {
    
    @Binding var item: Device
    @Binding var tapActionCallBack: GeneralCallBack<Device>
    @Binding var higIp: String
    
    var body: some View {
        
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                HStack {
                    Image(systemName: "network")
                    Text(item.host)
                }
                Spacer()
                Toggle("", isOn: $item.open) // 2
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
            }
            .frame(height: 20)
            VStack (alignment: .center) {
                HStack {
                    Slider(value: $item.bright, in: 0 ... 100, label: {
                                    Image(systemName: "sun.min")
                    }) { value in
                        print(value)
                        if value == false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                Socket.shared.changeBrightness(item, Int(item.bright))
                            })
                        }
                    }
                    .disabled(higIp == item.host ? false : true)
                    Text("\(item.bright, specifier: "%.0f")")
                                    .padding()
                }
            }
            .frame(height: 20)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 1))
        .frame(height: 60)
        .background(
            Rectangle()
                .fill(higIp == item.host ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(10)
                            
        )
        .onTapGesture {
            tapActionCallBack(item)
        }
    }
}
