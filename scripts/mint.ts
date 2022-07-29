import { Contract } from "ethers"
import { ethers } from "hardhat"

const contractAddress = process.env.CONTRACT_ADDRESS || "0x33cd5b83f71621970d7bbf8fcfe595c20cb5921a";
const contractName = process.env.CONTRACT_NAME || "DAWOO"
// Giá mint 1 NFT
const payableAmount = Number(process.env.PAYABLE_AMOUNT) || 0;
// Số lượng NFT tối đa nó cho phép trong 1 lần mint
const maxMintPerTx = Number(process.env.MAX_MIN_PER_TX) || 1;
// Muốn gọi hàm mint bao nhiêu lần
const numberMintSuccess = Number(process.env.NUMBER_MINT_SUCCESS) || 1;

const totalPayableAmount = payableAmount * maxMintPerTx;

async function mint(account, contract) {
  // console.log(`${account.address} start min at ${new Date()}`);
  try {
    let tx;
    if (payableAmount) {
      tx = await contract.connect(account).mint(maxMintPerTx, {
        value: totalPayableAmount
      })
    } else {
      tx = await contract.connect(account).mint(maxMintPerTx);
    }

    await tx.wait()

    console.log(`Ví ${account.address} mint thành công ${maxMintPerTx} NFT với giá ${totalPayableAmount}`);
    return true;
  } catch (error) {
    console.log(`Mint lỗi: ${error}`);
    // console.log(`Mint failed!`);
    return false;
  }
}

async function handleMintPerAccount(account, contract) {
  
  let txCount = numberMintSuccess;

  while (txCount > 0) {
      let check = await mint(account, contract);
      check && txCount--;
  }
}

const main = async (): Promise<any> => {
    const accounts = await ethers.getSigners();
    console.log('Accounts: ', accounts.map(a => a.address));
    const Box = await ethers.getContractFactory('Rocks');
    const contract = await Box.attach(contractAddress);
    // const contract = await ethers.getContractAt(contractName, contractAddress);

    let tasks = accounts.map(account => handleMintPerAccount(account, contract));
    await Promise.all(tasks);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })