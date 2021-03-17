//  Loader, which can be observed.
public protocol ObservableLoader: AnyObject {
    
    /// Starts observing the loader state change.
    ///
    /// - Parameter changeHandler: State change handler.
    /// - Returns: An instance of `LoaderObservation` to cancel observation.
    func observe(_ changeHandler: @escaping () -> Void) -> LoaderObservation
}
