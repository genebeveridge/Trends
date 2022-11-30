//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./TrendTools.sol";
import "./Market.sol";

contract CrossoverMarket is Market {

    // link to specific synth
    // These parameters define the behavior (entry, exit and stop) of this trend module. Stored as state variables.
    uint fastMAPeriod;
    uint slowMAPeriod;
    int[] fastMAPrices; // i=0 is today, i=n is n days ago.
    int[] slowMAPrices; // i=0 is today, i=n is n days ago.

    constructor() {
        // Set up the unique parameters of this trend module. 
        // Design decision up for debate: Since these may be plugged into my multiple portfolios,
        // parameter preference by potfolio managers must be done by withdrawing from one module and investing in a prefered one.
        trendType = TrendType.crossover;
        fastMAPeriod = 100; // From msg.sender.
        fastMAPeriod = 50; // From msg.sender.
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

    function updateCrossoverSignal() internal {
        fastMAPrices = updateEma(prices, fastMAPrices, fastMAPeriod);
        slowMAPrices = updateEma(prices, slowMAPrices, slowMAPeriod);

        if(fastMAPrices[0] > slowMAPrices[0]) { // Trending up
            marketSignal = Position.long;
        }
        else if(fastMAPrices[0] < slowMAPrices[0]) { // Trending down
            marketSignal = Position.short;
        }
    }
    

    
}

