// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {NounsDAOLogicV2} from "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";

import "src/Propdates.sol";

contract PropdatesBaseTest is Test {
    Propdates propdates;
    NounsDAOLogicV2 nounsDAO;

    uint256 forkId = vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), 17465831);
    uint256 propId = 300;

    function setUp() public virtual {
        propdates = new Propdates();
        nounsDAO = NounsDAOLogicV2(propdates.NOUNS_DAO());
    }
}
