const hre = require("hardhat");

async function main() {
  await hre.run('compile');

  // We get the contract to deploy
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();

  console.log("Contract deployed to:", nftContract.address);
  let tx = await nftContract.makeAnEpicNFT();
  await tx.wait();

  tx = await nftContract.makeAnEpicNFT();
  await tx.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
