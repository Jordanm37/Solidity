async function main() {
    const diamondAddress = "0xCb730cC1e71416B5428a1Af2a6c27eb3A19Cb0B3"; // Replace with your deployed diamond address
    // const [deployer] = await ethers.getSigners();
    // console.log(deployer.address);
    // const diamond = await ethers.getContractAt("Diamond", diamondAddress);
    const Diamond = await ethers.getContractFactory("Diamond");
    // console.log("Diamond:", Diamond);
    const diamond = await Diamond.attach(diamondAddress);
    // const owner = await diamond.owner();
    // console.log("Owner:", owner)
    // console.log("Diamond:", diamond);

    const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
    const ownershipFacetInstance = await ethers.getContractAt(OwnershipFacet.interface, diamondAddress);
  
    const owner = await ownershipFacetInstance.owner();
    console.log("Owner:", owner);
        
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

  
  
  


    // 