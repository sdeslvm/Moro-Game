import Foundation
import SwiftUI

struct MoroEntryScreen: View {
    @StateObject private var loader: MoroWebLoader

    init(loader: MoroWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            MoroWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                MoroProgressIndicator(value: percent)
            case .failure(let err):
                MoroErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                MoroOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct MoroProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            MoroLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct MoroErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct MoroOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
