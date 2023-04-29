// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Proposal} from 'lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOInterface.sol';

contract Propdates {
    mapping (uint256 => address) public propUpdateAdmin;
    mapping (uint256 => address) public pendingPropUpdateAdmin;

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);

    modifier onlyPropUpdateAdmin(uint256 _propId) {
        require(msg.sender == propUpdateAdmin[_propId]);
        _;
    }

    function transferPropUpdateAdminPower(uint256 _propId, address _newAdmin) public  {
        require(msg.sender == propUpdateAdmin[_propId] || );
        pendingPropUpdateAdmin[_propId] = _newAdmin;

        emit PropUpdateAdminTransferStarted(_propId, msg.sender, _newAdmin);
    }

    function acceptPropUpdateAdminPower(uint256 _propId) public {
        require(msg.sender == pendingPropUpdateAdmin[_propId]);

        address oldAdmin = propUpdateAdmin[_propId];
        address newAdmin = pendingPropUpdateAdmin[_propId];

        propUpdateAdmin[_propId] = newAdmin;
        pendingPropUpdateAdmin[_propId] = address(0);

        emit PropUpdateAdminTransfered(_propId, oldAdmin, newAdmin);
    }
}
