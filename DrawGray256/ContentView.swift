//
//  ContentView.swift
//  DrawGray256
//
//  Created by Sang Hyun Kim on 8/4/24.
//

import SwiftUI
import CoreGraphics

struct ContentView: View {
    var body: some View {
        VStack {
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
