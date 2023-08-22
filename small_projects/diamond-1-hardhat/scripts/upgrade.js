const { ethers } = require('hardhat')

const {
    getSelectors,
    getSelector,
    get,
    FacetCutAction,
    // removeSelectors,
    // findAddressPositionInFacets
  } = require('./libraries/diamond.js')

  async function deployDiamond () {
    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]
  
    // Deploy DiamondInit
    // DiamondInit provides a function that is called when the diamond is upgraded or deployed to initialize state variables
    // Read about how the diamondCut function works in the EIP2535 Diamonds standard
    const DiamondInit = await ethers.getContractFactory('DiamondInit')
    const diamondInit = await DiamondInit.deploy()
    await diamondInit.deployed()
    console.log('DiamondInit deployed:', diamondInit.address)
  
    // Deploy facets and set the `facetCuts` variable
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
      'DiamondCutFacet',
      'DiamondLoupeFacet',
      'OwnershipFacet'
    ]
    // The `facetCuts` variable is the FacetCut[] that contains the functions to add during diamond deployment
    const facetCuts = []
    for (const FacetName of FacetNames) {
      const Facet = await ethers.getContractFactory(FacetName)
      const facet = await Facet.deploy()
      await facet.deployed()
      console.log(`${FacetName} deployed: ${facet.address}`)
      facetCuts.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet)
      })
    }
  
    // console.log(facetCuts)
  
    // Creating a function call
    // This call gets executed during deployment and can also be executed in upgrades
    // It is executed with delegatecall on the DiamondInit address.
    let functionCall = diamondInit.interface.encodeFunctionData('init')
  
    // Setting arguments that will be used in the diamond constructor
    const diamondArgs = {
      owner: contractOwner.address,
      init: diamondInit.address,
      initCalldata: functionCall
    }
  
    // deploy Diamond
    const Diamond = await ethers.getContractFactory('Diamond')
    const diamond = await Diamond.deploy(facetCuts, diamondArgs)
    await diamond.deployed()
    console.log()
    console.log('Diamond deployed:', diamond.address)
  
    // returning the address of the diamond
    return diamond.address
  }

const deployer = async () => {
    const diamondAddress = await deployDiamond()
    console.log(`The Diamond address is ${diamondAddress}`)
    const Test1Facet = await ethers.getContractFactory('Test1Facet')
    const test1Facet = await Test1Facet.deploy()
    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
    await test1Facet.deployed()
    
    console.log(`facet1 deployed at: ${test1Facet.address}`)
    const selectors1 = getSelectors(test1Facet)
    const bytesSelector = selectors1.get(['supportsInterface(bytes4)'])
    console.log(`The bytesSelector is ${bytesSelector}`)

    // const selectors = getSelectors(test1Facet).remove(['supportsInterface(bytes4)'])
    const selectors = getSelectors(test1Facet).filter(selector => selector != bytesSelector);
    // const selectors = getSelectors(test1Facet)

    console.log('The function selectors are: ' + selectors)

    const cut = [
      {
        facetAddress: test1Facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectors,
      },
    ];
    console.log("Cut: ", cut);

    


    tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: test1Facet.address,
          action: FacetCutAction.Add,
          functionSelectors: selectors
        }],
        diamondAddress, '0x', { gasLimit: 4000000  })
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
      }
      result = await diamondLoupeFacet.facetFunctionSelectors(test1Facet.address)

      // const upgradeTest = await test1Facet.test1Func2()
      // console.log(`This is from the testFacet1: ${upgradeTest}`)

      return diamondAddress
}

const testUpgrade = async (diamondAddress) => {
  const test1Facet = await ethers.getContractAt('Test1Facet', diamondAddress);
  return test1Facet.test1Func2().then(upgradeTest => {
    console.log(`This is from the testFacet: ${upgradeTest}`);
  });
};

// if (require.main === module) {
//     deployer()
//       // .then((diamondAddress) => testUpgrade(diamondAddress))
//       .then(() => process.exit(0))
//       .catch(error => {
//         console.error(error)
//         process.exit(1)
//       })
//   }

if (require.main === module) {
  deployer()
    .then((diamondAddress) => testUpgrade(diamondAddress))
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}