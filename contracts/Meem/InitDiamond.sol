// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibAppStorage} from './storage/LibAppStorage.sol';
import {LibAccessControl} from './libraries/LibAccessControl.sol';
import {IDiamondCut} from './interfaces/IDiamondCut.sol';
import {IDiamondLoupe} from './interfaces/IDiamondLoupe.sol';

import '@solidstate/contracts/introspection/ERC165.sol';

contract InitDiamond {
	using ERC165Storage for ERC165Storage.Layout;

	struct Args {
		string name;
		string symbol;
		uint256 childDepth;
		uint256 nonOwnerSplitAllocationAmount;
		address proxyRegistryAddress;
		string contractURI;
	}

	function init(Args memory _args) external {
		ERC165Storage.Layout storage erc165 = ERC165Storage.layout();
		erc165.setSupportedInterface(type(IDiamondCut).interfaceId, true);
		erc165.setSupportedInterface(type(IDiamondLoupe).interfaceId, true);

		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl._grantRole(s.ADMIN_ROLE, msg.sender);
	}
}
