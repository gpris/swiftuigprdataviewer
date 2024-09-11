//
//  ContentView.swift
//  DrawGray256
//
//  Created by Sang Hyun Kim on 8/4/24.
//

import SwiftUI
import CoreGraphics
import Foundation
import Network

class TCPClient: ObservableObject {
    @Published var receivedData: String = "Waiting for data..."
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "TCP Client Queue")

    func start(host: String, port: UInt16) {
        let nwHost = NWEndpoint.Host(host)
        let nwPort = NWEndpoint.Port(rawValue: port)!
        connection = NWConnection(host: nwHost, port: nwPort, using: .tcp)
        
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to \(nwHost):\(nwPort)")
                self.receive()
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                break
            }
        }
        connection?.start(queue: queue)
    }

    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8) ?? "Received non-text data"
                DispatchQueue.main.async {
                    self.receivedData = message
                }
                self.receive() // Continue to receive more data
            } else if let error = error {
                print("Receive error: \(error)")
            }
        }
    }

    func stop() {
        connection?.cancel()
    }
}
//class TCPClient {
//    let connection: NWConnection
//    let queue = DispatchQueue(label: "TCP Client Queue")
//
//    init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
//        connection = NWConnection(host: host, port: port, using: .tcp)
//    }
//
//    func start() {
//        connection.stateUpdateHandler = { newState in
//            switch newState {
//            case .ready:
//                print("Connected to \(self.connection.endpoint)")
//                self.receive()
//            case .failed(let error):
//                print("Failed to connect: \(error)")
//            default:
//                break
//            }
//        }
//        connection.start(queue: queue)
//    }
//
//    func receive() {
//        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
//            if let data = data, !data.isEmpty {
//                let message = String(data: data, encoding: .utf8) ?? "Received non-text data"
//                print("Received: \(message)")
//                self.receive() // Continue to receive more data
//            } else if let error = error {
//                print("Receive error: \(error)")
//            }
//        }
//    }
//
//    func stop() {
//        connection.cancel()
//    }
//}
//let client = TCPClient(host: "localhost", port: 8080)
//client.start()


struct ContentView: View {
    @StateObject private var tcpClient = TCPClient()
    var body: some View {
        VStack { 
            Text(tcpClient.receivedData)
                            .padding()
                        Button("Start TCP Client") {
                            tcpClient.start(host: "localhost", port: 8080)
                        }
                        .padding()
            if let cgImage = createImageWithLines(width: 4096, height: 256) {
                Image(cgImage, scale: 1.0, label: Text("Line by Line Image"))
                    .resizable()
                    .frame(width: 768, height: 256)
            } else {
                Text("Failed to create image")
            }
        }
    }
    
    func createImageWithLines(width: Int, height: Int) -> CGImage? {
        let bitsPerComponent = 8
        let bytesPerRow = width
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // 빈 데이터 배열 생성
        //var data = [UInt8](repeating: 0, count: width * height)
        var data = [UInt8](repeating: 128, count: width * height)
        // 한 데이터 라인으로 전체를 그릴 수 있는지 확인
        let datum = [UInt8](0...255).map { _ in
            return UInt8.random(in: 0...255)
        }
        for y in 0..<width  {
                        for x in 0..<height {
                            data[x * width + y] = UInt8.random(in: 0...255) // 예제 데이터
                            //data[x * width + y] = datum[x] // working for one random vertical 256 pcs data
                        }
            //data.insert(contentsOf:datum, at: y*256)
            //
        }
        
        guard let providerRef = CGDataProvider(data: NSData(bytes: data, length: data.count)) else {
            print("Failed to create CGDataProvider.")
            return nil
        }
        
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }

}

#Preview {
    
    ContentView()
}
