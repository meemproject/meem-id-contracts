import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import chai, { assert } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import { ethers } from 'hardhat'
import { deployDiamond } from '../tasks'
import { MeemIdFacet } from '../typechain'

chai.use(chaiAsPromised)

describe('Meem ID', function Test() {
	let meemIdFacet: MeemIdFacet
	let signers: SignerWithAddress[]

	before(async () => {
		signers = await ethers.getSigners()
		console.log({ signers })
		const { DiamondProxy: DiamondAddress } = await deployDiamond({
			ethers
		})

		meemIdFacet = (await ethers.getContractAt(
			'MeemIdFacet',
			DiamondAddress
		)) as MeemIdFacet
	})

	it('Can not create ID with non-trusted account', async () => {
		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.createOrAddMeemID(signers[2].address, 'signer2')
		)
	})

	it('Can create ID with trusted account', async () => {
		await meemIdFacet
			.connect(signers[0])
			.createOrAddMeemID(signers[2].address, 'signer2')
	})

	it('Can get ID by address', async () => {
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByWalletAddress(signers[2].address)

		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.twitters[0], 'signer2')
	})

	it('Can get ID by twitter handle', async () => {
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByTwitterHandle('signer2')

		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.twitters[0], 'signer2')
	})

	it('Can add wallet by twitter handle', async () => {
		await meemIdFacet
			.connect(signers[0])
			.createOrAddMeemID(signers[3].address, 'signer2')

		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByTwitterHandle('signer2')

		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets[1], signers[3].address)
		assert.equal(id.twitters[0], 'signer2')
	})

	it('Can add twitter handle by wallet', async () => {
		await meemIdFacet
			.connect(signers[0])
			.createOrAddMeemID(signers[3].address, 'signer2-2')
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByTwitterHandle('signer2-2')
		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets[1], signers[3].address)
		assert.equal(id.twitters[0], 'signer2')
		assert.equal(id.twitters[1], 'signer2-2')
	})

	it('Can not remove twitter handle by wallet as untrusted', async () => {
		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.removeTwitterHandleByWalletAddress(signers[3].address, 'signer2-2')
		)
	})

	it('Can remove twitter handle by wallet', async () => {
		await meemIdFacet
			.connect(signers[0])
			.removeTwitterHandleByWalletAddress(signers[3].address, 'signer2-2')
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByWalletAddress(signers[3].address)
		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets[1], signers[3].address)
		assert.equal(id.twitters.length, 1)
		assert.equal(id.twitters[0], 'signer2')

		await assert.isRejected(
			meemIdFacet.connect(signers[1]).getMeemIDByTwitterHandle('signer2-2')
		)
	})

	it('Can not remove twitter handle by twitter handle as untrusted', async () => {
		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.removeTwitterHandleByTwitterHandle('signer2', 'signer2-2')
		)
	})

	it('Can remove twitter handle by twitter handle', async () => {
		await meemIdFacet
			.connect(signers[0])
			.createOrAddMeemID(signers[3].address, 'signer2-2')

		await meemIdFacet
			.connect(signers[0])
			.removeTwitterHandleByTwitterHandle('signer2', 'signer2-2')
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByWalletAddress(signers[3].address)
		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets[1], signers[3].address)
		assert.equal(id.twitters.length, 1)
		assert.equal(id.twitters[0], 'signer2')

		await assert.isRejected(
			meemIdFacet.connect(signers[1]).getMeemIDByTwitterHandle('signer2-2')
		)
	})

	it('Can not remove wallet handle by wallet as untrusted', async () => {
		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.removeWalletAddressByWalletAddress(
					signers[2].address,
					signers[3].address
				)
		)
	})

	it('Can remove wallet handle by wallet', async () => {
		await meemIdFacet
			.connect(signers[0])
			.removeWalletAddressByWalletAddress(
				signers[2].address,
				signers[3].address
			)
		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByWalletAddress(signers[2].address)
		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets.length, 1)

		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.getMeemIDByWalletAddress(signers[3].address)
		)
	})

	it('Can not remove wallet handle by twitter handle as untrusted', async () => {
		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.removeWalletAddressByTwitterHandle('signer2', signers[3].address)
		)
	})

	it('Can remove wallet handle by twitter handle', async () => {
		await meemIdFacet
			.connect(signers[0])
			.createOrAddMeemID(signers[3].address, 'signer2')

		await meemIdFacet
			.connect(signers[0])
			.removeWalletAddressByTwitterHandle('signer2', signers[3].address)

		const id = await meemIdFacet
			.connect(signers[1])
			.getMeemIDByWalletAddress(signers[2].address)
		assert.equal(id.wallets[0], signers[2].address)
		assert.equal(id.wallets.length, 1)

		await assert.isRejected(
			meemIdFacet
				.connect(signers[1])
				.getMeemIDByWalletAddress(signers[3].address)
		)
	})
})
