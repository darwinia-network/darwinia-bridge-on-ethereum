pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DarwiniaRelay.sol";

contract TestDarwiniaRelay {

  function testInitialBalanceUsingDeployedContract() public {
    DarwiniaRelay meta = DarwiniaRelay(DeployedAddresses.DarwiniaRelay());

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 DarwiniaRelay initially");
  }

}
