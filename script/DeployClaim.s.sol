// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Claim} from "../src/Claim.sol";
import {DeployMyToken, MyToken} from "./DeployMyToken.s.sol";

contract DeployClaim is Script {
    function run() external returns (Claim claim, MyToken myToken) {
        DeployMyToken deployer = new DeployMyToken();
        myToken = deployer.run();
        vm.startBroadcast();
        claim = new Claim(address(myToken));
        myToken.transfer(address(claim), 1000e18);
        vm.stopBroadcast();
    }
}
