import Foundation

/// Media Progress Coordinator Delegate comunicates changes on media progress.
///
@objc public protocol MediaProgressCoordinatorDelegate: class {

    func mediaProgressCoordinator(_ mediaProgressCoordinator: MediaProgressCoordinator, progressDidChange progress: Float)
    func mediaProgressCoordinatorDidStartUploading(_ mediaProgressCoordinator: MediaProgressCoordinator)
    func mediaProgressCoordinatorDidFinishUpload(_ mediaProgressCoordinator: MediaProgressCoordinator)
}

extension ProgressUserInfoKey {
    static let mediaID = ProgressUserInfoKey("mediaID")
    static let mediaError = ProgressUserInfoKey("mediaError")
    static let mediaObject = ProgressUserInfoKey("mediaObject")
}

/// Media Progress Coordinator allow the tracking of progress on multiple media objects.
///
public class MediaProgressCoordinator: NSObject {

    public weak var delegate: MediaProgressCoordinatorDelegate?

    private(set) var mediaGlobalProgress: Progress?

    private(set) lazy var mediaInProgress: [String: Progress] = {
        return [String: Progress]()
    }()

    private var mediaProgressObserverContext: String = "mediaProgressObserverContext"

    deinit {
        mediaGlobalProgress?.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
    }

    /// Setup the coordinator to track the provided number of tasks
    ///
    /// - Parameter count: the number of tasks that need to be tracked
    ///
    func track(numberOfItems count: Int) {
        if let mediaUploadingProgress = mediaGlobalProgress, !isRunning {
            mediaUploadingProgress.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
            mediaGlobalProgress = nil
        }

        if mediaGlobalProgress == nil {
            mediaGlobalProgress = Progress.discreteProgress(totalUnitCount: 0)
            mediaGlobalProgress?.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: [.new], context: &mediaProgressObserverContext)

            delegate?.mediaProgressCoordinatorDidStartUploading(self)
        }

        mediaGlobalProgress?.totalUnitCount += Int64(count)
    }

    /// Start the tracking of a task that is represented by the provided progress and is associated to an object with the provided mediaID.
    ///
    /// - Parameters:
    ///   - progress: the object that tracks the progress
    ///   - object: the associated object.
    ///   - mediaID: the unique taskID
    ///
    func track(progress: Progress, ofObject object: Media, withMediaID mediaID: String) {
        progress.setUserInfoObject(mediaID, forKey: .mediaID)
        progress.setUserInfoObject(object, forKey: .mediaObject)
        mediaGlobalProgress?.addChild(progress, withPendingUnitCount: 1)
        mediaInProgress[mediaID] = progress
    }

    /// Finish one of the tasks.
    ///
    /// Note: This method is used to advance the completed number of tasks, when the task doesn't have any relevant associated work/progress to be tracked.
    /// For example an already existing media object that is already uploaded to the server.
    ///
    func finishOneItem() {
        guard let mediaUploadingProgress = mediaGlobalProgress else {
            return
        }

        mediaUploadingProgress.completedUnitCount += 1
    }

    /// Attach an error to an ongoing media creation/upload task
    ///
    /// - Parameters:
    ///   - error: the error to attach
    ///   - mediaID: the mediaID to attach error
    ///
    func attach(error: NSError, toMediaID mediaID: String) {
        guard let progress = mediaInProgress[mediaID] else {
            return
        }
        progress.setUserInfoObject(error, forKey: .mediaError)
    }

    // MARK: - Methods to check state of a mediaID process

    /// Return the error, if any, associated to the task with the provided mediaID.
    ///
    /// - Parameter mediaID: mediaID to search for error
    /// - Returns: the error value if any
    ///
    func error(forMediaID mediaID: String) -> NSError? {
        guard let progress = mediaInProgress[mediaID],
            let error = progress.userInfo[.mediaError] as? NSError
            else {
                return nil
        }

        return error
    }

    /// And Media object if any associated to the MediaID provided.
    ///
    /// - Parameter mediaID: the mediaID object to search for
    /// - Returns: the Media object associated
    ///
    func media(forMediaID mediaID: String) -> Media? {
        guard let progress = mediaInProgress[mediaID],
            let object = progress.userInfo[.mediaObject] as? Media
            else {
                return nil
        }

        return object
    }
    
    /// Returns the Progress object associated with a mediaID.
    ///
    /// - Parameter mediaID: the media ID to search for
    /// - Returns: a Progress object associated with the MediaID
    ///
    func progress(forMediaID mediaID: String) -> Progress? {
        return mediaInProgress[mediaID]
    }

    /// Returns, if any, a media object associated with the provided media ID.
    ///
    /// - Parameter mediaID: the media ID to search for
    /// - Returns: the Media object
    //
    func isMediaInProgress(mediaID: String) -> Bool {
        if let mediaProgress = mediaInProgress[mediaID],
            mediaProgress.completedUnitCount < mediaProgress.totalUnitCount {
            return true
        }
        return false
    }

    /// The global value of progress for all task being runned.
    ///
    var totalProgress: Float {
        var value = Float(0)
        if let progress = mediaGlobalProgress {
            value = Float(progress.fractionCompleted)
        }
        return value
    }
    
    /// Returns true if any task is still ongoing.
    ///
    var isRunning: Bool {
        guard let progress = mediaGlobalProgress else {
            return false
        }

        if progress.isCancelled {
            return false
        }

        if mediaInProgress.isEmpty {
            return progress.completedUnitCount < progress.totalUnitCount
        }

        for progress in mediaInProgress.values {
            if !progress.isCancelled && (progress.totalUnitCount != progress.completedUnitCount) {
                return true
            }
        }
        return false
    }

    /// Returns true if any of media tasks being tracked have an error associated.
    ///
    var hasFailedMedia: Bool {
        for progress in mediaInProgress.values {
            if !progress.isCancelled && progress.userInfo[.mediaError] != nil {
                return true
            }
        }
        return false
    }

    /// Returns a list of media IDs that were cancelled,
    ///
    var cancelledMediaIDs: [String] {
        var mediaIDs = [String]()
        for (key, progress) in mediaInProgress {
            if progress.isCancelled {
                mediaIDs.append(key)
            }
        }
        return mediaIDs
    }

    /// Returns a list of media IDs that are still uploading.
    ///
    var inProgressMediaIDs: [String] {
        var mediaIDs = [String]()
        for (key, progress) in mediaInProgress {
            if !progress.isCancelled && progress.userInfo[.mediaError] == nil {
                mediaIDs.append(key)
            }
        }
        return mediaIDs
    }

    /// Returns a list of all media ID that have an error attached
    ///
    var failedMediaIDs: [String] {
        var failedMediaIDs = [String]()
        for (key, progress) in mediaInProgress {
            if !progress.isCancelled && progress.userInfo[.mediaError] != nil {
                failedMediaIDs.append(key)
            }
        }
        return failedMediaIDs
    }

    // MARK: - KeyPath observer method for the global progress property
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard
            context == &mediaProgressObserverContext,
            keyPath == #keyPath(Progress.fractionCompleted)
            else {
                super.observeValue(forKeyPath: keyPath,
                                   of: object,
                                   change: change,
                                   context: context)
                return
        }

        DispatchQueue.main.async {
            self.refreshMediaProgress()
        }
    }

    private func refreshMediaProgress() {

        delegate?.mediaProgressCoordinator(self, progressDidChange: totalProgress)

        if !isRunning {
            delegate?.mediaProgressCoordinatorDidFinishUpload(self)
        }
    }

    // MARK: - Actions

    /// Cancels and stop tracking of progress for a media upload
    ///
    /// - Parameter mediaID: the identifier for the media
    ///
    func cancelAndStopTrack(of mediaID: String) {
        guard let mediaProgress = mediaInProgress[mediaID] else {
            return
        }
        if mediaProgress.completedUnitCount < mediaProgress.totalUnitCount {
            mediaProgress.cancel()
        }
        mediaInProgress.removeValue(forKey: mediaID)
    }

    /// Cancels all pending uploads and stops tracking the progress of them
    ///
    func cancelAndStopAllInProgressMedia() {
        let pendingUploadIds = mediaInProgress.keys

        for mediaID in pendingUploadIds {
            cancelAndStopTrack(of: mediaID)
        }

        mediaGlobalProgress?.cancel()
    }

    /// Stop trackings all media uploads and resets the global progress tracking
    ///
    func stopTrackingOfAllMedia() {
        if let mediaUploadingProgress = mediaGlobalProgress, !isRunning {
            mediaUploadingProgress.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
            mediaGlobalProgress = nil
        }
        mediaInProgress.removeAll()
    }

    /// Stop tracking of all media uploads that are in failed/error state.
    ///
    func stopTrackingAllFailedMedia() {
        for key in failedMediaIDs {
            mediaInProgress.removeValue(forKey: key)
        }
    }

}
