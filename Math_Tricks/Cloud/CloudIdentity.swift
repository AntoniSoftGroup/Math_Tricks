import AuthenticationServices
import CryptoKit
import Security
import UIKit
import FirebaseCore
@preconcurrency import FirebaseAuth
@preconcurrency import GoogleSignIn

@MainActor
final class CloudIdentity: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    enum Provider { case apple, google }
    private var continuation: CheckedContinuation<(AuthCredential,String?),Error>?
    private var nonce: String?
    private var window: UIWindow?

    func credential(_ provider: Provider, from presenter: UIViewController) async throws -> (AuthCredential,String?) {
        switch provider {
        case .google:
            guard let clientID = FirebaseApp.app()?.options.clientID else { throw CloudError.unavailable }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID:clientID)
            let response = try await GIDSignIn.sharedInstance.signIn(withPresenting:presenter)
            guard let token = response.user.idToken?.tokenString else { throw CloudError.signIn }
            return (GoogleAuthProvider.credential(withIDToken:token,accessToken:response.user.accessToken.tokenString),nil)
        case .apple:
            guard continuation == nil, let window = presenter.viewIfLoaded?.window else { throw CloudError.unavailable }
            var random = [UInt8](repeating:0,count:32)
            guard SecRandomCopyBytes(kSecRandomDefault,random.count,&random) == errSecSuccess else { throw CloudError.signIn }
            let nonce = random.map { String(format:"%02x",$0) }.joined()
            self.nonce = nonce; self.window = window
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName,.email]
            request.nonce = SHA256.hash(data:Data(nonce.utf8)).map { String(format:"%02x",$0) }.joined()
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                let controller = ASAuthorizationController(authorizationRequests:[request])
                controller.delegate = self; controller.presentationContextProvider = self
                controller.performRequests()
            }
        }
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor { window! }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { continuation = nil; nonce = nil; window = nil }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce, let data = credential.identityToken, let token = String(data:data,encoding:.utf8) else {
            continuation?.resume(throwing:CloudError.signIn); return
        }
        let auth = OAuthProvider.appleCredential(withIDToken:token,rawNonce:nonce,fullName:credential.fullName)
        let code = credential.authorizationCode.flatMap { String(data:$0,encoding:.utf8) }
        continuation?.resume(returning:(auth,code))
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing:error); continuation = nil; nonce = nil; window = nil
    }
    func signOut() throws { try Auth.auth().signOut(); GIDSignIn.sharedInstance.signOut() }
}
