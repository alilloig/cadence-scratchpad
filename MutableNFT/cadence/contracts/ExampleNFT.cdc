/* 
*
*  This is an example implementation of a Flow Non-Fungible Token
*  It is not part of the official standard but it assumed to be
*  similar to how many NFTs would implement the core functionality.
*
*  This contract does not implement any sophisticated classification
*  system for its NFTs. It defines a simple NFT with minimal metadata.
*   
*/

import NonFungibleToken from "../../../lib/NonFungibleToken.cdc"
import Mutant from "./Mutant.cdc"

pub contract ExampleNFT: NonFungibleToken, Mutant {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionMutablePath: PublicPath
    pub let MinterStoragePath: StoragePath
    pub let MutatorStoragePath: StoragePath
    
    pub resource NFT: NonFungibleToken.INFT, Mutant.Mutable {
        
        pub let id: UInt64
        pub var state: AnyStruct

        init(
            state: AnyStruct
        ) {
            self.id = self.uuid
            self.state = state
        }

        pub fun mutate (state: AnyStruct, token: @{Mutant.AccessToken}) {
            let token <- token as! @ExampleNFT.AccessToken
            self.state = state
            destroy token
        }
    }


    pub resource AccessToken: Mutant.AccessToken {}


    pub resource interface ExampleNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowExampleNFT(id: UInt64): &ExampleNFT.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow ExampleNFT reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: ExampleNFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, 
                                                                NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @ExampleNFT.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }
 
        pub fun borrowExampleNFT(id: UInt64): &ExampleNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &ExampleNFT.NFT
            }
            return nil
        }


        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}) {

            // create a new NFT
            var newNFT <- create NFT(
                state: "base"
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            ExampleNFT.totalSupply = ExampleNFT.totalSupply + UInt64(1)

        }
    }

    pub resource ExampleMutator: Mutant.Mutator {

        pub fun grantAccess(): @{Mutant.AccessToken} {
            return <- create AccessToken()
        }

        pub fun mutateState (mutableRef: &{Mutant.Mutable}, state: AnyStruct) {
            //let exampleRef: &ExampleNFT.NFT = nftRef as! &ExampleNFT.NFT
            mutableRef.mutate(state: state, token: <- self.grantAccess())
        }

        init() {
        }
    }


    init() {
        // Initialize the total supply
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/exampleNFTCollection
        self.CollectionPublicPath = /public/exampleNFTCollection
        self.CollectionMutablePath = /public/exampleNFTCollectionMutable
        self.MinterStoragePath = /storage/exampleNFTMinter
        self.MutatorStoragePath = /storage/exampleNFTAccessGranter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        // 
        let mutator <- create ExampleMutator()
        self.account.save(<-mutator, to: self.MutatorStoragePath)

        emit ContractInitialized()
    }
}
