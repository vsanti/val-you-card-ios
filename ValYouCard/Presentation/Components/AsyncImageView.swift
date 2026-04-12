import SwiftUI

struct AsyncImageView: View {
    let url: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 8

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: width, height: height)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(AppTheme.grey)
                    .frame(width: width, height: height)
            @unknown default:
                EmptyView()
            }
        }
    }
}
