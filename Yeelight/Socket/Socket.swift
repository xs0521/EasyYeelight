//
//  AppCommand.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/21.
//

import Foundation


class Socket: NSObject {
    
    static let shared = Socket()
    
    var socketDidConnectCallBack: GeneralCallBack<String>?
    
    var udpSocket: UDPSocket!
    var tcpSocket: TCPSocket!
    
    var currentDevice: Device?
    
    private(set) var devices: Set<Device> = []
    
    func config() -> Void {
        udpSocket = UDPSocket()
        tcpSocket = TCPSocket()
        tcpSocket.socketDidConnectCallBack = { [weak self] (host) in
            self?.socketDidConnectCallBack?(host)
        }
    }
    
    func reset() -> Void {
        tcpSocket.disConnect()
        currentDevice = nil
        devices = []
    }
    
    func searchDevice(_  completion: @escaping GeneralCallBack<[Device]>) -> Void {
        udpSocket.discover { [weak self] (devices) in
            devices.forEach({self?.devices.insert($0)})
            var list = [Device]()
            self?.devices.forEach { device in
                list.append(device)
            }
            completion(list)
        }
    }
}

extension Socket {
    
    func switchOn(_ device: Device){
        
        if device == currentDevice {
            "on light".p()
            tcpSocket.switchOn()
        }
    }
    
    func switchOff(_ device: Device){
        
        if device == currentDevice {
            "off light".p()
            tcpSocket.switchOff()
        }
    }
    
    func changeBrightness(_ device: Device, _ bright: Int) -> Void {
        if device == currentDevice {
            "changeBrightness".p()
            tcpSocket.changeBrightness(bright)
        }
    }
    
    func changeColor(_ device: Device, _ value: Int) -> Void {
        if device == currentDevice {
            "changeBrightness".p()
            tcpSocket.changeColor(value)
        }
    }
    
    func connect(_ device: Device) -> Void {
        currentDevice = device
        tcpSocket.connect(device)
    }
    
    func autoReConnect() -> Void {
        guard let device = currentDevice else { return }
        "autoReConnect \(device.host)".p()
        connect(device)
    }
}
