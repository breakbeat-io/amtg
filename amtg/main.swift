//
//  main.swift
//  amtg
//
//  Created by Greg Hepworth on 10/01/2021.
//

import Foundation
import ArgumentParser
import SwiftJWT

struct AMTG: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Creates an Apple Music API Token")
    
    @Option(name: [.customShort("k"), .customLong("keyId")], help: "Apple Music Key ID")
    var appleMusicKeyId: String
    
    @Option(name: [.customShort("t"), .customLong("teamID")], help: "Apple Developer Team ID")
    var appleDeveloperTeamId: String
    
    @Option(name: [.customShort("p"), .customLong("privateKeyPath")], help: "Path to Apple Music Private Key (.p8)")
    var appleMusicPrivateKeyPath: String
    
    mutating func run() throws {
        let tokenHeader = Header(kid: appleMusicKeyId)

        struct TokenClaims: Claims {
            let iss: String
            let exp: Date
            let iat: Date
        }

        let tokenClaims = TokenClaims(iss: appleDeveloperTeamId,
                                exp: Calendar.current.date(byAdding: DateComponents(month: 6), to: Date())!,
                                iat: Date())

        let AppleMusicAPIToken = JWT(header: tokenHeader, claims: tokenClaims)

        let privateKeyPath = URL(fileURLWithPath: appleMusicPrivateKeyPath)
        let privateKey = try Data(contentsOf: privateKeyPath)

        let jwtEncoder = JWTEncoder(jwtSigner: JWTSigner.es256(privateKey: privateKey))
        let encodedAppleMusicAPIToken = try jwtEncoder.encodeToString(AppleMusicAPIToken)

        print(encodedAppleMusicAPIToken)
    }
}

AMTG.main()
