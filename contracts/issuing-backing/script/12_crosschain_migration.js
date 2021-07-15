const Issuing = artifacts.require("Issuing")
const ERC223 = artifacts.require("StandardERC223")
const ISettingsRegistry = artifacts.require("ISettingsRegistry")

module.exports = async (deployer, network, accounts) => {
    console.log('Issuing Test, deployer:', accounts, accounts[0])
    if (network != "ropsten") {
        return
    }

    const params = {
        ropsten: {
            registry: "0x6982702995b053A21389219c1BFc0b188eB5a372",
            isPaused: false,
            ring: '0xb52FBE2B925ab79a821b261C82c5Ba0814AAA5e0',
            kton: '0x1994100c58753793D52c6f457f189aa3ce9cEe94',
            settingsRegistry: '0x6982702995b053A21389219c1BFc0b188eB5a372'
        }
    }

    let issuing = await Issuing.new(params[network].settingsRegistry)
    // let issuing = await Issuing.at('xxx')
    console.log('issuing.address: ', issuing.address)
    // return
    // set ring authrity
    let registry = await ISettingsRegistry.at(params[network].settingsRegistry)

    //  UINT_BRIDGE_FEE
    await registry.setUintProperty('0x55494e545f4252494447455f4645450000000000000000000000000000000000', web3.utils.toWei('2'))

    //  CONTRACT_BRIDGE_POOL
    await registry.setAddressProperty('0x434f4e54524143545f4252494447455f504f4f4c000000000000000000000000', '0x7f5B598827359939606B3525712Fb124A1C7851d')
    console.log('set registry success')

    await issuing.addSupportedTokens(params[network].ring);
    await issuing.addSupportedTokens(params[network].kton);
    console.log('add supported tokens success')

    // test
    // crossChain test
    const RING = await ERC223.at(params[network].ring);
    const KTON = await ERC223.at(params[network].kton);

    // approve ring
    await RING.approve(issuing.address, web3.utils.toWei('10000'))
    console.log('approve ring success')

    let tx = await RING.transferFrom(accounts[0], issuing.address, web3.utils.toWei('1.2345'), '0xe44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318')
    console.log('transfer ring tx:', tx.tx)

    tx = await KTON.transferFrom(accounts[0], issuing.address, web3.utils.toWei('0.0001234'), '0xe44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318')
    console.log('transfer kton tx:', tx.tx)
}
