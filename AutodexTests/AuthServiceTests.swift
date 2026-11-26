//
//  AuthServiceTests.swift
//  AutodexTests
//
//  Created by Tom Tas on 20/11/2026.
//

import XCTest
@testable import Autodex

@MainActor
final class AuthServiceTests: XCTestCase {
    
    var authService: AuthService!
    
    override func setUp() async throws {
        try await super.setUp()
        authService = AuthService()
    }
    
    override func tearDown() async throws {
        authService.deconnexion()
        authService = nil
        try await super.tearDown()
    }
    
    // MARK: - Tests de Validation d'Email
    func testValidationEmailValide() {
        let emailsValides = [
            "etudiant@iutsd.uhp-nancy.fr",
            "tom.tas@gmail.com",
            "test_user+tag@domain.co.uk",
            "carlover99@apple.com"
        ]
        
        for email in emailsValides {
            XCTAssertTrue(authService.validerFormatEmail(email), "L'email \(email) devrait être considéré comme valide.")
        }
    }
    
    func testValidationEmailInvalide() {
        let emailsInvalides = [
            "",
            "etudiant",
            "etudiant@",
            "@domain.com",
            "etudiant@domain",
            "etudiant.domain.com",
            "etudiant @domain.com"
        ]
        
        for email in emailsInvalides {
            XCTAssertFalse(authService.validerFormatEmail(email), "L'email \(email) devrait être considéré comme invalide.")
        }
    }
    
    // MARK: - Tests de Validation des Identifiants
    func testValidationIdentifiantsReussite() {
        XCTAssertNoThrow(
            try authService.validerIdentifiants(email: "valid@autodex.fr", motDePasse: "Autodex2026!")
        )
    }
    
    func testValidationIdentifiantsEmailVide() {
        XCTAssertThrowsError(
            try authService.validerIdentifiants(email: "", motDePasse: "123456")
        ) { error in
            guard let err = error as? ErreurAuth,
                  case .erreurPersonnalisee(let msg) = err else {
                XCTFail("Type d'erreur inattendu")
                return
            }
            XCTAssertTrue(msg.contains("requise"))
        }
    }
    
    func testValidationIdentifiantsMotDePasseTropCourt() {
        XCTAssertThrowsError(
            try authService.validerIdentifiants(email: "valid@autodex.fr", motDePasse: "12345")
        ) { error in
            guard let err = error as? ErreurAuth,
                  case .erreurPersonnalisee(let msg) = err else {
                XCTFail("Type d'erreur inattendu")
                return
            }
            XCTAssertTrue(msg.contains("12 caractères"))
        }
    }
    
    // MARK: - Tests du Modèle UtilisateurAutodex
    func testModeleUtilisateurNomOuEmail() {
        let userAvecNom = UtilisateurAutodex(
            id: "uid123",
            email: "alyssia@autodex.fr",
            nomAffichage: "Alyssia Frey",
            fournisseur: .emailMotDePasse
        )
        XCTAssertEqual(userAvecNom.nomOuEmail, "Alyssia Frey")
        XCTAssertEqual(userAvecNom.initiales, "AF")
        
        let userSansNom = UtilisateurAutodex(
            id: "uid456",
            email: "baptiste@domain.com",
            nomAffichage: nil,
            fournisseur: .google
        )
        XCTAssertEqual(userSansNom.nomOuEmail, "Baptiste")
        XCTAssertEqual(userSansNom.initiales, "BA")
    }
    
    func testModeleUtilisateurFournisseur() {
        let userGoogle = UtilisateurAutodex(
            id: "gid1",
            email: "test@gmail.com",
            fournisseur: .google
        )
        XCTAssertEqual(userGoogle.fournisseur.libelle, "Google (Gmail)")
        XCTAssertEqual(userGoogle.fournisseur.iconeSysteme, "globe")
        
        let userEmail = UtilisateurAutodex(
            id: "eid1",
            email: "test@domain.com",
            fournisseur: .emailMotDePasse
        )
        XCTAssertEqual(userEmail.fournisseur.libelle, "Email")
        XCTAssertEqual(userEmail.fournisseur.iconeSysteme, "envelope.fill")
    }
    
    // MARK: - Tests Traduction des Erreurs Firebase
    func testTraductionErreursFirebase() {
        let erreurEmailInvalide = NSError(domain: "FIRAuthErrorDomain", code: 17008, userInfo: [NSLocalizedDescriptionKey: "invalid email"])
        XCTAssertEqual(authService.formaterErreur(erreurEmailInvalide), "L'adresse email saisie n'est pas valide.")
        
        let erreurUserNotFound = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: [NSLocalizedDescriptionKey: "user not found"])
        XCTAssertEqual(authService.formaterErreur(erreurUserNotFound), "Aucun compte trouvé avec cette adresse email.")
        
        let erreurWrongPassword = NSError(domain: "FIRAuthErrorDomain", code: 17009, userInfo: [NSLocalizedDescriptionKey: "wrong password"])
        XCTAssertEqual(authService.formaterErreur(erreurWrongPassword), "Mot de passe incorrect. Veuillez réessayer.")
        
        let erreurEmailInUse = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: [NSLocalizedDescriptionKey: "email already in use"])
        XCTAssertEqual(authService.formaterErreur(erreurEmailInUse), "Un compte existe déjà avec cette adresse email. Veuillez vous connecter.")
        
        let erreurWeakPassword = NSError(domain: "FIRAuthErrorDomain", code: 17026, userInfo: [NSLocalizedDescriptionKey: "weak password"])
        XCTAssertEqual(authService.formaterErreur(erreurWeakPassword), "Le mot de passe est trop court (au moins 6 caractères requis).")
        
        let erreurGoogleAnnulee = NSError(domain: "com.google.GIDSignIn", code: -5, userInfo: [NSLocalizedDescriptionKey: "canceled"])
        XCTAssertEqual(authService.formaterErreur(erreurGoogleAnnulee), "Connexion Google annulée.")
    }
    
    // MARK: - Tests Déconnexion
    func testDeconnexionReinitialiseUtilisateur() {
        authService.utilisateurCourant = UtilisateurAutodex(
            id: "123",
            email: "test@autodex.fr"
        )
        XCTAssertTrue(authService.estConnecte)
        
        authService.deconnexion()
        
        XCTAssertFalse(authService.estConnecte)
        XCTAssertNil(authService.utilisateurCourant)
        XCTAssertNil(authService.messageErreur)
    }
    
    // MARK: - Tests Conformité CNIL / RGPD (Mot de passe)
    func testValidationMotDePasseCNIL() {
        // Trop court (< 12 caractères)
        XCTAssertFalse(authService.verifierComplexiteMotDePasseCNIL("Abc123!").isEmpty)
        // Sans majuscule
        XCTAssertFalse(authService.verifierComplexiteMotDePasseCNIL("autodex1234!").isEmpty)
        // Sans minuscule
        XCTAssertFalse(authService.verifierComplexiteMotDePasseCNIL("AUTODEX1234!").isEmpty)
        // Sans chiffre
        XCTAssertFalse(authService.verifierComplexiteMotDePasseCNIL("AutodexSuper!").isEmpty)
        // Sans caractère spécial
        XCTAssertFalse(authService.verifierComplexiteMotDePasseCNIL("Autodex12345").isEmpty)
        // Conforme CNIL (12+ car., maj, min, chiffre, spécial)
        XCTAssertTrue(authService.verifierComplexiteMotDePasseCNIL("Autodex2026!").isEmpty)
        XCTAssertNoThrow(try authService.validerIdentifiants(email: "tom@autodex.fr", motDePasse: "Autodex2026!"))
    }
}
