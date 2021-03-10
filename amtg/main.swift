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
    
    @Option(name: [.customShort("k"), .customLong("privateKey")], help: "Apple Music Private Key (base64)")
    var appleMusicPrivateKey: String
    
    @Option(name: [.customShort("i"), .customLong("keyId")], help: "Apple Music Key ID")
    var appleMusicKeyId: String
    
    @Option(name: [.customShort("t"), .customLong("teamID")], help: "Apple Developer Team ID")
    var appleDeveloperTeamId: String
    
    
    mutating func run() throws {
        let tokenHeader = Header(kid: appleMusicKeyId)
        
        struct TokenClaims: Claims {
            let iss: String
            let exp: Date
            let iat: Date
        }
        
        let tokenClaims = TokenClaims(iss: appleDeveloperTeamId,
                                      exp: Calendar.current.date(byAdding: DateComponents(second: 15000000), to: Date())!, // exp can be no longer than 6 months, this is slightly short to avoid server time differences
                                      iat: Date())
        
        let AppleMusicAPIToken = JWT(header: tokenHeader, claims: tokenClaims)
        
        let privateKey = Data(base64Encoded: appleMusicPrivateKey)!
        
        let jwtEncoder = JWTEncoder(jwtSigner: JWTSigner.es256(privateKey: privateKey))
        let encodedAppleMusicAPIToken = try jwtEncoder.encodeToString(AppleMusicAPIToken)
        
        print(encodedAppleMusicAPIToken)
    }
}

AMTG.main()
