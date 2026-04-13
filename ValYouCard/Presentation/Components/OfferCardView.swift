import SwiftUI

struct OfferCardView: View {
    let offer: Offer

    var isOnline: Bool {
        (offer.searchDistance ?? 0) > 1000
    }

    var formattedDistance: String? {
        guard let distance = offer.searchDistance, !isOnline, distance > 0 else { return nil }
        return String(format: "%.1f mi", distance)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Logo
            AsyncImageView(url: offer.logoUrl, width: 60, height: 60, cornerRadius: 8)
                .frame(width: 70, height: 70)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.offerStore.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if isOnline {
                    Label("Online", systemImage: "globe")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if let distance = formattedDistance {
                    Text(distance)
                        .font(.caption)
                        .foregroundStyle(AppTheme.blue)
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text(offer.savingsAmount ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Avg Savings")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.darkGrey)
                    }

                    Spacer()
                }
            }

            Spacer()

            // View Deals button
            Text("View Deals")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}
