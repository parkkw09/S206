//
//  AppDelegate.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    let container = {
//        let container = Container()
//        // 모듈을 등록하라
//        // container.register(Animal.self) { _ in Cat(name: "Mimi") }
//        container.register(SeoulRepository.self) { _ in SeoulRepositoryImpl(_source: SeoulApi()) }
//        container.register(SeoulUsecase.self) { resolver in SeoulUsecaseImpl(repo: resolver.resolve(SeoulRepository.self)) }
//        container.register(MainViewController.self) { resolver in
//            let controller = MainViewController()
//            // 뷰 컨트롤러에 모듈 주입
//            controller.seoulUsecase = resolver.resolve(SeoulUsecase.self)
//            return controller
//        }
//        return container
//    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // sleep(1)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

