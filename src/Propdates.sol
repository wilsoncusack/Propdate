// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {NounsDAOLogicV2} from "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";
import "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOInterfaces.sol";

contract Propdates {
    address payable public constant NOUNS_DAO = payable(0x6f3E6272A167e8AcCb32072d08E0957F9c79223d);

    mapping(uint256 => address) public propUpdateAdmin;
    mapping(uint256 => address) public pendingPropUpdateAdmin;

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PostUpdate(uint256 indexed propId, string update);

    error OnlyPropUpdateAdmin();

    modifier onlyPropUpdateAdmin(uint256 propId) {
        if(msg.sender != propUpdateAdmin[propId]) {
            revert OnlyPropUpdateAdmin();
        }
        _;
    }

    function transferPropUpdateAdminPower(uint256 propId, address _newAdmin) external {
        address currentAdmin = propUpdateAdmin[propId];
        if (
            msg.sender != currentAdmin
                && !(currentAdmin == address(0) && NounsDAOLogicV2(NOUNS_DAO).proposals(propId).proposer == msg.sender)
        ) {
            revert OnlyPropUpdateAdmin();
        }
        pendingPropUpdateAdmin[propId] = _newAdmin;

        emit PropUpdateAdminTransferStarted(propId, currentAdmin, _newAdmin);
    }

    function acceptPropUpdateAdminPower(uint256 propId) external {
        require(msg.sender == pendingPropUpdateAdmin[propId]);

        address oldAdmin = propUpdateAdmin[propId];
        address newAdmin = pendingPropUpdateAdmin[propId];

        propUpdateAdmin[propId] = newAdmin;
        pendingPropUpdateAdmin[propId] = address(0);

        emit PropUpdateAdminTransfered(propId, oldAdmin, newAdmin);
    }

    /// NOTE we could restrict this to successfully funded props only, but maybe fine/interesting to leave open?
    function postUpdate(uint256 propId, string calldata update) onlyPropUpdateAdmin(propId) external {
        emit PostUpdate(propId, update);
    }
}
