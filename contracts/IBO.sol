import "./HumanStandardToken.sol";

pragma solidity ^0.4.17;

contract IBO{

 HumanStandardToken token;



   uint8 decimals;
    
    uint numBounties;
    uint numClaims;
    
     function IBO(address _tokenAddress) public {
         token = HumanStandardToken(_tokenAddress);
         decimals = token.decimals();
    }

   struct Bounty{
        uint BountyID;
        string Name;
        uint Reward;      //Reward for this bounty
        uint Available;   //bounties available
    }
    
    enum ClaimState{Approved,Rejected,Pending}
    
    struct Claim {
        uint BountyID;
        uint ClaimID;
        address Claimer; 
        bytes32 SubmissionHash;
        
    }
    mapping(uint=>Bounty) Bounties;
    mapping(uint => Claim) Claims;
    
    
    function CreateBounty(string _name,uint _reward,uint _available){
        
        _reward = _reward*10**decimals;
        require(token.balanceOf(this) >= _reward*_available);
        
        numBounties++;
        
        Bounties[numBounties] = Bounty(numBounties,_name,_reward,_available);
    
    }
    
    function CreateClaim(uint _BountyID,address _Claimer,bytes32 _SubmissionHash){
        numClaims++;
        
        Claims[numClaims] = Claim(_BountyID,numClaims,_Claimer,_SubmissionHash);
    }
    
  function acceptClaim(uint claimID) {
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
 
}


