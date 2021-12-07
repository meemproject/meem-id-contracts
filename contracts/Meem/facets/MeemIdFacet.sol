// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import {LibAppStorage} from '../storage/LibAppStorage.sol';
import {LibArray} from '../libraries/LibArray.sol';
import {LibStrings} from '../libraries/LibStrings.sol';
import {LibAccessControl} from '../libraries/LibAccessControl.sol';
import {TwitterAlreadyAdded, MeemIDNotFound, MeemIDAlreadyExists, MeemIDAlreadyAssociated, NoRemoveSelf} from '../libraries/Errors.sol';
import {IMeemID, MeemID} from '../interfaces/IMeemID.sol';

contract MeemIdFacet is IMeemID {
	function createOrAddMeemID(address addy, string memory twitterHandle)
		external
		override
	{
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl.requireRole(s.ID_VERIFIER_ROLE);
		uint256 idx = s.walletIdIndex[addy];
		uint256 twitterIdx = s.twitterIdIndex[twitterHandle];

		if (idx == 0 && twitterIdx == 0) {
			// Create the ID
			address[] memory wallets = new address[](1);
			string[] memory twitters = new string[](1);
			wallets[0] = addy;
			twitters[0] = twitterHandle;

			s.ids.push(MeemID({wallets: wallets, twitters: twitters}));

			idx = s.ids.length - 1;

			s.walletIdIndex[addy] = idx;
			s.twitterIdIndex[twitterHandle] = idx;
		} else if (idx != 0 && twitterIdx == 0) {
			// Add twitter
			s.ids[idx].twitters.push(twitterHandle);
			s.twitterIdIndex[twitterHandle] = idx;
		} else if (idx == 0 && twitterIdx != 0) {
			// Add wallet
			s.ids[twitterIdx].wallets.push(addy);
			s.walletIdIndex[addy] = twitterIdx;
		} else if (idx != 0 && twitterIdx != 0 && idx != twitterIdx) {
			// Mismatched ids
			revert MeemIDAlreadyAssociated();
		}

		// Else it's already been added. Nothing to do.
	}

	function getMeemIDByWalletAddress(address addy)
		external
		view
		override
		returns (MeemID memory)
	{
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();

		if (s.walletIdIndex[addy] == 0) {
			revert MeemIDNotFound();
		}

		return s.ids[s.walletIdIndex[addy]];
	}

	function getMeemIDByTwitterHandle(string memory twitterHandle)
		external
		view
		override
		returns (MeemID memory)
	{
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();

		if (s.twitterIdIndex[twitterHandle] == 0) {
			revert MeemIDNotFound();
		}

		return s.ids[s.twitterIdIndex[twitterHandle]];
	}

	function removeWalletAddressByWalletAddress(
		address lookupWalletAddress,
		address addressToRemove
	) external override {
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl.requireRole(s.ID_VERIFIER_ROLE);

		if (lookupWalletAddress == addressToRemove) {
			revert NoRemoveSelf();
		}

		uint256 idx = s.walletIdIndex[lookupWalletAddress];

		if (idx == 0) {
			revert MeemIDNotFound();
		}

		for (uint256 i = 0; i < s.ids[idx].wallets.length; i++) {
			if (s.ids[idx].wallets[i] == addressToRemove) {
				s.ids[idx].wallets = LibArray.removeAddressAt(
					s.ids[idx].wallets,
					i
				);

				delete s.walletIdIndex[addressToRemove];
			}
		}
	}

	function removeWalletAddressByTwitterHandle(
		string memory lookupTwitterHandle,
		address addressToRemove
	) external override {
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl.requireRole(s.ID_VERIFIER_ROLE);

		uint256 idx = s.twitterIdIndex[lookupTwitterHandle];

		if (idx == 0) {
			revert MeemIDNotFound();
		}

		for (uint256 i = 0; i < s.ids[idx].wallets.length; i++) {
			if (s.ids[idx].wallets[i] == addressToRemove) {
				s.ids[idx].wallets = LibArray.removeAddressAt(
					s.ids[idx].wallets,
					i
				);

				delete s.walletIdIndex[addressToRemove];
			}
		}
	}

	function removeTwitterHandleByWalletAddress(
		address lookupWalletAddress,
		string memory twitterHandleToRemove
	) external override {
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl.requireRole(s.ID_VERIFIER_ROLE);

		uint256 idx = s.walletIdIndex[lookupWalletAddress];

		if (idx == 0) {
			revert MeemIDNotFound();
		}

		for (uint256 i = 0; i < s.ids[idx].twitters.length; i++) {
			if (
				LibStrings.compareStrings(
					s.ids[idx].twitters[i],
					twitterHandleToRemove
				)
			) {
				s.ids[idx].twitters = LibArray.removeStringAt(
					s.ids[idx].twitters,
					i
				);

				delete s.twitterIdIndex[twitterHandleToRemove];
			}
		}
	}

	function removeTwitterHandleByTwitterHandle(
		string memory lookupTwitterHandle,
		string memory twitterHandleToRemove
	) external override {
		LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
		LibAccessControl.requireRole(s.ID_VERIFIER_ROLE);

		if (
			LibStrings.compareStrings(
				lookupTwitterHandle,
				twitterHandleToRemove
			)
		) {
			revert NoRemoveSelf();
		}

		uint256 idx = s.twitterIdIndex[lookupTwitterHandle];

		if (idx == 0) {
			revert MeemIDNotFound();
		}

		for (uint256 i = 0; i < s.ids[idx].twitters.length; i++) {
			if (
				LibStrings.compareStrings(
					s.ids[idx].twitters[i],
					twitterHandleToRemove
				)
			) {
				s.ids[idx].twitters = LibArray.removeStringAt(
					s.ids[idx].twitters,
					i
				);

				delete s.twitterIdIndex[twitterHandleToRemove];
			}
		}
	}
}
