// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

/// @title relay with daily limit - Allows the relay to mint token in a daily limit.
contract DailyLimit {

    event DailyLimitChange(address token, uint dailyLimit);

    mapping(address => uint) public dailyLimit;
    mapping(address => uint) public lastDay;
    mapping(address => uint) public spentToday;

    /// ==== Internal functions ====

    /// @dev Contract constructor sets initial owners, required number of confirmations and daily mint limit.
    /// @param _token Token address.
    /// @param _dailyLimit Amount in wei, which can be mint without confirmations on a daily basis.
    function _setDailyLimit(address _token, uint _dailyLimit)
        internal
    {
        dailyLimit[_token] = _dailyLimit;
    }

    /// @dev Allows to change the daily limit.
    /// @param _token Token address.
    /// @param _dailyLimit Amount in wei.
    function _changeDailyLimit(address _token, uint _dailyLimit)
        internal
    {
        dailyLimit[_token] = _dailyLimit;
        emit DailyLimitChange(_token, _dailyLimit);
    }

    /// @dev Allows to change the daily limit.
    /// @param token Token address.
    /// @param amount Amount in wei.
    function expendDailyLimit(address token, uint amount)
        internal
    {
        require(isUnderDailyLimit(token, amount), "DailyLimit:: expendDailyLimit: Out ot daily limit.");
        spentToday[token] += amount;
    }

    /// @dev Returns if amount is within daily limit and resets spentToday after one day.
    /// @param token Token address.
    /// @param amount Amount to calc.
    /// @return Returns if amount is under daily limit.
    function isUnderDailyLimit(address token, uint amount)
        internal
        returns (bool)
    {
        if (now > lastDay[token] + 24 hours) {
            lastDay[token] = now;
            spentToday[token] = 0;
        }

        if (spentToday[token] + amount > dailyLimit[token] || spentToday[token] + amount < spentToday[token]) {
          return false;
        }

        return true;
    }

    /// ==== Web3 call functions ====

    /// @dev Returns maximum withdraw amount.
    /// @param token Token address.
    /// @return Returns amount.
    function calcMaxWithdraw(address token)
        public
        view
        returns (uint)
    {
        if (now > lastDay[token] + 24 hours) {
          return dailyLimit[token];
        }

        if (dailyLimit[token] < spentToday[token]) {
          return 0;
        }

        return dailyLimit[token] - spentToday[token];
    }
}