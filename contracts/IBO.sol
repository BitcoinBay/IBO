import "./HumanStandardToken.sol";
import "./Ownable.sol";

pragma solidity ^0.4.17;

contract IBO is Ownable{

 HumanStandardToken token;

    uint TokenValue; //Value of each token in wei
    address ProjectOwner;

   uint8 decimals;
    
    uint numBounties;
    uint numClaims;
    
    uint markedTokenBalance;
    
    
    function() {
        
    }
    
    function withdrawEth(){
        owner.transfer(this.balance);
    }
    
     function IBO(address _tokenAddress) public {
         token = HumanStandardToken(_tokenAddress);
         decimals = token.decimals();

    }

   struct Bounty{
        uint BountyID;
        string Name;
        uint Reward;      //Reward for this bounty
        uint Available;   //bounties available
        bool CanBenefact;
       // BountyType bountyType;
       // uint claimFraction;
    }
    
   // enum BountyType{Normal,Infinite}
    enum ClaimState{Approved,Rejected,Pending}
    
    struct Claim {
        uint BountyID;
        uint ClaimID;
        address Claimer; 
        bytes32 SubmissionHash;
        
    }
    mapping(uint=>Bounty) Bounties;
    mapping(uint => Claim) Claims;
    
    
    function CreateBounty(string _name,uint _reward,uint _available,bool _CanBenefact){
        
    
        require(_available >= 1);
        require(_reward >= 1);
        uint totalReward =_reward*_available;
        
        require((token.balanceOf(this) - markedTokenBalance)>= totalReward);
      
        markedTokenBalance += totalReward;
        
        numBounties++;
        
        Bounties[numBounties] = Bounty(numBounties,_name,_reward,_available,_CanBenefact);
    
    }
    
    function CreateClaim(uint _BountyID,address _Claimer,bytes32 _SubmissionHash){
        numClaims++;
        
        Claims[numClaims] = Claim(_BountyID,numClaims,_Claimer,_SubmissionHash);
    }
    
  function Benefact(uint _BountyID) payable{
      
      Bounty _Bounty = Bounties[_BountyID];
     
      uint BountyPrice = _Bounty.Reward*TokenValue;      //Price of 1 Bounty in Wei
      uint numBounties = msg.value/BountyPrice;        //Number of Bounties benefacted
      uint Remainder;                                   //Remaining Wei
      uint TotalReward;                                 // Total Token Reward
      
      if(numBounties>_Bounty.Available){
          TotalReward = _Bounty.Available*_Bounty.Reward;
      } else{
          TotalReward = numBounties*_Bounty.Reward;
      }
                Remainder = msg.value%_Bounty.Reward;

      Remainder = msg.value%BountyPrice;
      token.transfer(msg.sender, TotalReward);
      msg.sender.transfer(Remainder);
      
      Bounties[_BountyID].Available -= numBounties;
      markedTokenBalance -= TotalReward;
      
      
  }  
    
  function approveClaim(uint claimID) {
      Claim claim = Claims[claimID];
      uint bountyID = claim.BountyID;
      Bounty bounty = Bounties[bountyID];
      require(token.transfer(claim.Claimer, bounty.Reward));
      bounty.Available--;
  }
   function GetBounty(uint _BountyID) constant returns(string, uint, uint){
       Bounty _bounty = Bounties[_BountyID];
       return (_bounty.Name,_bounty.Reward,_bounty.Available);
   }
   
   function GetClaim(uint _ClaimID) constant returns(uint, uint, address, bytes32){
       Claim _claim = Claims[_ClaimID];
       return (_claim.BountyID,_claim.ClaimID,_claim.Claimer,_claim.SubmissionHash);
   }
   
   function GetMarkedTokenBalance() constant returns(uint){
       return(markedTokenBalance);
   }
 
}


