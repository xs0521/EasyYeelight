//
//  TCPSocket.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/22.
//

import Foundation
import CocoaAsyncSocket

class TCPSocket: NSObject {
    
    private var socket: GCDAsyncSocket!
    private var connected = false
    private var currentIP = ""
    private var i = 0
    
    var socketDidConnectCallBack: GeneralCallBack<String>?
    
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    func enbleConnect(_ ip: String) -> Bool {
        return !connected || ip != currentIP
    }
    
    func connect(_ device: Device) -> Void {
        
        if enbleConnect(device.ip) == false {
            return
        }
        connected = true
        currentIP = device.ip
        
        disConnect()
        
        do {
            "start connect ip \(device.ip) port \(device.port)".p()
            try socket.connect(toHost: device.ip, onPort: device.port, withTimeout: -1)
        } catch {
            
        }
    }
    
    func disConnect() -> Void {
        socket.disconnect()
    }
}

extension TCPSocket {
    
    func switchOn(){
        sendCMD(msgType: .switchOn)
    }
    
    func switchOff(){
        sendCMD(msgType: .switchOff)
    }
    
    func changeBrightness(_ bright: Int) -> Void {
        sendCMD(msgType: .bright(value: bright))
    }
    
    func sendCMD(msgType: MessageType) -> Void {
        sendCmdReply(id: getIndex(), method: msgType.method, params: msgType.params, tag: msgType.tag)
    }
}

extension TCPSocket: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        "tcp didConnectTo url \(url.absoluteString)".p()
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        "tcp didConnectToHost host \(host) port \(port)".p()
        socketDidConnectCallBack?(host)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        connected = false
        "tcp socketDidDisconnect err \(String(describing: err))".p()
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        "tcp didRead tag \(tag))".p()
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        "tcp didWriteDataWithTag tag \(tag))".p()
    }
}

extension TCPSocket {
    
    func sendCmdReply(id: Int, method: String, params: [Any], tag: Int) -> Void {
        let content = handlerParams(params)
        let cmd = "{\"id\":\(id),\"method\":\"\(method)\",\"params\":[\(content)]}\r\n";
        guard let cmdData = cmd.data(using: String.Encoding.utf8) else { return }
        ("SEND: " + cmd).p()
        socket.write(cmdData, withTimeout: -1, tag: tag)
    }

    private func handlerParams(_ array: [Any]) -> String {
        return array.compactMap { (value) -> String? in
            return (value is Int ? "\(value)" : ("\"\(value)\""))
            }.joined(separator: ",")
    }

    private func getIndex() -> Int{
        i=i+1;
        return i;
    }
    
}
