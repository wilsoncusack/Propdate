// SPDX-License-Identifier: UNLICEMITNSED
pragma solidity ^0.8.17;

import "src/Propdates.sol";
import "./PropdatesBase.t.sol";

contract PostUpdateTest is PropdatesBaseTest {
    function testSetsIsCompleted() public {
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin);
        propdates.acceptPropUpdateAdmin(propId);
        propdates.postUpdate(propId, true, "Update 1");

        assertTrue(propdates.propdateInfo(propId).isCompleted);
    }

    function testSetsLastUpdated() public {
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin);
        propdates.acceptPropUpdateAdmin(propId);
        propdates.postUpdate(propId, true, "Update 1");

        assertEq(propdates.propdateInfo(propId).lastUpdated, block.timestamp);
    }

    event PostUpdate(uint256 indexed propId, bool indexed isCompleted, string update);

    function testEmitsPostUpdate() public {
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin);
        propdates.acceptPropUpdateAdmin(propId);

        vm.expectEmit(true, true, false, true);
        emit PostUpdate(propId, true, "Update 1");
        propdates.postUpdate(propId, true, "Update 1");
    }

    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);

    function testAcceptsPendingAdmin() public {
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.prank(newAdmin);

        vm.expectEmit(true, true, true, false);
        emit PropUpdateAdminTransfered(propId, address(0), newAdmin);
        propdates.postUpdate(propId, true, "Update 2");

        assertEq(newAdmin, propdates.propdateInfo(propId).propUpdateAdmin);
    }

    function testRevertsIfNotCurrentOrPendingAdmin() public {
        vm.expectRevert(Propdates.OnlyPropUpdateAdmin.selector);
        propdates.postUpdate(propId, true, "Update 3");
    }

    function testNoUnsetIsCompleted() public {
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin);
        propdates.acceptPropUpdateAdmin(propId);
        propdates.postUpdate(propId, true, "Update 4");
        propdates.postUpdate(propId, false, "Update 5");

        assertEq(true, propdates.propdateInfo(propId).isCompleted);
    }

    function testGasRefundWhenProposalExecuted() public {
        vm.txGasPrice(2);
        vm.deal(address(this), 10e18);
        payable(address(propdates)).send(10e18);
        propId = 284;
        address admin = address(0xb0b);
        vm.deal(address(admin), 10e18);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin, admin);
        propdates.acceptPropUpdateAdmin(propId);

        uint256 initialBalance = address(admin).balance;
        propdates.postUpdate(propId, true, "Update 1");
        uint256 finalBalance = address(admin).balance;
        // tx does not actually use gas, start balance of admin is 0
        assertGt(finalBalance, initialBalance, "Gas was not refunded");
    }

    function testGasRefundDoesNotCauseRevertIfNotFunded() public {
        vm.txGasPrice(2);
        // propdate contract has no funds
        // vm.deal(address(propdates), 10e18);
        propId = 284;
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin, admin);
        propdates.acceptPropUpdateAdmin(propId);

        uint256 initialBalance = address(admin).balance;
        propdates.postUpdate(propId, true, "Update 1");
        uint256 finalBalance = address(admin).balance;
        // tx does not actually use gas, start balance of admin is 0
        assertEq(finalBalance, initialBalance);
    }

    function testGasNotRefundedWhenProposalExecuted() public {
        vm.txGasPrice(2);
        vm.deal(address(propdates), 10e18);
        propId = 300;
        address admin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, admin);
        vm.startPrank(admin, admin);
        propdates.acceptPropUpdateAdmin(propId);

        uint256 initialBalance = address(admin).balance;
        propdates.postUpdate(propId, true, "Update 1");
        uint256 finalBalance = address(admin).balance;

        assertEq(finalBalance, initialBalance, "Gas was refunded");
    }
}
