//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TrendTools.sol";

interface ITrendTools {
    function abs(int _num) external returns (uint);
}

abstract contract TrendPortfolio is Context, ERC20 {
// This is a tokenised portfolio that has received sUSD to deploy pending signals from trend modules.

    uint internal riskAppetite; // portion of invested capital risked on each trade measured in bps = n(price-stop), where n is the number of synths purchased.
    uint internal accountEquity; // total amout of closed-trade equity (measured in sUSD) in all TrendMarket modules managed by this TrendPortfolio.

    mapping(address => uint) modules; // list of modules that have been invested into.
    mapping(address => uint) positionSize; // list of sizes of positions managed my easch connected module.

    mapping(address => uint) investors; // ERC-20 token for managing investors.

    mapping(address => uint) pendingWithdrawals; // addresses that have returned their ERC-20 tokens, but have and owed balance of sUSD. 

    address addressTrendTools;

    event enteredPostion(address _token, int _price, uint _postionSize);

    constructor() {
        riskAppetite = 200;
    }

    function receiveInvestments() public {
        // Receive sUSD from investors, update investments mapping and totalInvestment
        // Issue ERC-20 token to represent share of ownership of portfolio.

        uint _newCapital; // From msg.sender

        accountEquity = accountEquity + _newCapital;
    }

    function requestWithdrawal() public {
        // Get msg.sender added to the bottom of the withdrawl list.
    }

    function withdrawInvestments(address _address, uint ammout) public {
        // send sUSD to address and burn ERC-20 tokens
    }

    function receiveProfits(address _moduleAddress, uint ammount) public {
        // take account of sUSD returned from a closed trade
    }

    function connectModule() public {
        // Add a new module from msg.sender

        // Receive ERC-20 token to represent share of ownership and can be sold for instant liquidity

        // Deposit sUSD
    }

    function removeModule() public {
        // Remove a new module from msg.sender

        // Return the module's ERC-20 token

        // Ask for sUSD back
    } 

    function enterPosition(address _token, int _price, int _stoploss) external returns (uint) { // Called from TrendModule
        // Module has detected a signal and now needs to trigger investors to enter trade. 

        uint _postionSize = getPostionSize(_price, _stoploss);

        // Enter a position with available sUSD by trading sUSD for specific synth

        emit enteredPostion(_token, _price, _postionSize); // Could be done here or in the Market module
        return _postionSize;
    }

    function getPostionSize(int _price, int _stoploss) internal returns (uint) {
        uint _riskPerTrade = riskAppetite * accountEquity;
        uint _postiontSize = _riskPerTrade / ITrendTools(addressTrendTools).abs(_price - _stoploss);


        return _postiontSize;
    }

    
}


