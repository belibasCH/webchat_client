module Services.CryptoStringAes exposing (doDecrypt, doEncrypt)

import Crypto.Strings exposing (decrypt, encrypt)
import Crypto.Strings.Types exposing (Passphrase, Plaintext, Ciphertext)
import Random exposing (Seed, initialSeed)

{-| In real code, you'd pass in a seed created from a time, not a time.
-}
doEncrypt : Int -> Passphrase -> Plaintext -> Result String ( Ciphertext, Seed )
doEncrypt time passphrase plaintext =
    encrypt (initialSeed time) passphrase plaintext

doDecrypt : Passphrase -> Ciphertext -> Result String Plaintext
doDecrypt passphrase ciphertext =
    decrypt passphrase ciphertext