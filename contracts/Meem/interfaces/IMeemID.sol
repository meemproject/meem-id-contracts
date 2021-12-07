// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct MeemID {
	address[] wallets;
	string[] twitters;
}

interface IMeemID {
	function createOrAddMeemID(address addy, string memory twitterHandle)
		external;

	function getMeemID(address addy) external view returns (MeemID memory);

	function getMeemID(string memory twitterHandle)
		external
		view
		returns (MeemID memory);
}
