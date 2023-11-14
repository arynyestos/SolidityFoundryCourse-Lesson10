// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";
import {console} from "forge-std/console.sol";

contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns(OurToken) {
        vm.startBroadcast();
        OurToken ourtToken = new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        // console.log("Deploy contract address", address(this));
        // console.log("Deployer sender", msg.sender);
        return ourtToken;
    }

}