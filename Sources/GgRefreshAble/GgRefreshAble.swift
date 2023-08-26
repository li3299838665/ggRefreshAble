import SwiftUI

#if DEBUG
struct GgRefreshAbleTestDemo: View {
    
    @State var loadingMore: Bool = false
    var body: some View {

        ScrollView {

            LazyVStack(spacing: 0, pinnedViews: PinnedScrollableViews.sectionHeaders) {
               
                Section {
                    ForEach(0..<20) { value in
                        Text("\(value)")
                            .padding()
                    }
                } header: {
                    Color.blue
                }
                
                HStack(spacing: 12) {
                    ProgressView()
                    Text("加载中...")
                }
                .padding()
                .onAppear {
                    Task {
                        await loadMore()
                    }
                }
            }
            .ggRefreshAble(.normal) {
                await refresh()
            }
//            .ggRefreshAble { // 简化写法
//                await refresh()
//            }
//
//            .ggRefreshAble { // 自定义刷新头
//                await refresh()
//            } content: { state in
//
//                VStack {
//                    if state == .refreshing {
//                        HStack(spacing: 12) {
//                            ProgressView()
//                            Text("正在刷新...")
//                        }
//
//                    }else if state == .prepare || state == .pulling {
//
//                        Image(systemName: "arrow.down")
//                        Text("继续下拉刷新")
//                    }else {
//                        Text("刷新完成")
//
//                    }
//                }
//                .padding()
//            }

        }
        .clipped()
        .padding(.vertical, 100)
    }
        
    func refresh() async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }
    
    func loadMore() async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }
}


struct GgRefreshAbleTestDemo_Previews: PreviewProvider {
    static var previews: some View {
        GgRefreshAbleTestDemo()
    }
}
#endif

extension View {
    
    public func ggRefreshAble(_ style: GgRefreshAbleControl.Style = .normal, action: @escaping @Sendable () async -> Void) -> some View {

        return self.modifier(GgScrollViewModifier(action: action, refreshView: { state in
            GgRefreshAbleControl(style: style, state: state)
        }))
    }
    
    public func ggRefreshAble<V: View>(_ action: @escaping @Sendable () async -> Void, content: @escaping @Sendable (GgRefreshState) -> V) -> some View {
        return self.modifier(GgScrollViewModifier(action: action, refreshView: { state in
            
            content(state)
        }))
    }
}

public enum GgRefreshState {
    
    case prepare
    case pulling
    case refreshing
    case end
}

struct GgScrollViewModifier<V: View>: ViewModifier {
    

    var action: () async -> Void
    var refreshView: (_ state: GgRefreshState) -> V

    @State private var refreshState: GgRefreshState = .prepare
    @State private var threthold: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var originOffsetY: CGFloat?
    @State private var frozen: Bool = false
    @State private var paddingHeight: CGFloat = 0
    func body(content: Content) -> some View {

        VStack(spacing: 0) {

            Color.clear
                .frame(height: paddingHeight)
            refreshView(refreshState)
                .background(
                    GeometryReader(content: { proxy in
                        
                        Color.clear
                            .onChange(of: proxy.size.height) { newValue in

                                threthold = newValue
                            }
                            .onAppear {

                                threthold = proxy.size.height
                            }
                    })
                )
            content
        }
        .background(
            
            GeometryReader(content: { proxy in
                
                Color.clear
                    .onChange(of: proxy.frame(in: .global).minY, perform: { newValue in
                        
                        if offsetY <= 0 && refreshState == .end && frozen == true {
                            
                            frozen = false
                            refreshState = .prepare
                        }

                        offsetY = newValue
                        
                        if originOffsetY == nil {
                            
                            originOffsetY = newValue
                        }

                        offsetY = newValue - (originOffsetY ?? 0)
                        
//                        print("offsetY: \(offsetY), originOffsetY: \(originOffsetY ?? 0)")

                        if offsetY > threthold && frozen == false && refreshState == .pulling {
                            frozen = true
                            refreshState = .refreshing
                            
                            Task {
                                
                                await action()
                                let animationDuration = 0.25
                                refreshState = .end
                                withAnimation(.easeInOut(duration: animationDuration)) {
                                    
                                    paddingHeight = min(threthold, max(0, offsetY))
                                }
                            }
                        }else if offsetY > 0 {
                            
                            if refreshState == .prepare {
                                refreshState = .pulling
                            }
                        }
                        
                        if refreshState == .refreshing {
                
                            paddingHeight = threthold
                        }else {
                
                            paddingHeight = min(threthold, max(0, offsetY))
                        }
                    })
                    .onAppear {
                        
                        originOffsetY = nil
                    }
            })
        )
        .padding(.top, -threthold)
    }
}

public struct GgRefreshAbleControl: View {
    
    public enum Style {
        case empty
        case normal
    }
    
    public var style: Style = .normal
    var state: GgRefreshState
    public var body: some View {
        
        if style == .normal {
            GgRefreshAbleNormalControl(state: state)
        }else {
            EmptyView()
        }
    }
}

struct GgRefreshAbleNormalControl: View {
    var state: GgRefreshState
    var body: some View {
        
        VStack {
            HStack(spacing: 12) {
                if state == .refreshing {
                   
                    ProgressView()
                    Text("正在刷新...")
                }else if state == .prepare || state == .pulling {
                    
                    Image(systemName: "arrow.down")
                    Text("继续下拉刷新...")
                }else {
                    Text("刷新完成")
                }
            }
            .font(.system(size: 12))
            
        }
        .frame(height: 80)
    
    }
}
