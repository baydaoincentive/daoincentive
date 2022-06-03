pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BayToken is ERC20, Ownable {
   uint public INITIAL_SUPPLY = 10**(18+8);

   constructor() ERC20("BAY Token - test", "BAYT-t"){
      _mint(msg.sender, INITIAL_SUPPLY);
   }
}
