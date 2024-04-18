// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {OldClaim} from "../src/OldClaim.sol";
import {DeployMyToken, MyToken} from "./DeployMyToken.s.sol";

contract DeployOldClaim is Script {
    function run() external returns (OldClaim claim, MyToken myToken) {
        DeployMyToken deployer = new DeployMyToken();
        myToken = deployer.run();
        vm.startBroadcast();
        claim = new OldClaim(address(myToken));
        myToken.transfer(address(claim), 1000e18);
        vm.stopBroadcast();
    }
}
