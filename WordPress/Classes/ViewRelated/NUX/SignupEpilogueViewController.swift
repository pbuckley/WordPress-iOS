import SVProgressHUD
import WordPressAuthenticator


class SignupEpilogueViewController: NUXViewController {

    // MARK: - Public Properties

    var credentials: AuthenticatorCredentials?
    var socialService: SocialService?

    /// Closure to be executed upon tapping the continue button.
    ///
    var onContinue: (() -> Void)?

    // MARK: - Outlets

    @IBOutlet private var buttonViewContainer: UIView! {
        didSet {
            buttonViewController.move(to: self, into: buttonViewContainer)
        }
    }

    // MARK: - Private Properties

    private var updatedDisplayName: String?
    private var updatedPassword: String?
    private var updatedUsername: String?
    private var epilogueUserInfo: LoginEpilogueUserInfo?
    private var displayNameAutoGenerated: Bool = false
    private var changesMade = false

    // MARK: - Lazy Properties

    private lazy var buttonViewController: NUXButtonViewController = {
        let buttonViewController = NUXButtonViewController.instance()
        buttonViewController.delegate = self
        buttonViewController.setButtonTitles(primary: ButtonTitles.primary, primaryAccessibilityId: ButtonTitles.primaryAccessibilityId)
        buttonViewController.backgroundColor = WordPressAuthenticator.shared.style.viewControllerBackgroundColor
        return buttonViewController
    }()


    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        WordPressAuthenticator.track(.signupEpilogueViewed, properties: tracksProperties())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .neutral(.shade0)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? SignupEpilogueTableViewController {
            vc.credentials = credentials
            vc.socialService = socialService
            vc.dataSource = self
            vc.delegate = self
        }

        if let vc = segue.destination as? SignupUsernameViewController {
            vc.currentUsername = updatedUsername ?? epilogueUserInfo?.username
            vc.displayName = updatedDisplayName ?? epilogueUserInfo?.fullName
            vc.delegate = self

            // Empty Back Button
            navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .plain, target: nil, action: nil)
        }
    }

    // MARK: - analytics

    private func tracksProperties() -> [AnyHashable: Any] {
        let source: String = {
            guard let service = socialService else {
                return "email"
            }
            switch service {
            case .google:
                return "google"
            case .apple:
                return "apple"
            }
        }()

        return ["source": source]
    }
}

// MARK: - NUXButtonViewControllerDelegate

extension SignupEpilogueViewController: NUXButtonViewControllerDelegate {
    func primaryButtonPressed() {
        saveChanges()
    }
}

// MARK: - SignupEpilogueTableViewControllerDataSource

extension SignupEpilogueViewController: SignupEpilogueTableViewControllerDataSource {
    var customDisplayName: String? {
        return updatedDisplayName
    }

    var password: String? {
        return updatedPassword
    }

    var username: String? {
        return updatedUsername
    }
}

// MARK: - SignupEpilogueTableViewControllerDelegate

extension SignupEpilogueViewController: SignupEpilogueTableViewControllerDelegate {

    func displayNameUpdated(newDisplayName: String) {
        updatedDisplayName = newDisplayName
        displayNameAutoGenerated = false
    }

    func displayNameAutoGenerated(newDisplayName: String) {
        updatedDisplayName = newDisplayName
        displayNameAutoGenerated = true
    }

    func passwordUpdated(newPassword: String) {
        if !newPassword.isEmpty {
            updatedPassword = newPassword
        }
    }

    func usernameTapped(userInfo: LoginEpilogueUserInfo?) {
        epilogueUserInfo = userInfo
        performSegue(withIdentifier: .showUsernames, sender: self)
        WordPressAuthenticator.track(.signupEpilogueUsernameTapped, properties: self.tracksProperties())
    }
}

// MARK: - Private Extension

private extension SignupEpilogueViewController {
    func saveChanges() {
        if let newUsername = updatedUsername {
            SVProgressHUD.show(withStatus: HUDMessages.changingUsername)
            changeUsername(to: newUsername) {
                self.updatedUsername = nil
                self.saveChanges()
            }
        } else if let newDisplayName = updatedDisplayName {
            // If the display name is not auto generated, then the user changed it.
            // So we need to show the HUD to the user.
            if !displayNameAutoGenerated {
                SVProgressHUD.show(withStatus: HUDMessages.changingDisplayName)
            }
            changeDisplayName(to: newDisplayName) {
                self.updatedDisplayName = nil
                self.saveChanges()
            }
        } else if let newPassword = updatedPassword {
            SVProgressHUD.show(withStatus: HUDMessages.changingPassword)
            changePassword(to: newPassword) { success, error in
                if success {
                    self.updatedPassword = nil
                    self.saveChanges()
                } else {
                    self.showPasswordError(error)
                }
            }
        } else {
            if !changesMade {
                WordPressAuthenticator.track(.signupEpilogueUnchanged, properties: tracksProperties())
            }
            self.refreshAccountDetails() {
                SVProgressHUD.dismiss()
                self.dismissEpilogue()
            }
        }
        changesMade = true
    }

    func changeUsername(to newUsername: String, finished: @escaping (() -> Void)) {
        guard newUsername != "" else {
            finished()
            return
        }

        let context = ContextManager.sharedInstance().mainContext
        let accountService = AccountService(managedObjectContext: context)
        guard let account = accountService.defaultWordPressComAccount(),
            let api = account.wordPressComRestApi else {
                navigationController?.popViewController(animated: true)
                return
        }

        let settingsService = AccountSettingsService(userID: account.userID.intValue, api: api)
        settingsService.changeUsername(to: newUsername, success: {
            WordPressAuthenticator.track(.signupEpilogueUsernameUpdateSucceeded, properties: self.tracksProperties())
            finished()
        }) {
            WordPressAuthenticator.track(.signupEpilogueUsernameUpdateFailed, properties: self.tracksProperties())
            finished()
        }
    }

    func changeDisplayName(to newDisplayName: String, finished: @escaping (() -> Void)) {

        let context = ContextManager.sharedInstance().mainContext

        guard let defaultAccount = AccountService(managedObjectContext: context).defaultWordPressComAccount(),
        let restApi = defaultAccount.wordPressComRestApi else {
            finished()
            return
        }

        let accountSettingService = AccountSettingsService(userID: defaultAccount.userID.intValue, api: restApi)
        let accountSettingsChange = AccountSettingsChange.displayName(newDisplayName)

        accountSettingService.saveChange(accountSettingsChange) { success in
            if success {
                WordPressAuthenticator.track(.signupEpilogueDisplayNameUpdateSucceeded, properties: self.tracksProperties())
            } else {
                WordPressAuthenticator.track(.signupEpilogueDisplayNameUpdateFailed, properties: self.tracksProperties())
            }
            finished()
        }
    }

    func changePassword(to newPassword: String, finished: @escaping (_ success: Bool, _ error: Error?) -> Void) {

        let context = ContextManager.sharedInstance().mainContext

        guard let defaultAccount = AccountService(managedObjectContext: context).defaultWordPressComAccount(),
            let restApi = defaultAccount.wordPressComRestApi else {
                finished(false, nil)
                return
        }

        let accountSettingService = AccountSettingsService(userID: defaultAccount.userID.intValue, api: restApi)

        accountSettingService.updatePassword(newPassword) { (success, error) in
            if success {
                WordPressAuthenticator.track(.signupEpiloguePasswordUpdateSucceeded, properties: self.tracksProperties())
            } else {
                WordPressAuthenticator.track(.signupEpiloguePasswordUpdateFailed, properties: self.tracksProperties())
            }

            finished(success, error)
        }
    }

    func dismissEpilogue() {
        guard let onContinue = self.onContinue else {
            self.navigationController?.dismiss(animated: true)
            return
        }

        onContinue()
    }

    func refreshAccountDetails(finished: @escaping () -> Void) {
        let context = ContextManager.sharedInstance().mainContext
        let service = AccountService(managedObjectContext: context)
        guard let account = service.defaultWordPressComAccount() else {
            self.dismissEpilogue()
            return
        }
        service.updateUserDetails(for: account, success: { () in
            finished()
        }, failure: { _ in
            finished()
        })
    }

    private func showPasswordError(_ error: Error? = nil) {
        let errorMessage = error?.localizedDescription ?? HUDMessages.changePasswordGenericError
        SVProgressHUD.showError(withStatus: errorMessage)
    }
}

extension SignupEpilogueViewController: SignupUsernameViewControllerDelegate {
    func usernameSelected(_ username: String) {
        if username.isEmpty || username == epilogueUserInfo?.username {
            updatedUsername = nil
        } else {
            updatedUsername = username
        }
    }
}


private extension SignupEpilogueViewController {
    enum ButtonTitles {
        static let primary = NSLocalizedString("Continue", comment: "Button text on site creation epilogue page to proceed to My Sites.")
        static let primaryAccessibilityId = "Continue Button"
    }

    enum HUDMessages {
        static let changingDisplayName = NSLocalizedString("Changing display name", comment: "Shown while the app waits for the display name changing web service to return.")
        static let changingUsername = NSLocalizedString("Changing username", comment: "Shown while the app waits for the username changing web service to return.")
        static let changingPassword = NSLocalizedString("Changing password", comment: "Shown while the app waits for the password changing web service to return.")
        static let changePasswordGenericError = NSLocalizedString("There was an error changing the password", comment: "Text displayed when there is a failure changing the password.")
    }
}

// MARK: - User Defaults

extension UserDefaults {
    var quickStartWasDismissedPermanently: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
}
