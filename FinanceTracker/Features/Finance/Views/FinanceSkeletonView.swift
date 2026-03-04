import SwiftUI

struct FinanceSkeletonView: View {
    let showTopLoader: Bool
    
    init(showTopLoader: Bool = true) {
        self.showTopLoader = showTopLoader
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showTopLoader {
                DotArcLoaderView(size: 74, dotSize: 13)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 6)
            }
            
            summarySkeleton
            sectionHeader(width: 190)
            chartSkeleton
            sectionHeader(width: 150)
            transactionsSkeleton
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 80)
        .accessibilityHidden(true)
    }
    
    private var summarySkeleton: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: 12)],
            spacing: 12
        ) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 10) {
                    SkeletonBlockView(width: 24, height: 24, cornerRadius: 12)
                    SkeletonBlockView(width: 68, height: 10, cornerRadius: 5)
                    SkeletonBlockView(width: 94, height: 14, cornerRadius: 7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .cardSurface(cornerRadius: 12)
            }
        }
    }
    
    private func sectionHeader(width: CGFloat) -> some View {
        SkeletonBlockView(width: width, height: 24, cornerRadius: 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var chartSkeleton: some View {
        VStack(spacing: 16) {
            SkeletonBlockView(width: 184, height: 184, cornerRadius: 92)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack(spacing: 10) {
                        SkeletonBlockView(width: 10, height: 10, cornerRadius: 5)
                        SkeletonBlockView(height: 12, cornerRadius: 6)
                            .frame(maxWidth: .infinity)
                        VStack(alignment: .trailing, spacing: 6) {
                            SkeletonBlockView(width: 52, height: 10, cornerRadius: 5)
                            SkeletonBlockView(width: 72, height: 12, cornerRadius: 6)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .cardSurface(cornerRadius: 16)
    }
    
    private var transactionsSkeleton: some View {
        VStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { _ in
                HStack(spacing: 12) {
                    SkeletonBlockView(width: 30, height: 30, cornerRadius: 8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonBlockView(width: 120, height: 14, cornerRadius: 6)
                        SkeletonBlockView(width: 84, height: 10, cornerRadius: 5)
                    }
                    
                    Spacer(minLength: 0)
                    
                    SkeletonBlockView(width: 70, height: 14, cornerRadius: 6)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .cardSurface(cornerRadius: 12)
    }
}

#Preview("Finance Skeleton") {
    FinanceSkeletonView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
}
