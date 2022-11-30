//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./TrendTools.sol";

interface ITrendPortfolio {
    function enterPosition(address _token, int _prices, int _stoploss) external returns (uint);
}
interface IBreakoutMarket {
    function updateBreakoutSignal() external;
}
interface ICrossoverMarket {
    function updateCrossoverSignal() external;
}

contract Market is TrendTools{
    Price[] prices;

    uint internal atrLookback; // days to lookback to calculate ATR. // Should be declared in module constructor from msg.sender.
    uint internal atrsToRisk; // stdDevs/ATRs to stop, and so likelihood on not getting stopped out. // Defined in constructor from msg.sender.
    uint internal atr;
    int stoploss;

    // General flags that apply to managing any market
    TrendType internal trendType;
    bool internal canGoLong;
    bool internal canGoShort;
    Position internal marketSignal;
    Position internal currentPosition; 
    address tokenLong;
    address tokenShort;

    address[] internal investors; // Tracks investors that funded curent position or are waiting to be included in the next position.
    uint[] internal investmentAmmount; // Tracks investment ammounts that funded curent trade. Must be synced with investors[].
    address[] internal investorsToAdd; // A list of investors that will fund next trade.
    address[] internal investorsToRemove; // A list of investors that will be removed from the investors list before teh next position is entered
    uint internal totalInvestmentAmmounts; // sUSD under control of module, will be 0 when until trade is placed,

    address internal addressTrendPortfolio;
    address internal addressBreakoutMarket;
    address internal addressCrossoverMarket;

    function calculateAtr (uint _atrLookback) internal view returns (uint) {
        // Updates the ATR based on data regarding a specific market.
        // Must be used in by a contract that has a Prices[] array.

        uint[] memory _atrArray = new uint[](_atrLookback);
        uint _atr = 0;

        require (prices.length >= _atrLookback, "Not enough data to calculate the ATR"); // check that enough price data is available to continue

        for (uint i = 0; i < _atrLookback; i++) {
            _atrArray[i] = uint(max3(prices[i].high-prices[i].low, prices[i].high-prices[i+1].close, prices[i+1].close-prices[i].low)); // average true ranges of each daying going back atrLookback days
            // Original formular: N = (19 * N[1] + ATR)/20 //weird moving average of the ATR, actually looks more gas efficient
            _atr = _atr + _atrArray[i]; // Sum all the ATR values with the _atrLookback range into one number.
        }

        _atr = _atr / _atrLookback; // Turn sum into average.

        return _atr;
    }

    function calculateStopLoss(uint _atrsToRisk, uint _atr, Position _tradeDirection) internal view returns (int) {
        // Sets the stop loss for a trade based on parameters from the market aggregator.
        int _stopLoss;

        if(_tradeDirection == Position.long) {
            // if direction is long, calculate stoploss below closing price
            _stopLoss = prices[0].close - int(_atrsToRisk) * int(_atr);
        }
        else if(_tradeDirection == Position.short) {
            // if direction is short, calculate stoploss above closing price
            _stopLoss = prices[0].close + int(_atrsToRisk) * int(_atr);
        }

        return _stopLoss;
    }

    function calculatePositionSize() internal view returns (uint) {
        return (atr * atrsToRisk) / uint(prices[0].close - stoploss);
    }

    function requestToEnterPosition() public {
        require(currentPosition == Position.none, "Can't enter position because trade is already placed");
        updateSignal();
        require(marketSignal != Position.none, "Position won't be entered since there is no trend signal for this market");

        // Calculate parameters from the module's side
        atr = calculateAtr(atrLookback);
        stoploss = calculateStopLoss(atrsToRisk, atr, marketSignal);
        
        // Loop through connected investors instructing them to enter the trade
        if(marketSignal == Position.long && canGoLong) {
            for(uint i = 0; i < investors.length; i++) {
                investmentAmmount[i] = ITrendPortfolio(addressTrendPortfolio).enterPosition(tokenLong, prices[prices.length-1].close, stoploss);
            }
        }
        else if(marketSignal == Position.short && canGoShort) {
            for(uint i = 0; i < investors.length; i++) {
                investmentAmmount[i] = ITrendPortfolio(addressTrendPortfolio).enterPosition(tokenShort, prices[prices.length-1].close, stoploss);
            }        
        }
    }

    function updateSignal() internal {
        if(trendType == TrendType.breakout) {
            IBreakoutMarket(addressBreakoutMarket).updateBreakoutSignal();
        }
        else if(trendType == TrendType.crossover) {
            ICrossoverMarket(addressCrossoverMarket).updateCrossoverSignal();
        }
    }

    function forceEnterPosition() public {
        // add special logic to allow an address to deploy its sUSD even though the entry signal triggered some time ago.
    }

    function exitPosition() external view {
        // Check the current price has hit exit or stoploss the threshold in the relevant direction.
        require(currentPosition != Position.none, "Can't close position since there is no position to close");

        uint[] memory ownershipPortion;
        for(uint i = 0; i < investmentAmmount.length; i++) {
            ownershipPortion[i] = investmentAmmount[i] / totalInvestmentAmmounts;
        }
        // Sell synths
    }

    function addInvestor(address _newInvestor) external {
        MatchAddress memory _matchAddress;
        require(_newInvestor == msg.sender);

        _matchAddress = getMatchAddress(_newInvestor, investors);
        require(_matchAddress.success == false); // prevent adding an investor twice

        _matchAddress = getMatchAddress(_newInvestor, investorsToAdd);
        require(_matchAddress.success == false); // Prevent adding an investor to the add list twice
                
        _matchAddress = getMatchAddress(_newInvestor, investorsToRemove);
        if(_matchAddress.success == true) { // Just prevent investor from being removed, and they will stay in
            delete investorsToRemove[_matchAddress.index];
        }
        else if(_matchAddress.success == false) { // 
            investorsToAdd.push(_newInvestor);
        }
    }

    function removeInvestor(address _newInvestor) external {
        require(_newInvestor == msg.sender, "You do not have permission to remove other investors from a trend market");

        investorsToAdd.push(_newInvestor);
    }
}
