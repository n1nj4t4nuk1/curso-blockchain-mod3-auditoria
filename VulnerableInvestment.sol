// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


uint256 constant MIN_INVESTED = 1_000;
uint256 constant MAX_PERCENTAGE = 10;
uint256 constant PERCENT = 100;


///@notice The contract allows anyone to perform some investments. Then, it allows to distribute some of the invested
/// amount to the beneficiaries. The caller will be rewarded with a percentage of the distributed amount as incentive.
///@custom:exercise This contract is part of JC's mock-audit exercise at https://github.com/jcr-security/solidity-security-teaching-resources
contract VulnerableInvestment {

    /************************************** State vars  and Structs *******************************************************/

    ///@notice The total amount of vested tokens
	uint256 total_invested;
    ///@notice The address of the admin
    address admin;
    ///@notice The addresses of the beneficiaries of the investment
    address[10] beneficiaries;
    ///@notice The period of time between each distribution
    uint256 distribute_period;
    ///@notice The block number of the last distribution
    uint256 latest_distribution;


    /************************************** Events and modifiers *****************************************************/

    event Benefits(uint256 amount);


    ///@notice  Checks that the caller is the admin
	modifier onlyOwner() {
	    require(msg.sender == admin, "Unauthorized");
	    _;
	}


    ///@notice Transfers a percentage of the vested tokens to the caller as reward
    ///@param percentage The percentage of the vested tokens to transfer
    modifier returnRewards(uint256 percentage) {
        // 0.1% of the distributed amount will be rewarded to the distributor as incentive
        uint256 reward = total_invested * percentage / 10_000;

        (bool success, ) =  payable(msg.sender).call{value: reward}("");
        require(success, "Reward payment failed");

        _;
    }


    /************************************** External  ****************************************************************/ 
    ///@notice Creates a new investment contract
    ///@param beneficiary_addresses The addresses of the beneficiaries of the investment
    ///@param period_in_blocks The period of time between each distribution
    constructor(address[10] memory beneficiary_addresses, uint256 period_in_blocks) {
        admin = msg.sender;
        beneficiaries = beneficiary_addresses;
        distribute_period = period_in_blocks;
        latest_distribution = block.number;
    }


    ///@notice Modify configuration parameters, only the owner can do it
    ///@param n_blocks The new period of time between each distribution
    function updateConfig(uint256 n_blocks) external onlyOwner() {
        distribute_period = n_blocks;
    }


    ///@notice Invests funds in the contract
    function doInvest() external payable {
        /*
        * Investing logic goes here.
        * Consider this missing piece of code to be correct, do not ponder
        * about potential lack of validtaion or checks here
        */
    }


    ///@notice Distributes a percentage of the total vested to the beneficiaries. Before that, the caller will be 
    /// rewarded with a percentage of the distributed amount as detailed in the returnRewards modifier
    ///@param percentage The percentage of the vested tokens to distribute
	function distributeBenefits(uint256 percentage) external {
	    // Checks
	    require(total_invested >= MIN_INVESTED, "Not big enough to avoid rounding issues");
	    require(percentage < MAX_PERCENTAGE, "Should be below the max distribution percentage");
	    require(block.number - latest_distribution >= distribute_period, "Too soon");
	
	    // Effects
	    latest_distribution = block.number;
	    uint256 amount = total_invested * percentage / PERCENT;
	    total_invested -= amount;
	
	    // Interactions
	    doDistribute(amount);
	
	    // Reward logic (new Interaction after all Effects)
	    uint256 reward = amount / 1000; // 0.1% of amount
	    (bool success, ) = payable(msg.sender).call{value: reward}("");
	    require(success, "Reward payment failed");
	
	    emit Benefits(amount);
	}

	

    /************************************** Internal *****************************************************************/
    ///@notice Distributes the benefits to the beneficiaries
    ///@param amount The amount of tokens to distribute
    function doDistribute(uint256 amount) internal {
        /*
        * Benefits distribution logic goes here and strictly follows Checks-Effects-Interactionc :).
        * Consider this missing piece of code to be correct, do not ponder
        * about potential lack of validtaion or checks here
        */
    }

}

