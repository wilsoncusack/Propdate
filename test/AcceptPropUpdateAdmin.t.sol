// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/Propdates.sol";
import "./PropdatesBase.t.sol";

contract acceptPropUpdateAdminTest is PropdatesBaseTest {
    function testAcceptsPendingAdmin() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.prank(newAdmin);
        propdates.acceptPropUpdateAdmin(propId);
        
        assertEq(newAdmin, propdates.propdateInfo(propId).propUpdateAdmin);
    }

    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);

    function testEmitsPropUpdateAdminTransfered() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.prank(newAdmin);
        
        vm.expectEmit(true, true, true, false);
        emit PropUpdateAdminTransfered(propId, address(0), newAdmin);
        propdates.acceptPropUpdateAdmin(propId);
    }

    function testRemovesPendingAdmin() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.prank(newAdmin);
        propdates.acceptPropUpdateAdmin(propId);
        
        assertEq(address(0), propdates.pendingPropUpdateAdmin(propId));
    }

    function testRevertsIfNotPendingAdmin() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.expectRevert(Propdates.OnlyPendingPropUpdateAdmin.selector);
        propdates.acceptPropUpdateAdmin(propId);
    }
}
