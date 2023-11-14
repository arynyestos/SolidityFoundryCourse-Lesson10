// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
// import {StdCheats} from "forge-std/StdCheats.sol"; // Esto creo que es para ayudar a ChatGPT 

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {

    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        console.log("Test this", address(this));
        console.log("Test this balance", ourToken.balanceOf(address(this)));
        console.log("Test msg.sender", msg.sender);
        console.log("Test msg.sender balance", ourToken.balanceOf(msg.sender));

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowanceWorks() public {
        uint256 initialAllowance = 1000;
        
        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }
        
    function testTransfer() public {
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        uint256 transferAmount = 100;
        vm.prank(msg.sender);
        ourToken.transfer(address(0x1), transferAmount);
        uint256 finalBalance = ourToken.balanceOf(msg.sender);
        assertEq(finalBalance, initialBalance - transferAmount);
    }

    function testTransferFrom() public {
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        console.log("Initial balance: ", initialBalance);
        uint256 transferAmount = 100;
        address receiver = address(0x1);
        vm.prank(msg.sender);
        ourToken.approve(address(this), transferAmount);
        ourToken.transferFrom(msg.sender, receiver, transferAmount);
        uint256 finalBalance = ourToken.balanceOf(msg.sender);
        console.log("Final balance: ",finalBalance);
        assertEq(finalBalance, initialBalance - transferAmount);
        assertEq(ourToken.balanceOf(receiver), transferAmount);
    }

    function testBalanceAfterTransfer() public {
        uint256 transferAmount = 1000;
        address receiver = address(0x1);
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        ourToken.transfer(receiver, transferAmount);
        assertEq(ourToken.balanceOf(msg.sender), initialBalance - transferAmount);
    }
}