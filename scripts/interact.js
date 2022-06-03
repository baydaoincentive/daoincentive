const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const contract = require("../artifacts/contracts/BayStudentDao.sol/BayStudentDao.json");

// provider - Alchemy
const alchemyProvider = new ethers.providers.AlchemyProvider(network="ropsten", API_KEY);

// signer - you
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// contract instance
const BayStudentDaoContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function give_balance(address) {

    // const balance = await BayStudentDaoContract.balanceOf("0x94d97B33cc29F3DfE83B683cDf63F237Ca68Fc5F");
    // console.log("The balance is: ",balance); 

    console.log("Updating the message...");
    const tx = await BayStudentDaoContract.transfer(address,10 ** 10);
    await tx.wait();
    
    const balance_new = await BayStudentDaoContract.balanceOf(address);
    console.log("New balance is: ",balance_new); 

}

async function create_lesson(tutor_address) {
    console.log("Updating the message...");
    const tx = await BayStudentDaoContract.create_lesson(tutor_address,10**8);
    await tx.wait();
}

async function main() {
    // await give_balance("0x94d97B33cc29F3DfE83B683cDf63F237Ca68Fc5F");

    // await create_lesson("0x94d97B33cc29F3DfE83B683cDf63F237Ca68Fc5F")

    // const lesson = await BayStudentDaoContract.lessons(1);
    // console.log("The lesson is: ",lesson); 

    // const tx = await BayStudentDaoContract.participate_lesson(1);
    // await tx.wait();

    // const tx = await BayStudentDaoContract.close_lesson(1);
    // await tx.wait();

    // const tx = await BayStudentDaoContract.vote_lesson(1,10);
    // await tx.wait(); 
    const tx = await BayStudentDaoContract.distribute_incentives(1);
    await tx.wait(); 
}

main();