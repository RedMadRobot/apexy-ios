# ApexyLoader
 
ApexyLoader is an add-on for Apexy that lets you store fetched data in memory and observe the loading state.
 
The main concepts of ApexyLoader are loader and state.
 
## Loader
 
A loader is an object that fetches, stores data, and notifies subscribers about loading state changes.
 
Loader inherits from `WebLoader`. When inheriting from this class you must specify the content type, which must be the same as the content type of `Endpoint`. For example `WebLoader<UserProfile>`.

In the example below a user profile loader is shown.

`UserProfileEndpoint` returns `UserProfile` and `UserProfileLoader` also must returns `UserProfile`.

```swift
import Foundation
import ApexyLoader

protocol UserProfileLoading: ContentLoading {
    var state: LoadingState<UserProfile> { get }
}

final class UserProfileLoader: WebLoader<UserProfile>, UserProfileLoading {
    func load() {
        guard startLoading() else { return }
        request(UserProfileEndpoint())
    }
}
```

When you create a Loader, you must pass a class that conforms to the `Client` protocol from the Apexy library.

Example of creating a loader using the Service Locator pattern:

```swift
import Apexy
import ApexyURLSession
import Foundation

final class ServiceLayer {
    static let shared = ServiceLayer()
    private init() {}
    
    private(set) lazy var userProfileLoader: UserProfileLoading = UserProfileLoader(apiClient: apiClient)
    
    private lazy var apiClient: Client = {
        URLSessionClient(baseURL: URL(string: "https://api.server.com")!, configuration: .ephemeral)
    }()
}
```

Example of passing a Loader to the `UIViewController`.

```swift
final class ProfileViewController: UIViewController {

    private let profileLoader: UserProfileLoading
    
    init(profileLoader: UserProfileLoading = ServiceLayer.shared.userProfileLoader) {
        self.profileLoader = profileLoader
        super.init(nibName: nil, bundle: nil)
    }
}
```

## Loading state

The `enum LoadingState<Content>` represents a loading state. It may have the following states:
- `initial` — initial state when content loading has not yet started.
- `loading(cache: Content?)` — content is loading, and there may be cached (previously loaded) content.
- `success(content: Content)` — content successfully loaded.
- `failure(error: Error, cache: Content?)` — unable to load content, there may be cached (previously loaded) content.

When you create a loader its initial state is `initial`. The loader has `startLoading()` method which must be called to change the state to `loading`. Immediately after the first call of this method the state of the loader becomes `loading(cache: nil)`. If an error occurs then the state becomes `failure(error: Error, cache: nil)`, otherwise `success(Content)`. If after successful content loading the loading content is repeated (e.g. by a pull to refresh), the `loading` and `failure` states will contain the previously loaded content in the `cache` argument.

<img src="resources/uml_state.png" width="650"/>

The state of multiple loaders can be combined using the `merge` method of `LoadingState`. This method takes a second state and closure which returns a new content based on the content of both states.

In the example below there are two states: the state of loading user info and the state of loading service list. The `merge` method combines these two states into one. Instead of two model objects: `User` and `Service` there will be one `UserServices`.

```swift
let userState = LoadingState<User>.loading(cache: nil)
let servicesState = LoadingState<[Service]>.success(content: 3)

let state = userState.merge(servicesState) { user, services in
    UserServices(user: user, services: services)
}

switch state {
case .initial:
    // initial state
case .loading(let userServices):
    // loading state with optional cache (info about user and list of services)
case .success(let userServices):
    // successfull state with info about user and list of services
case .failure(let error, let userServices):
    // failed state with optional cache (info about user and list of services)
}
```

## Observing loading state

The `observe` method is used to keep track of the loader state. As with RxSwift and Combine, and in the case of ApexyLoader you need to save the reference to the observer. To do this, you need to declare a variable of `LoaderObservation` type in class properties.

```swift
final class ProfileViewController: UIViewController {
    private var observer: LoaderObservation?
    ...
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = userProfileLoader.observe { [weak self] in
            guard let self = self else { return }
            
            switch self.userProfileLoader.state {
            case .initial:
                //
            case .loading(let cache):
                //
            case .success(let content):
                //
            case .failure(let error, let cache):
                //
            }
        }
    }
}
```

## Use cases

ApexyLoader used in the following scenarios:
1. When you want to store the loaded data in memory.
For example, to use previously loaded data instead of loading it again each time you open a screen.
2. The fetch progress and the fetched data itself are displayed on different screens.
For example, one screen may have a button that initiates a long loading operation. Once the data is fetched, it may be displayed on different screens. The loading process itself may also be displayed on different screens.

3. When you want to load data from multiple sources and show the loading process and the result as a whole.

Example:

<img src="resources/img_1.png"/>

In this app, the main screen loads a lot of data from different sources: a list of cameras, intercoms, barriers, notifications, user profile. Each loader has its own state. The states of all loaders can be combined into one state and show the result of loading as a whole.

The camera list loader is reused on the camera list screen. When you go to the camera list screen, you can immediately display the previously loaded data. If you make pull-to-refresh on this screen, the camera list on the main screen will also be updated.

## Example project

In the `ApexyLoaderExample` folder, you can see an example of how to use the `ApexyLoader`. 

This app consists of two screens. On the first screen, you can start downloading data, see the download progress and the result (list of repositories and organization name). On the second screen, you can see the download progress and the result (list of repositories).

This example demonstrates how to use a shared loader between multiple screens, how to observe the loading state, and to merge the states.

<img src="resources/demo.gif"/>
