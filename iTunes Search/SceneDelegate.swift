//
//  SceneDelegate.swift
//  iTunes Search
//
//  Created by Anmol Kalra on 03/04/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	private var appCoordinator: ApplicationCoordinator?
	
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
		let appCoordinator = ApplicationCoordinator(window: window)
        self.window = window
		self.appCoordinator = appCoordinator
		appCoordinator.start()
        window.makeKeyAndVisible()
    }
}
