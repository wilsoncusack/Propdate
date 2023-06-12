// SPDX-License-Identifier: UNLICENSED
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
}
