// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() external returns (MyToken) {
        vm.startBroadcast();
        MyToken myToken = new MyToken();
        vm.stopBroadcast();
        return myToken;
    }
}
