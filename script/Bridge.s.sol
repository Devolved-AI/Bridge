// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Bridge.sol";

contract DeployBridge is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the Bridge contract
        Bridge bridge = new Bridge();

        // Log the address of the deployed contract
        console.log("Bridge contract deployed at:", address(bridge));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
