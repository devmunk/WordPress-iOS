import WordPressFlux

fileprivate final class ReaderPostSerialiser {
    func serialise(_ post: ReaderPost) -> ReaderSavedForLaterPost {
        return ReaderSavedForLaterPost()
    }
}

final class SaveForLaterAction: PostAction {
    private struct Strings {
        static let postSaved = NSLocalizedString("Post saved.", comment: "Title of the notification presented in Reader when a post is saved for later")
        static let viewAll = NSLocalizedString("View All", comment: "Button in the notification presented in Reader when a post is saved for later")
    }

    private let serialiser = ReaderPostSerialiser()

    func execute(with post: ReaderPost, context: NSManagedObjectContext ) {
        toggleSavedForLater(post, context: context)
        //Should be presented only after save is successfull.
        presentSuccessNotice()
    }

    private func presentSuccessNotice() {
        let notice = Notice(title: Strings.postSaved,
                            feedbackType: .success,
                            actionTitle: Strings.viewAll,
                            actionHandler: {
                                self.showAll()
        })

        ActionDispatcher.dispatch(NoticeAction.post(notice))
    }

    private func showAll() {
        //Navigate to all saved for later
    }

    private func toggleSavedForLater(_ post: ReaderPost, context: NSManagedObjectContext) {
        // TODO. We are still dealing with mocks, this will have to be updated when the coredata model is updated
        post.isSavedForLater() ? remove(post, context: context) : save(post, context: context)
    }

    private func save(_ post: ReaderPost, context: NSManagedObjectContext) {
        let readerPostService = ReaderPostService(managedObjectContext: context)
        //readerPostService.toggleSavedForLater(post)
        let savedForLaterService = MockSaveForLaterService()
        savedForLaterService.add(serialiser.serialise(post))
    }

    private func remove(_ post: ReaderPost, context: NSManagedObjectContext) {
        let savedForLaterService = MockSaveForLaterService()
        if let postId = post.postID {
            savedForLaterService.remove(postId)
        }
    }
}