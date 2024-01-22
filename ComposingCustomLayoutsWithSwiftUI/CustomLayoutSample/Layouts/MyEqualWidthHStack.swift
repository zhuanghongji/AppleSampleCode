/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom horizontal stack that offers all its subviews the width of its largest subview.
*/

import SwiftUI

/// A custom horizontal stack that offers all its subviews the width of its
/// widest subview.
///
/// This custom layout arranges views horizontally, giving each the width needed
/// by the widest subview.
///
/// ![Three rectangles arranged in a horizontal line. Each rectangle contains
/// one smaller rectangle. The smaller rectangles have varying widths. Dashed
/// lines above each of the container rectangles show that the larger rectangles
/// all have the same width as each other.](voting-buttons)
///
/// The custom stack implements the protocol's two required methods. First,
/// ``sizeThatFits(proposal:subviews:cache:)`` reports the container's size,
/// given a set of subviews.
///
/// ```swift
/// let maxSize = maxSize(subviews: subviews)
/// let spacing = spacing(subviews: subviews)
/// let totalSpacing = spacing.reduce(0) { $0 + $1 }
///
/// return CGSize(
///     width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
///     height: maxSize.height)
/// ```
///
/// This method combines the largest size in each dimension with the horizontal
/// spacing between subviews to find the container's total size. Then,
/// ``placeSubviews(in:proposal:subviews:cache:)`` tells each of the subviews
/// where to appear within the layout's bounds.
///
/// ```swift
/// let maxSize = maxSize(subviews: subviews)
/// let spacing = spacing(subviews: subviews)
///
/// let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
/// var nextX = bounds.minX + maxSize.width / 2
///
/// for index in subviews.indices {
///     subviews[index].place(
///         at: CGPoint(x: nextX, y: bounds.midY),
///         anchor: .center,
///         proposal: placementProposal)
///     nextX += maxSize.width + spacing[index]
/// }
/// ```
///
/// The method creates a single size proposal for the subviews, and then uses
/// that, along with a point that changes for each subview, to arrange the
/// subviews in a horizontal line with default spacing.
struct MyEqualWidthHStack: Layout {
    /// Returns a size that the layout container needs to arrange its subviews
    /// horizontally.
    /// - Tag: sizeThatFitsHorizontal
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CGSize(
            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
            height: maxSize.height)
    }

    /// Places the subviews in a horizontal stack.
    /// - Tag: placeSubviewsHorizontal
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)

        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var nextX = bounds.minX + maxSize.width / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: nextX, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            nextX += maxSize.width + spacing[index]
        }
    }

    /// Finds the largest ideal size of the subviews.
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }

    /// Gets an array of preferred spacing sizes between subviews in the
    /// horizontal dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
}
