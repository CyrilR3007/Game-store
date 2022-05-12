//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract GameStore {

  // Contains store data
  uint256 taxFee;
  address immutable taxAccount;
  uint8 totalSupply = 0;

  // Game information
  struct GameStruct {
    uint8 id;
    address seller;
    string title;
    string description;
    uint256 cost;
    uint256 timestamp;
  }

  // Assiociate games with seller and buyers
  GameStruct[] games;
  mapping(address => GameStruct[]) gamesOf;
  mapping(uint => address) public sellerOf;
  mapping(uint => bool) gameExist;


 // Logs out sales record
 event Sale (
   uint8 id,
   address indexed buyer,
   address indexed seller,
   uint cost,
   uint timestamp
 );

 // Logs out created game record
 event Created (
   uint8 id,
   address indexed seller,
   uint timestamp
 );

 // initialize tax on game sale
 constructor(uint _taxFee) {
   taxAccount = msg.sender;
   taxFee = _taxFee;
 }

 // Game creation
 function createGame ( string memory title, string memory description, uint cost ) public returns(bool) {
   require(bytes(title).length > 0, "Title empty");
   require(bytes(description).length > 0, "Description empty");
   require(cost > 0 ether, "Price can't be zero");

   // Add games to shop
   games.push(
     GameStruct(
       totalSupply++,
       msg.sender,
       title,
       description,
       cost,
       block.timestamp
     )
   );

   // Records game selling detail
   sellerOf[totalSupply] = msg.sender;
   gameExist[totalSupply] = true;

   emit Created(
     totalSupply, msg.sender, block.timestamp
     );

   return true;
 }

 // Performs game payment
 function payForGame(uint8 id) public payable returns(bool) {
   require(gameExist[id], "Book does not exist");
   require(msg.value >= games[id - 1].cost, "Ethers too small");

   // Computes payment data
   address seller = sellerOf[id];
   uint tax = (msg.value / 100)*taxFee;
   uint payment = msg.value - tax;

   // Bills buyer to seller
   payTo(seller, payment);
   payTo(taxAccount, tax);

   // Gives game to buyer
   gamesOf[msg.sender].push(games[id - 1]);

   emit Sale(
     id,
     msg.sender,
     seller,
     payment,
     block.timestamp
   );

   return true;
 }

 // Methode 1 : pay to
 function payTo(
        address to, 
        uint256 amount
    ) internal returns (bool) {
      (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }
        
        
 // Methode 2 : transfer to
 /*function transferTo(
        address to,
        uint256 amount
    ) internal returns (bool) {
        payable(to).transfer(amount);
        return true;
    }

 // Methode 3 : send to
  function sendTo(
        address to, 
        uint256 amount
    ) internal returns (bool) {
        require(payable(to).send(amount), "Payment failed");
        return true;
    }*/

 // Returns games of buyer
 function myGames(address buyer) external view returns(GameStruct[] memory) {
   return gamesOf[buyer];
 }    

 // Returns games in store
 function getGames() external view returns(GameStruct[] memory) {
   return games;
 }

 // Returns specific game by id
 function getSpecificGame (uint8 id) external view returns(GameStruct memory) {
   return games[id - 1];
 }
}


