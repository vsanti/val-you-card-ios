import SwiftUI

struct MemberIdCardView: View {
    let memberId: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Val-You Card")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Member ID")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            HStack {
                Text(memberId)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.orange.opacity(0.3), radius: 12, y: 6)
    }
}
