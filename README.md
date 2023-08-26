# GgRefreshAble

A description of this package.

## Import method: new pacakge xcode, input the HTTPS path - https://github.com/li3299838665/ggRefreshAble.git

## Supports fast custom refresh headers and provides a default refresh header. You can also hide the refresh header at any time by setting the style none

## example:
    import SwiftUI
    import GgRefreshAble
    
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
    //                    }else if state == .prepare || state == .pulling {
    //
    //                        HStack(spacing: 12) {
    //                            Image(systemName: "arrow.down")
    //                            Text("继续下拉刷新")
    //                        }
    //                    }else {
    //
    //                        Text("刷新完成")
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

    
    
