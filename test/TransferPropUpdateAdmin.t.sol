// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/Propdates.sol";
import "./PropdatesBase.t.sol";

contract TransferPropUpdateAdminTest is PropdatesBaseTest {
    function testSetsPendingPropAdmin() public { 
        assertEq(address(0), propdates.propdateInfo(propId).propUpdateAdmin);
        vm.prank(nounsDAO.proposals(propId).proposer);
        address newAdmin = address(0xb0b);
        propdates.transferPropUpdateAdmin(propId, newAdmin);

        assertEq(newAdmin, propdates.pendingPropUpdateAdmin(propId));
    }

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);

    function testEmitsPropUpdateAdminTransferStarted() public { 
        assertEq(address(0), propdates.propdateInfo(propId).propUpdateAdmin);
        vm.prank(nounsDAO.proposals(propId).proposer);
        address newAdmin = address(0xb0b);

        vm.expectEmit(true, true, true, false);
        emit PropUpdateAdminTransferStarted(propId, address(0), newAdmin);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
    }


    function testAllowsProposerIfCurrentAdminZero() public { 
        assertEq(address(0), propdates.propdateInfo(propId).propUpdateAdmin);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, address(0xb0b));
    }

    function testRevertsIfNewAdminZero() public { 
        assertEq(address(0), propdates.propdateInfo(propId).propUpdateAdmin);
        vm.prank(nounsDAO.proposals(propId).proposer);
        vm.expectRevert(Propdates.NoZeroAddress.selector);
        propdates.transferPropUpdateAdmin(propId, address(0));
    }

    function testRevertsIfNotProposerAndAddressZero() public { 
        assertEq(address(0), propdates.propdateInfo(propId).propUpdateAdmin);
        vm.expectRevert(Propdates.OnlyPropUpdateAdmin.selector);
        propdates.transferPropUpdateAdmin(propId, address(0xb0b));
    }

    function testAllowsCurrentAdmin() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.startPrank(newAdmin);
        propdates.acceptPropUpdateAdmin(propId);
        propdates.transferPropUpdateAdmin(propId, address(0xb0));
    }

    function testRevertsIfNotCurrentAdmin() public { 
        address newAdmin = address(0xb0b);
        vm.prank(nounsDAO.proposals(propId).proposer);
        propdates.transferPropUpdateAdmin(propId, newAdmin);
        vm.prank(newAdmin);
        propdates.acceptPropUpdateAdmin(propId);
        vm.prank(nounsDAO.proposals(propId).proposer);
        vm.expectRevert(Propdates.OnlyPropUpdateAdmin.selector);
        propdates.transferPropUpdateAdmin(propId, address(0xb0));
    }
}
