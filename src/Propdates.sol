// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {NounsDAOLogicV2} from "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";
import "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOInterfaces.sol";

contract Propdates {
    struct PropdateInfo {
        // who can post updates for this prop
        address propUpdateAdmin;
        // when was the last update posted
        uint88 lastUpdated;
        // is the primary work of the proposal considered done
        bool isCompleted;
    }

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PostUpdate(uint256 indexed propId, bool indexed isCompleted, string update);

    error OnlyPropUpdateAdmin();
    error OnlyPendingPropUpdateAdmin();
    error NoZeroAddress();

    address payable public constant NOUNS_DAO = payable(0x6f3E6272A167e8AcCb32072d08E0957F9c79223d);

    mapping(uint256 => address) public pendingPropUpdateAdmin;
    mapping(uint256 => PropdateInfo) internal _propdateInfo;

    function transferPropUpdateAdmin(uint256 propId, address newAdmin) external {
        if (newAdmin == address(0)) {
            // block transferring to zero address because it creates a weird state
            // where the prop proposer has control again
            revert NoZeroAddress();
        }

        address currentAdmin = _propdateInfo[propId].propUpdateAdmin;
        if (
            msg.sender != currentAdmin
                && !(currentAdmin == address(0) && NounsDAOLogicV2(NOUNS_DAO).proposals(propId).proposer == msg.sender)
        ) {
            revert OnlyPropUpdateAdmin();
        }
        pendingPropUpdateAdmin[propId] = newAdmin;

        emit PropUpdateAdminTransferStarted(propId, currentAdmin, newAdmin);
    }

    function acceptPropUpdateAdmin(uint256 propId) external {
        if (msg.sender != pendingPropUpdateAdmin[propId]) {
            revert OnlyPendingPropUpdateAdmin();
        }

        _acceptPropUpdateAdmin(propId);
    }

    function postUpdate(uint256 propId, bool isCompleted, string calldata update) external {
        if (msg.sender != _propdateInfo[propId].propUpdateAdmin) {
            if (msg.sender == pendingPropUpdateAdmin[propId]) {
                // don't love the side effect here, but it saves a tx and so seems worth it?
                // could also just make it multicallable 
                _acceptPropUpdateAdmin(propId);
            } else {
                revert OnlyPropUpdateAdmin();
            }
        }

        _propdateInfo[propId].lastUpdated = uint88(block.timestamp);
        // only set this value if true, so that it can't be unset
        if (isCompleted) {
            _propdateInfo[propId].isCompleted = true;
        }
        
        emit PostUpdate(propId, isCompleted, update);
    }

    function propdateInfo(uint256 propId) external view returns (PropdateInfo memory) {
        return _propdateInfo[propId];
    }

    function _acceptPropUpdateAdmin(uint256 propId) internal {
        delete pendingPropUpdateAdmin[propId];

        address oldAdmin = _propdateInfo[propId].propUpdateAdmin;
        _propdateInfo[propId].propUpdateAdmin = msg.sender;

        emit PropUpdateAdminTransfered(propId, oldAdmin, msg.sender);
    }
}
