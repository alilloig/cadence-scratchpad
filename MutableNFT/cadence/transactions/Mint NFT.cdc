import NonFungibleToken from "../../../lib/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"


/// This script uses the NFTMinter resource to mint a new NFT
/// It must be run with the account that has the minter resource
/// stored in /storage/NFTMinter

transaction(recipient: Address) {

    /// local variable for storing the minter reference
    let minter: &ExampleNFT.NFTMinter

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)
            ?? panic("Account does not store an object at the specified path")

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(recipient)
            .getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {
        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: self.recipientCollectionRef)
    }

}
 