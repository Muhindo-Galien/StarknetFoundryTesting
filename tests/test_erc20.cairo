use core::traits::Into;
use testing_in_cairo::IERC20DispatcherTrait;
use testing_in_cairo::IERC20;
use core::result::ResultTrait;
use testing_in_cairo::ERC20;
use testing_in_cairo::IERC20Dispatcher;
use testing_in_cairo::IERC20SafeDispatcher;
use traits::TryInto;
use snforge_std::{declare, ContractClassTrait, CheatTarget, start_prank, stop_prank};
use starknet::ContractAddress;
use array::ArrayTrait;
use testing_in_cairo::Account::{user1, user2};
use debug::PrintTrait;

const token_name: felt252 = 'TestToken';
const token_symbol: felt252 = 'TT';
const token_decimals: u8 = 18;
const mint_amount: u256 = 10000;

fn deploy_contract() -> ContractAddress {
    let contract = declare('ERC20');
    let calldata = array![token_name, token_symbol, token_decimals.into()];
    let contract_address = contract.deploy(@calldata).unwrap();
    start_prank(CheatTarget::One(contract_address), user1());
    let dispatcher = IERC20Dispatcher { contract_address };
    dispatcher.mint(mint_amount);
    stop_prank(CheatTarget::One(contract_address));
    contract_address
}

mod Error {
    const INSUFFICIENT_BALANCE: felt252 = 'INSUFFICIENT_BALANCE';
    const INVALID_DECIMALS: felt252 = 'INVALID_DECIMALS';
    const INVALID_NAME: felt252 = 'INVALID_NAME';
    const INVALID_SYMBOL: felt252 = 'INVALID_SYMBOL';
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract();
    let dispatcher = IERC20Dispatcher { contract_address };
    let name = dispatcher.name();
    let symbol = dispatcher.symbol();
    let decimals = dispatcher.decimals();
    assert(name == token_name, Error::INVALID_NAME);
    assert(symbol == token_symbol, Error::INVALID_SYMBOL);
    assert(decimals.into() == token_decimals, Error::INVALID_DECIMALS);
}

#[test]
fn test_total_supply() {
    let contract_address = deploy_contract();
    let dispatcher = IERC20Dispatcher { contract_address };
    let total_supply = dispatcher.total_supply();
    // total_supply.print();
    assert(total_supply == mint_amount, 'INVALID_TOTAL_SUPPLY');
}

#[test]
fn test_balance_of_user1() {
    let contract_address = deploy_contract();
    let dispatcher = IERC20Dispatcher { contract_address };
    let balance = dispatcher.balance_of(user1());
    assert(balance == mint_amount, 'INVALID_BALANCE');
}

#[test]
fn test_transfer() {
    let contract_address = deploy_contract();
    let dispatcher = IERC20Dispatcher { contract_address };
    start_prank(CheatTarget::One(contract_address), user1());
    let amount = 100;
    dispatcher.transfer(user2(), amount);
    stop_prank(CheatTarget::One(contract_address));
    let balance1 = dispatcher.balance_of(user1());
    let balance2 = dispatcher.balance_of(user2());
    assert(balance1 == mint_amount - amount, 'INVALID_BALANCE');
    assert(balance2 == 100, 'INVALID_BALANCE');
}

