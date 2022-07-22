import NonFungibleToken from "../../../lib/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"

// This script borrows an NFT from a collection
pub fun main(address: Address, id: UInt64) {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nftRef = collectionRef.borrowExampleNFT(id: id)

    log("nft state: ")
    log(nftRef!.state)
}