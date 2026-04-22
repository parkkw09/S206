//
//  SceneDelegate.swift
//  S206
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Info.plist 의 UISceneStoryboardFile=Main 에 의해 window·rootVC 가 이미 생성되어 있음.
        // Storyboard 가 만든 인스턴스에 의존성을 주입합니다.
        if let mainVC = window?.rootViewController as? MainViewController {
            appDelegate.appContainer.inject(into: mainVC)
        } else {
            // Storyboard 자동 로딩이 꺼져 있는 경우를 위한 수동 경로.
            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainVC = storyboard.instantiateInitialViewController() as? MainViewController else {
                fatalError("Main storyboard 의 initial VC 가 MainViewController 가 아닙니다.")
            }
            appDelegate.appContainer.inject(into: mainVC)
            window.rootViewController = mainVC
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
