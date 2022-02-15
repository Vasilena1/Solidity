pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Library is Ownable{

    uint allTimeUsersCount = 0;
    uint allBooksInStock = 0;
    bool available;

    struct Book{
        string id;
        string name;
        uint16 copies;
    }

    mapping(uint => Book) books;
    mapping(address => string) users;
    mapping(uint => address) allTimeUsers;
    

    function addBook (Book calldata _book) public onlyOwner {
      for (uint8 i = 0; i < allBooksInStock; i++) {
        if(keccak256(abi.encodePacked(books[i].id)) == keccak256(abi.encodePacked(_book.id))){
          available = true;
        }
      }
      if(available == false){
        books[allBooksInStock] = _book;
        allBooksInStock++;
      }
    }

    function changeCopies (string calldata _idInput, uint16 _numberOfCopies) public onlyOwner{
      for (uint8 i = 0; i < allBooksInStock; i++) {
            if (keccak256(abi.encodePacked(books[i].id)) == keccak256(abi.encodePacked(_idInput))) {
               books[i].copies = _numberOfCopies;
            }
      }
    }

    function displayBooks () public view returns(Book[] memory){
      Book[] memory ret = new Book[](allBooksInStock);
      for(uint i = 0; i < allBooksInStock; i++){
        require(books[i].copies > 0);
        Book storage book = books[i];
        ret[i] = book;
      }
      return ret;
    }

    function borrowBook (string calldata _idInput) public{
       for(uint i = 0; i < allBooksInStock; i++){
          if(keccak256(abi.encodePacked(books[i].id)) == keccak256(abi.encodePacked(_idInput))
            && !(keccak256(abi.encodePacked(users[msg.sender])) == keccak256(abi.encodePacked(_idInput)))){
            users[msg.sender] = books[i].id;
            allTimeUsers[i] = msg.sender; 
            allTimeUsersCount++;
            books[i].copies--;
          }
       }
    }

     function returnBook (string calldata _idInput) public{
      for(uint i = 0; i < allBooksInStock; i++){
          if(keccak256(abi.encodePacked(books[i].id)) == keccak256(abi.encodePacked(_idInput))
          && (keccak256(abi.encodePacked(_idInput)) == keccak256(abi.encodePacked(users[msg.sender])))){
            books[i].copies++;
          }
       }
       delete(users[msg.sender]);
    }

    function displayAllTimeUsers() public view returns(address[] memory){
      address[] memory us = new address[](allTimeUsersCount);
      for(uint i = 0; i < allTimeUsersCount; i++){
        us[i] = allTimeUsers[i];
      }
      return us;
    }

}
