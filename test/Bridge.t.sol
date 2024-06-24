// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Bridge.sol";

contract ERC20Mock is IERC20 {
    string public name = "Mock Token";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**18;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract BridgeTest is Test {
    Bridge public bridge;
    ERC20Mock public token;
    address public user = address(0x123);
    address public owner = address(this);

    function setUp() public {
        bridge = new Bridge();
        token = new ERC20Mock();
        token.transfer(user, 1000 * 10**18);
    }

    function testInitiateTransfer() public {
        vm.startPrank(user);
        token.approve(address(bridge), 100 * 10**18);
        bridge.initiateTransfer(address(token), 100 * 10**18, "destinationChain", owner);
        vm.stopPrank();

        assertEq(token.balanceOf(address(bridge)), 100 * 10**18);
        assertEq(bridge.lockedFunds(address(token), "destinationChain"), 100 * 10**18);
    }

    function testCompleteTransfer() public {
        vm.startPrank(user);
        token.approve(address(bridge), 100 * 10**18);
        bridge.initiateTransfer(address(token), 100 * 10**18, "destinationChain", owner);
        vm.stopPrank();

        uint256 initialOwnerBalance = token.balanceOf(owner);

        bridge.completeTransfer(address(token), 100 * 10**18, "destinationChain", owner);

        assertEq(token.balanceOf(owner), initialOwnerBalance + 100 * 10**18);
        assertEq(bridge.lockedFunds(address(token), "destinationChain"), 0);
    }

    function testOnlyOwnerCanCompleteTransfer() public {
        vm.startPrank(user);
        token.approve(address(bridge), 100 * 10**18);
        bridge.initiateTransfer(address(token), 100 * 10**18, "destinationChain", owner);
        vm.stopPrank();

        vm.prank(user);
        vm.expectRevert("Only the owner can call this function");
        bridge.completeTransfer(address(token), 100 * 10**18, "destinationChain", owner);
    }

    function testInsufficientLockedFunds() public {
        vm.startPrank(user);
        token.approve(address(bridge), 100 * 10**18);
        bridge.initiateTransfer(address(token), 100 * 10**18, "destinationChain", owner);
        vm.stopPrank();

        vm.expectRevert("Insufficient locked funds");
        bridge.completeTransfer(address(token), 200 * 10**18, "destinationChain", owner);
    }
}
