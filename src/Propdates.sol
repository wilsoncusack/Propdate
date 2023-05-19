// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {NounsDAOLogicV2} from "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";
import "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOInterfaces.sol";

contract Propdates {
    struct PropdateInfo {
        address propUpdateAdmin;
        uint96 lastUpdated;
    }
    
    address payable public constant NOUNS_DAO = payable(0x6f3E6272A167e8AcCb32072d08E0957F9c79223d);

    mapping(uint256 => PropdateInfo) public propdateInfo;
    mapping(uint256 => address) public pendingPropUpdateAdmin;

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PostUpdate(uint256 indexed propId, string update);

    error OnlyPropUpdateAdmin();
    error OnlyPendingPropUpdateAdmin();

    function transferPropUpdateAdminPower(uint256 propId, address newAdmin) external {
        address currentAdmin = propdateInfo[propId].propUpdateAdmin;
        if (
            msg.sender != currentAdmin
                && !(currentAdmin == address(0) && NounsDAOLogicV2(NOUNS_DAO).proposals(propId).proposer == msg.sender)
        ) {
            revert OnlyPropUpdateAdmin();
        }
        pendingPropUpdateAdmin[propId] = newAdmin;

        emit PropUpdateAdminTransferStarted(propId, currentAdmin, newAdmin);
    }

    function acceptPropUpdateAdminPower(uint256 propId) external {
        if (msg.sender != pendingPropUpdateAdmin[propId]) {
            revert OnlyPendingPropUpdateAdmin();
        }

        _acceptPropUpdateAdminPower(propId);
    }

    function postUpdate(uint256 propId, string calldata update) external {
        if (msg.sender != propdateInfo[propId].propUpdateAdmin) {
            if (msg.sender == pendingPropUpdateAdmin[propId]) {
                _acceptPropUpdateAdminPower(propId);
            } else {
                revert OnlyPropUpdateAdmin();
            }
        }

        propdateInfo[propId].lastUpdated = uint96(block.timestamp);
        emit PostUpdate(propId, update);
    }

    function _acceptPropUpdateAdminPower(uint256 propId) internal {
        delete pendingPropUpdateAdmin[propId];

        address oldAdmin = propdateInfo[propId].propUpdateAdmin;
        propdateInfo[propId].propUpdateAdmin = msg.sender;

        emit PropUpdateAdminTransfered(propId, oldAdmin, msg.sender);
    }
}
