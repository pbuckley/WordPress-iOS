import Foundation

final class PostListItemViewModel {
    let post: Post
    let title: String?
    let snippet: String?
    let imageURL: URL?
    let date: String?
    let accessibilityIdentifier: String?

    var status: String { statusViewModel.statusAndBadges(separatedBy: " · ")}
    var statusColor: UIColor { statusViewModel.statusColor }
    var author: String { statusViewModel.author }

    private let statusViewModel: PostCardStatusViewModel

    init(post: Post) {
        self.post = post
        self.title = post.titleForDisplay()
        self.snippet = post.contentPreviewForDisplay()
        self.imageURL = post.featuredImageURL
        self.date = post.displayDate()?.capitalizeFirstWord
        self.statusViewModel = PostCardStatusViewModel(post: post)
        self.accessibilityIdentifier = post.slugForDisplay()
    }
}

private extension String {
    var capitalizeFirstWord: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst()
        return firstLetter + remainingLetters
    }
}
