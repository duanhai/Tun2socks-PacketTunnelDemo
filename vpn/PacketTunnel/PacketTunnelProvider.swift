//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by duanhai on 2019/8/29.
//  Copyright © 2019 duanhai. All rights reserved.
//

import NetworkExtension
import Tun2socks
class PacketTunnelProvider: NEPacketTunnelProvider {

    let serverIp = "xxx"
    
    func tunToUDP() {
        
        weak var weakSelf = self
        self.packetFlow.readPackets { (packets: [Data], protocols: [NSNumber]) in
            for packet in packets {
                Tun2socksInputPacket(packet)
                
            }
            
            // Recursive to keep reading
            weakSelf!.tunToUDP()
        }
    }
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverIp)
        networkSettings.mtu = 1480
        
        let ipv4Settings = NEIPv4Settings(addresses: [serverIp], subnetMasks: ["255.255.255.0"])
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        let dnsSetting = NEDNSSettings.init(servers: ["8.8.8.8","8.8.4.8"])
        
        networkSettings.ipv4Settings = ipv4Settings
        networkSettings.dnsSettings = dnsSetting
//        self.setTunnelNetworkSettings(ipv4Settings, completionHandler:  (Error?) ->Void){
//            completionHandler(nil)
//        }
        
        setTunnelNetworkSettings(networkSettings) { (error) in
            guard error == nil else {
                completionHandler(error)
                NSLog(error?.localizedDescription ?? "")
                return
            }
            
            completionHandler(error)



        }
        NSLog("before")

//        Tun2socksStartShadowsocks(self, serverIp, 8488, "AES-256-CFB", "abcd1234")
        
        let fileName = "v2ray"
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
//                NSLog(data.description)
                NSLog("description :\(data.description)")
                Tun2socksStartV2Ray(self, data)

            } catch let err {
                print("error:\(err)")
            }

        }

        NSLog("after")
        
//        Tun2socksStartV2ray(self, <#T##configBytes: Data!##Data!#>)
        
//        self.tunToUDP()
        NSLog("========")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tunToUDP()
        }
        // Add code here to start the process of connecting the tunnel.
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        
//        VpnManager.shared.disconnect()
        completionHandler()
    }
    
//    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        // Add code here to handle the message.
//        if let handler = completionHandler {
//            handler(messageData)
//        }
//    }
//
//    override func sleep(completionHandler: @escaping () -> Void) {
//        // Add code here to get ready to sleep.
//        completionHandler()
//    }
//
//    override func wake() {
//        // Add code here to wake up.
//    }
}

extension PacketTunnelProvider: Tun2socksPacketFlowProtocol{
    func writePacket(_ packet: Data!) {
//        self.packetFlow.writePackets([packet],withProtocols: [NSNumber](repeating: AF_INET as NSNumber, count: 1))
        
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
//        self.packetFlow.writePacketObjects([packet])
        
    }
    
    
}
