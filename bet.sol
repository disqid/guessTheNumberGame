// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Bet {


    mapping(address => uint) public balances;
    // track the balance of an address in the contract   
    
    mapping(address => uint[]) public rangeByAddress;
    // track the range set by an address. The correct number is in that range.

    mapping(address => uint256) private TargetNumber;
    // The target number of an address. if the attackor guess this number, he wins.

    mapping(address => uint256) private TimeOfSet;

    uint256 public timeOfSet;
    // the address cannot change his number all the time. He has to wait 1 hour.

    uint256 balanceOf;
    uint private a;
    uint private b;


    modifier deposit {
        require(balances[msg.sender] > 0, "Your deposit is zero");
        _;
    }

    function depositInWei() public payable {
    require(msg.value > 0);
    balances[msg.sender] += msg.value;
    }

    function getBalances(address person) public view returns (uint256) {
    return balances[person];
    }

    function setRange(uint256 c, uint256 d) public deposit {
        require(c < d, "first number must be less than second number");
        require(rangeByAddress[msg.sender].length < 2);
        rangeByAddress[msg.sender].push(c);
        rangeByAddress[msg.sender].push(d);
    }

    function setNumber(uint256 number) public {
        require(number > rangeByAddress[msg.sender][0], "first number of your range doesn't exist yet");
        require(number < rangeByAddress[msg.sender][1], "second number of your range doesn't exist yet");
        require(block.timestamp > TimeOfSet[msg.sender] + 3600, "you cannot change the number set yet. You have to wait again.");
        TimeOfSet[msg.sender] = block.timestamp;
        TargetNumber[msg.sender] = number;
    }
    
    function guessTheNumber(uint try1, uint try2, uint try3, address payable targetAddress) public payable{
        require(balances[msg.sender] >= balances[targetAddress], "Your deposit is zero");
        require(try1 > rangeByAddress[targetAddress][0] && try1 < rangeByAddress[targetAddress][1], "the first number you proposed is not in the range");
        require(try2 > rangeByAddress[targetAddress][0] && try2 < rangeByAddress[targetAddress][1], "the second number you proposed is not in the range");
        require(try3 > rangeByAddress[targetAddress][0] && try3 < rangeByAddress[targetAddress][1], "the third number you proposed is not in the range");
        if (try1 == TargetNumber[targetAddress] || try2 == TargetNumber[targetAddress] || try3 == TargetNumber[targetAddress]) {
            payable(msg.sender).transfer(balances[targetAddress]);
            balances[targetAddress] = 0;
        }
        else {
            balances[msg.sender] -= balances[targetAddress];
            payable(targetAddress).transfer(balances[targetAddress]);
            // We transfer to the target address the same balance of target address, because the attackor may have a superior or equal balance.
        }
    }

    function balanceOfContract() public view returns (uint){
        return address(this).balance;
    }

    function withdraw() public payable{
    require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "you are not the owner");
    payable(msg.sender).transfer(address(this).balance);
    }
}
