//
//  WeatherNowApp.swift
//  WeatherNow
//
//  Created by Daihei Doi on 2026/03/21.
//

// アーキテクチャ切り替え方法:
//   MVVM: import WeatherFeatureMVVM を有効にし、TCA ブロックをコメントアウト
//   TCA:  import WeatherFeatureTCA を有効にし、MVVM ブロックをコメントアウト

// MARK: - MVVM

import SwiftUI
import WeatherFeatureMVVM

@main
struct WeatherNowApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - TCA

// import ComposableArchitecture
// import SwiftUI
// import WeatherFeatureTCA
//
// @main
// struct WeatherNowApp: App {
//     var body: some Scene {
//         WindowGroup {
//             RootView(
//                 store: Store(initialState: RootFeature.State()) {
//                     RootFeature()
//                 }
//             )
//         }
//     }
// }
