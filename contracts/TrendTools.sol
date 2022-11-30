//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract TrendTools {
    // For generical definitions and functions

    enum Position{long, short, none} // used to aid the logic of some fuctions 
    enum TrendType{breakout, crossover}

    struct MatchAddress {
        bool success;
        uint index;
    }

    struct Price {
        int high;
        int low;
        int open;
        int close;
    }

    function updateEma(Price[] memory _prices, int[] memory _previousEmaValues, uint _period) internal pure returns (int[] memory) {
        require(_prices.length == _previousEmaValues.length + 1, "Prices array must be 1 longer than EMA array to calculate new EMA");

        _period = uint(min2(int(_period), int(_prices.length))); // reduce EMA period for early in the series when not enough data is available. Best to ignore eary data in CrossoverMarket.
        int[] memory _ema = _previousEmaValues;
        uint emaSmoothing = 2;

        if(_prices.length == 1) {
            _ema[0] = 0;
        }
        else { // Unsure if I can replace array.push() with this: 
            _ema[_ema.length-1] = ((_prices[_prices.length-1].close * int(emaSmoothing/(1 + _period))) + _previousEmaValues[_previousEmaValues.length-1] * int(1 - (emaSmoothing / (1 + _period))));
        }

        return _ema;
    }

    function updateEma2(int[] memory _priceValues, int[] memory _previousEmaValues, uint _period) internal pure returns (int[] memory) {
        require(_priceValues.length == _previousEmaValues.length + 1, "Prices array must be 1 longer than EMA array to calculate new EMA");

        _period = uint(min2(int(_period), int(_priceValues.length))); // reduce EMA period for early in the series when not enough data is available. Best to ignore eary data in CrossoverMarket.
        int[] memory _ema = _previousEmaValues;
        int emaSmoothing = 2;

        if(_priceValues.length == 1) {
            _ema[0] = 0;
        }
        else if(_priceValues.length < _period + 1) {
            _ema[_ema.length-1] = (calculateSma(_priceValues, _period));
        }
        else {
            _ema[_ema.length-1] = ((_priceValues[_priceValues.length-1] * (emaSmoothing/(1 + int(_period)))) + _previousEmaValues[_previousEmaValues.length-1] * ( 1 - (emaSmoothing / (1 + int(_period)))));
        }

        return _ema;
    }
    
    function calculateSma(int[] memory _values, uint _period) internal pure returns (int) {
        require(_values.length >= _period, "Not enough data to calculate sma");
        int _sma = 0;

        for(uint i = 0; i < _period; i++) {
            _sma = _sma + _values[_values.length - i];
        }

        _sma = _sma / int(_period);
        return _sma;
    }

    function getMatchAddress(address _valueToMatch, address[] memory _values) internal pure returns (MatchAddress memory) {
        require(_values.length > 0);

        MatchAddress memory matchAddress = MatchAddress({success: false, index: 0});

        for(uint i; i < _values.length; i++) {
            if(_values[i] == _valueToMatch) {
                matchAddress.success = true;
                matchAddress.index = i;
                break;
            }
        }
        
        return matchAddress;
    }
    
    function max2(int _num1, int _num2) internal pure returns (int) {
        int _maxNum;

        if (_num1 >= _num2) { 
            _maxNum = _num1; 
        }
        else { 
            _maxNum = _num2;
        }

        return _maxNum;
    }

    function max3(int _num1, int _num2, int _num3) internal pure returns (int) {
        int _maxNum;

        if (_num1 >= _num2) { 
            // num1 is larger than num2
            if (_num1 >= _num3) { 
                // and num3
                _maxNum = _num1; 
            }
            else { 
                // but num3 is larger than num1
                _maxNum = _num3; //  and num3 is larger than num1
            }
        }
        else { 
            // num2 is larger than num1
            if (_num2 >= _num3) { 
                // and num3
                _maxNum = _num2;
            }
            else {
                // but num3 is larger than num2
                _maxNum = _num3;
            }
        }

        return _maxNum;
    }

    function min2(int _num1, int _num2) internal pure returns (int) {
        int _minNum;

        if (_num1 <= _num2) { 
            _minNum = _num1; 
        }
        else { 
            _minNum = _num2;
        }

        return _minNum;
    }

    function abs(int _num) pure internal returns (uint) {
        if(_num < 0) {
            _num = -_num;
        }
        return uint(_num);
    }
}