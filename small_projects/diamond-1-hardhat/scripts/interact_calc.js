async function main() {
    const diamondAddress = "0xCd6fb07E5f11c12aa8bd16d51D8aB368d3bb4C47"; // Replace with your deployed diamond address
    // const [deployer] = await ethers.getSigners();
    // console.log(deployer.address);
    // const diamond = await ethers.getContractAt("Diamond", diamondAddress);
    const Diamond = await ethers.getContractFactory("Diamond");
    // console.log("Diamond:", Diamond);
    const diamond = await Diamond.attach(diamondAddress);
    // const owner = await diamond.owner();
    // console.log("Owner:", owner)
    // console.log("Diamond:", diamond);

    // const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
    // const ownershipFacetInstance = await ethers.getContractAt(OwnershipFacet.interface, diamondAddress);
    // const CalculatorFacetDep = await ethers.getContractFactory('CalculatorFacet');
    // const CalculatorFacetDepInstance = await ethers.getContractAt(CalculatorFacetDep.interface, diamondAddress);

    // await CalculatorFacetDepInstance.add(3,5);
    // const ans1 = await CalculatorFacetDepInstance.getResult();
    // console.log(`This is from the CalculatorFacet: ${ans1}`);

    // const owner = await ownershipFacetInstance.owner();
    // console.log("Owner:", owner);
    const CalculatorFacetInstance = await ethers.getContractAt('CalculatorFacet', diamondAddress);
    const calculation = await CalculatorFacetInstance.subtract(8,1);
    const receipt = await calculation.wait();
    if (!receipt.status) {
      throw Error(`Calculation failed: ${calculation.hash}`)
    }
    else{
      const ans2 = await CalculatorFacetInstance.getResult();
      console.log(`This is from the CalculatorFacet: ${ans2}`);
    }
// look into nested promise => transaction retrieves results after deterministic time
  }
  
  (async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  })();

  
  
  


