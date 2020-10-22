
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

contract Timelock {
  uint256 private _minDelay;

  event MinDelayChange(uint256 oldDuration, uint256 newDuration);

  function getMinDelay() public view returns (uint256 duration) {
      return _minDelay;
  }

  function _updateDelay(uint256 newDelay) internal {
    _minDelay = newDelay;
    emit MinDelayChange(_minDelay, newDelay);
  }

  function isOperationPending(uint256 timestamps) public view returns (bool pending) {
    require(timestamps > now, "TimeLock: Time is greater than the blockchain timestamp");
    return (timestamps - now) < getMinDelay();
  }

  function isOperationDone(uint256 timestamps) public view returns (bool pending) {
     require(timestamps > now, "TimeLock: Time is greater than the blockchain timestamp");
    return (timestamps - now) > getMinDelay();
  }
}
