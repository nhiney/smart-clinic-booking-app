import Flutter
import UIKit
import FirebaseAuth

class SceneDelegate: FlutterSceneDelegate {

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        var unhandledContexts = Set<UIOpenURLContext>()
        for urlContext in URLContexts {
            let url = urlContext.url
            if Auth.auth().canHandle(url) {
            } else {
                unhandledContexts.insert(urlContext)
            }
        }
        
        if !unhandledContexts.isEmpty {
            super.scene(scene, openURLContexts: unhandledContexts)
        }
    }
}