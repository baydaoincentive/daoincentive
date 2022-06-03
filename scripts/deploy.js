async function main() {
    const BayStudentDao = await ethers.getContractFactory("BayStudentDao");
 
    // Start deployment, returning a promise that resolves to a contract object
    const bay_student_dao = await BayStudentDao.deploy();   
    console.log("Contract deployed to address:", bay_student_dao.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });