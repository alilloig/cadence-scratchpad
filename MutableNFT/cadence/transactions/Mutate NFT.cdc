import NonFungibleToken from "../../../lib/NonFungibleToken.cdc"
import Mutant from "../contracts/Mutant.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"

transaction (nftOwner: Address, id: UInt64) {
  let colRef: &{ExampleNFT.ExampleNFTCollectionPublic}
  let nftRef: &{Mutant.Mutable}
  let mutatorRef: &ExampleNFT.ExampleMutator

  prepare(admin: AuthAccount) {
    self.colRef = getAccount(nftOwner).getCapability(ExampleNFT.CollectionPublicPath).borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Cant borrow example nft public collection")
    
    self.nftRef = self.colRef.borrowExampleNFT(id: id)
        ?? panic("Cannot borrow NFT")

    self.mutatorRef = admin.borrow<&ExampleNFT.ExampleMutator>(from: ExampleNFT.MutatorStoragePath) 
        ?? panic("Cannot borrow NFT mutator")
  }

  execute {
    self.mutatorRef.mutateState(mutableRef: self.nftRef, state: "mutated")
  }
}