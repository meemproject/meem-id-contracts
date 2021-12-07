// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct MeemID {
	address[] wallets;
	string[] twitters;
}

interface IMeemID {
	function createOrAddMeemID(address addy, string memory twitterHandle)
		external;

	function removeWalletAddressByWalletAddress(
		address lookupWalletAddress,
		address addressToRemove
	) external;

	function removeWalletAddressByTwitterHandle(
		string memory twitterHandle,
		address addressToRemove
	) external;

	function removeTwitterHandleByWalletAddress(
		address lookupWalletAddress,
		string memory twitterHandleToRemove
	) external;

	function removeTwitterHandleByTwitterHandle(
		string memory lookupTwitterHandle,
		string memory twitterHandleToRemove
	) external;

	function getMeemIDByWalletAddress(address addy)
		external
		view
		returns (MeemID memory);

	function getMeemIDByTwitterHandle(string memory twitterHandle)
		external
		view
		returns (MeemID memory);
}
