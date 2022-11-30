//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Token {
    // Nameing variables
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // Token supply
    uint256 public totalSupply = 1000000;

    // address of contract owner
    address public owner;

    // mapping for account balances
    mapping(address => uint256) balances;

    // Transfer event for offchain apps to understand state of contract
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Contract initialization
    constructor () {
        // assign total supply to contract creator
        balances[msg.sender] = totalSupply;
        // make contract deployer the owner
        owner = msg.sender;
    }

    // Transfer tokens from one account to another from outside the contract only
    function transfer(address to, uint256 amount) external {
        // Check that the sender has enough tokens to send
        require(balances[msg.sender] >= amount, "Not enough tokens");

        console.log(
            "Transferring from %s to %s %s tokens",
            msg.sender,
            to,
            amount
        );

        // Transfer tokens
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain apps
        emit Transfer(msg.sender, to, amount);
    }

    // Read only, gas-free function to read an account balance
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}