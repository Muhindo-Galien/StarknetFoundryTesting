#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[external(v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}

// unit testing

#[cfg(test)]
mod tests {
    use testing_in_cairo::IHelloStarknetDispatcherTrait;
    use core::result::ResultTrait;
    use super::HelloStarknet;
    use super::IHelloStarknetDispatcher;
    use snforge_std::{declare, ContractClassTrait};
    use starknet::ContractAddress;
    use array::ArrayTrait;

    mod Error {
        const INVALID_BALANCE: felt252 = 'Invalid balance';
    }

    const balance_to_increase: felt252 = 100;

    fn deploy_contract() -> ContractAddress {
        let contract = declare('HelloStarknet');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
        contract_address
    }

    //helper function
    #[test]
    fn test_increse_balance() {
        let contract_address = deploy_contract();
        let dispatcher = IHelloStarknetDispatcher { contract_address };
        dispatcher.increase_balance(balance_to_increase);
        let balance = dispatcher.get_balance();
        assert(balance == balance_to_increase, Error::INVALID_BALANCE);
    }

    #[test]
    fn test_get_balance() {
        let contract_address = deploy_contract();
        let dispatcher = IHelloStarknetDispatcher { contract_address };
        let balance = dispatcher.get_balance();
        assert(balance == 0, Error::INVALID_BALANCE);
    }

    #[test]
    #[should_panic(expected: ('Amount cannot be 0',))]
    fn test_increse_balance_zero() {
        let contract_address = deploy_contract();
        let dispatcher = IHelloStarknetDispatcher { contract_address };
        dispatcher.increase_balance(0);
    }
}
// intergration testing


