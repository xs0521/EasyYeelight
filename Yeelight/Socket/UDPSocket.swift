//
//  UDPSocket.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/21.
//

import Foundation
import CocoaAsyncSocket

private let discover_message = """
                M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: "ssdp:discover"\r\nST: wifi_bulb
                """
private let host = "239.255.255.250"
private let port: UInt16 = 1982
private let location = "Location"

class UDPSocket: NSObject {
    
    private var udpSocket: GCDAsyncUdpSocket!
    private var completion: GeneralCallBack<[Device]>?
    
    override init() {
        super.init()
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        udpSocket.setIPv4Enabled(true)
        udpSocket.setIPv6Enabled(false)
    }
}

extension UDPSocket {
    
    func discover(completion: @escaping GeneralCallBack<[Device]>) -> Void {
        
        "discover".p()
        self.completion = completion
        do {
            guard let discover_data = discover_message.data(using: String.Encoding.utf8) else { return }
            udpSocket.send(discover_data, toHost: host, port: port, withTimeout: 1000, tag: 0)
            try udpSocket.enableBroadcast(true)
            try udpSocket.beginReceiving()
        }catch (let error) {
            "discover error \(error)".p()
        }
    }
}

extension UDPSocket: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        "didReceive start ---------".p()
        
        let s = String(data: data, encoding: String.Encoding.utf8)!
        let rows = s.split(separator: "\r\n").map(String.init)
        var proprieties = [String : Any]()
        for s in rows {
            if s.contains(location) {
                let components = s.components(separatedBy: "//")
                var addr: String? = nil
                if components.count >= 2 {
                    addr = components.last
                }
                guard let addr = addr else { return }
                let parts = addr.split(separator: ":").map(String.init)
                proprieties["ip"] = parts.first?.removeHeadAndTailSpace
                proprieties["port"] = UInt16(parts.last?.removeHeadAndTailSpace ?? "0")
                continue
            }
            let values = s.split(separator: ":").map(String.init)
            if values.count == 2 {
                proprieties[values.first!] = values.last?.removeHeadAndTailSpace
                if let value = values.last?.removeHeadAndTailSpace, let v = Int(value) {
                    proprieties[values.first!] = v
                }
            }
        }
        
        print(proprieties)
        
        guard let jsonData = proprieties.toData() else { return }
        
        do {
            var device = try JSONDecoder().decode(Device.self, from: jsonData)
            device.update()
            completion?([device])
        }catch {
            "JSON fail".p()
        }
    }
    

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        "didNotConnect error\(String(describing: error))".p()
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        "udpSocketDidClose error\(String(describing: error))".p()
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        
        var hostname = [CChar].init(repeating: 0, count: Int(NI_MAXHOST))
        do{
            try address.withUnsafeBytes({ (pointer:UnsafePointer<sockaddr>) -> Void in
                guard getnameinfo(pointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else{
                    throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
                }
            })
        }catch(let error){
            print(error.localizedDescription)
        }
        var newAddress = String.init(cString: hostname)
        let addArry = newAddress.components(separatedBy: ":")
        if addArry.count > 1 {
            newAddress = addArry[addArry.count-1]
        }
        "didConnectToAddress IP:\(newAddress)".p()
        
        if let str = String.init(data: address, encoding: .utf8) {
            "didConnectToAddress \(str)".p()
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        "didSendDataWithTag \(tag)".p()
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        "didNotSendDataWithTag \(tag)".p()
    }
}
