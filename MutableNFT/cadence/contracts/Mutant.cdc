pub contract interface Mutant {

    pub resource interface Mutable {
        access(contract) state: AnyStruct
        pub fun mutate (state: AnyStruct, token: @{AccessToken})
    }
    
    pub resource interface AccessToken {}

    pub resource interface Mutator {
        pub fun grantAccess(): @{AccessToken} 
        pub fun mutateState (mutableRef: &{Mutable}, state: AnyStruct)
    }
    
}