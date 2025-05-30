// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;


///@notice The contract allows anyone to stake and unstake Ether. When a user sells a new item
///in the shop, the funds are unlocked by the Shop contract. If the user is considered malicious
///by the DAO, the funds are slashed. 
///@dev Security review is pending... should we deploy this?
///@dev custom:ctf This contract is part of the exercises at https://github.com/jcr-security/solidity-security-teaching-resources
contract VulnerableVault { 

    // The unlocked balance of the users in the vault
    mapping (address => uint256) balance;
    // The amount of funds locked for selling purposes
    mapping (address => uint256) lockedFunds;
    // The address of the powerseller NFT contract
    address powerseller_nft;
    // The address of the Shop contract
    address shop_addr;

    /************************************** Events and modifiers *****************************************************/

    event Stake(address user, uint256 amount);
    event Unstake(address user, uint256 amount);
    event unlockedFunds(address user, uint256 amount);
    event Rewards(address user, uint256 amount);
    

    ///@notice Check if the user has enough unlocked funds staked
    modifier enoughUnlocked(uint256 amount) {
		require(
            (balance[msg.sender] - amount) > 0,
            "Amount cannot be unstaked"
        );
        _;
    }

    ///@notice Check if the caller is the Shop contract
    modifier onlyShop() {
        require(msg.sender == shop_addr, "Unauthorized!");
        _;
    }

    /************************************** External  ****************************************************************/ 

    ///@notice Constructor, initializes the contract
    ///@param token The address of the powerseller NFT contract
    ///@param shop The address of the Shop contract
    constructor(address token, address shop) {
        powerseller_nft = token;
        shop_addr = shop;
    }


    ///@notice Desposit and stake funds in the vault, only withdrawable if the Shop contract allows
    function doStake() external payable {
        require(msg.value > 0, "Amount cannot be zero");
        lockedFunds[msg.sender] += msg.value;
        
        emit Stake(msg.sender, msg.value);
    }
	

    ///@notice withdraw unlocked funds from the vault
    ///@param amount The amount of funds to withdraw 
    function doUnstake(uint256 amount) external enoughUnlocked(amount) {	
        require(amount > 0, "Amount cannot be zero");

        balance[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Unstake failed");

        emit Unstake(msg.sender, amount);
	}

	///@notice Unlock staked funds for a user, only the shop contract can perform this action
	///@param user affected user
	///@param amount The amount of funds to unlock
	function unlockFunds(address user, uint256 amount) external onlyShop() {
	    require(lockedFunds[user] >= amount, "Not enough locked funds");
	    lockedFunds[user] -= amount;
	    balance[user] += amount;
	
	    emit unlockedFunds(user, amount);
	}



    ///@notice Claim rewards generated by slashing malicious users. 
    /// First checks if the user is elegible through the checkPrivilege function that will revert if not. 

	function claimRewards() external { 
	    uint256 amount;
	
	    // Check if the user is eligible by calling the powerseller_nft contract
	    (bool success, ) = powerseller_nft.call(
	        abi.encodeWithSignature(
	            "checkPrivilege(address)",
	            msg.sender
	        )
	    );
	    require(success, "Not authorized to claim rewards");
	
	    /*
	    * Rewards distribution logic goes here.
	    * Consider this missing piece of code to be correct, do not ponder
	    * about potential lack of validation or checks here
	    */
	
	    emit Rewards(msg.sender, amount);
	}



    /************************************** Views  *******************************************************/

    ///@notice Get the balance of the vault
	function vaultBalance () public view returns (uint256) {
		return address(this).balance;
	}
	

    ///@notice Get the unlocked balance of a user
    ///@param user The address of the user to query
	function userBalance (address user) public view returns (uint256) {
		return balance[user];
	}

}
