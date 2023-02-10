import UIKit
import WebKit

class BlazeWebViewController: UIViewController, BlazeWebView {

    // MARK: Public Variables

    let webView: WKWebView

    // MARK: Private Variables

    private var viewModel: BlazeWebViewModel?
    private let progressView = WebProgressView()

    // MARK: Lazy Loaded Views

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Strings.cancelButtonTitle,
                                     style: .plain,
                                     target: self,
                                     action: #selector(cancelButtonTapped))
        return button
    }()

    // MARK: Initializers

    init(source: BlazeWebViewCoordinator.Source, blog: Blog, postID: NSNumber?) {
        self.webView = WKWebView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
        viewModel = BlazeWebViewModel(source: source, blog: blog, postID: postID, view: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        configureSubviews()
        configureWebView()
        configureNavBar()
        viewModel?.startBlazeFlow()
    }

    // MARK: Private Helpers

    private func configureSubviews() {
        let subviews = [progressView, webView]
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        view = stackView
    }

    private func configureWebView() {
        webView.navigationDelegate = self
        webView.customUserAgent = WPUserAgent.wordPress()
        progressView.observeProgress(webView: webView)
    }

    private func configureNavBar() {
        title = Strings.navigationTitle
        navigationItem.rightBarButtonItem = cancelButton
        configureNavBarAppearance()
    }

    private func configureNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Colors.navigationBarColor
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationItem.compactScrollEdgeAppearance = appearance
        }
    }

    // MARK: BlazeWebView

    func loadRequest(request: URLRequest) {
        webView.load(request)
    }

    // MARK: Actions

    @objc func cancelButtonTapped() {
        dismiss(animated: true)
        viewModel?.cancelTapped()
    }
}

extension BlazeWebViewController: WKNavigationDelegate {

}

private extension BlazeWebViewController {
    enum Constants {
        static let blazeSiteURLFormat = "https://wordpress.com/advertising/%@?source=%@"
        static let blazePostURLFormat = "https://wordpress.com/advertising/%@?blazepress-widget=post-%d&source=%@"
    }

    enum Strings {
        static let navigationTitle = NSLocalizedString("feature.blaze.title",
                                                       value: "Blaze",
                                                       comment: "Name of a feature that allows the user to promote their posts.")
        static let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel. Action.")
    }

    enum Colors {
        static let navigationBarColor = UIColor(hexString: "F2F1F6")?.withAlphaComponent(0.8)
    }
}
