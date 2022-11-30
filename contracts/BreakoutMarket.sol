//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./TrendTools.sol";
import "./Market.sol";

contract TrendMarket is Market {

    // link to specific synth

    // These parameters define the behavior (entry, exit and stop) of this trend module. Stored as state variables.
    uint internal entryLookBackPeriod; // days to look back. // Should be declared in module constructor from msg.sender.
    uint internal exitLookBackPeriod; // days to look back. // Should be declared in module constructor from msg.sender.

    int internal breakoutEntryThreshold;
    int internal breakoutExitThreshold;
    int internal breakdownEntryThreshold;
    int internal breakdownExitThreshold;

    //Investment[] investments; // Tracks investments (investors and investmentAmmount) that funded curent position (ammount > 0) or will fund next trade (ammount = 0).

    constructor() {
        // Set up the unique parameters of this trend module. 
        // Design decision up for debate: Since these may be plugged into my multiple portfolios,
        // parameter preference by potfolio managers must be done by withdrawing from one module and investing in a prefered one.
        trendType = TrendType.breakout;
        entryLookBackPeriod = 100; // From msg.sender.
        exitLookBackPeriod = 50; // From msg.sender.
        atrLookback = 20; // From msg.sender.
        atrsToRisk = 2; // From msg.sender.
        //MarketDirection marketDirection = Direction.LONGSHORT; // From msg.sender.
        canGoLong = true; // From msg.sender.
        canGoShort = true; // From msg.sender.

        marketSignal = Position.none;
        currentPosition = Position.none;

        //tokenLong = 0x123
        //tokenShort =0xabc
    }

    function updateBreakoutEntrySignal() internal returns (Position) {

    }

    function updateBreakoutSignal(uint _LookBackPeriod) internal view returns (Position) {
        // Updates the entry and exit signal for both breakouts and breakdowns for a specific market.
        int[] memory _prices;

        for(uint i = 0; i < _LookBackPeriod; i++) {
            _prices[i] = prices[i].close;
        }

        Position _signal = Position.none;

        if(_prices[0] > caclulatePreviousHigh(_prices, _LookBackPeriod)) {
            _signal = Position.long;
        }
        else if(_prices[0] < calculatePreviousLow(_prices, _LookBackPeriod)) {
            _signal = Position.short;
        }
        return _signal;
    }

    function caclulatePreviousHigh(int[] memory _prices, uint _LookBackPeriod) internal pure returns (int) {
        int _previousHigh = 0;

        for (uint i = 0; i < _LookBackPeriod - 1; i++) {
            if((_prices[_prices.length - _LookBackPeriod + i]) > _previousHigh) {
                _previousHigh = _prices[_prices.length - _LookBackPeriod + i];
            }
        }
        return _previousHigh;

    }

    function calculatePreviousLow(int[] memory _prices, uint _LookBackPeriod) internal pure returns (int) {
        int _previousLow = 0;

        for (uint i = 0; i < _LookBackPeriod - 1; i++) {
            if((_prices[_prices.length - _LookBackPeriod + i]) < _previousLow) {
                _previousLow = _prices[_prices.length - _LookBackPeriod + i];
            }
        }
        return _previousLow;
    }
}

