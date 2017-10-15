import "./HumanStandardToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

pragma solidity 0.4.17;

contract IBO is Ownable{
          using SafeMath for uint256;


 HumanStandardToken token;

    uint TokenValue; //Value of each token in wei
    address ProjectOwner;

    uint8 decimals;

    uint numBounties;
    uint numClaims;

    uint markedTokenBalance;



    function withdrawEth(){
        owner.transfer(this.balance);
    }

     function IBO(address _tokenAddress) public {
         token = HumanStandardToken(_tokenAddress);
         decimals = token.decimals();

    }

   struct Bounty{
        uint BountyID;
        string  Name;
        uint Reward;      //Reward for this bounty
        uint Available;   //bounties available
        bool CanBenefact;
        uint numClaims;
        BountyType bountyType;
        uint claimFraction; 
        mapping(uint=>Claim) claims;
       // BountyType bountyType;
       // uint claimFraction;
    }

    struct Claim {
        uint BountyID;
        uint ClaimID;
        address Claimer;
        bytes32 SubmissionHash;

    }


   // enum BountyType{Normal,Infinite,Milestone}
      enum BountyType{Normal,Milestone,Infinite}

    enum ClaimState{Approved,Rejected,Pending}


    mapping(uint=>Bounty) Bounties;


    function CreateBountyNormal(string _name,uint _reward,uint _available,bool _CanBenefact){


        require(_available >= 1);
        require(_reward >= 1);
        uint totalReward =_reward*_available;

        require((token.balanceOf(this) - markedTokenBalance)>= totalReward);

        markedTokenBalance += totalReward;

        numBounties++;

        Bounties[numBounties] = Bounty(numBounties, _name, _reward, _available, _CanBenefact, 0,BountyType.Normal,0);

    }
    
    function CreateBountyInfinite(string _name,uint _reward,uint _claimFraction){
            require(_reward >= 1);
            require((token.balanceOf(this) - markedTokenBalance)>= _reward);
            markedTokenBalance += _reward;
            numBounties++;
            
        Bounties[numBounties] = Bounty(numBounties,_name,_reward,1,false,0,BountyType.Infinite,_claimFraction); 

    }
      /*function CreateBountyMilestone(string _name,uint _reward){
            require(_reward >= 1);
            require((token.balanceOf(this) - markedTokenBalance)>= _reward);
            markedTokenBalance += _reward;
            numBounties++;
            
        Bounties[numBounties] = Bounty(numBounties,_name,_reward,1,false,0,BountyType.Infinite,_claimFraction); 

    }*/

    function CreateClaim(uint _BountyID, bytes32 _SubmissionHash){
      Bounty storage bounty =  Bounties[_BountyID];
      bounty.numClaims++;
  if (bounty.bountyType == BountyType.Normal){
      bounty.claims[bounty.numClaims] = Claim(_BountyID,bounty.numClaims,msg.sender,_SubmissionHash);
      }else if(bounty.bountyType == BountyType.Infinite){
          //calculate payout
              uint payout = (bounty.Reward).mul(bounty.claimFraction).div(1000000);
                          //transfer _tokenAddress

            require(token.transfer(msg.sender, payout));
                          //subtract from reward

            bounty.Reward -= payout;

              
      }
    
}
  function Benefact(uint _BountyID) payable{

      Bounty storage _Bounty = Bounties[_BountyID];

      uint BountyPrice = _Bounty.Reward*TokenValue;      //Price of 1 Bounty in Wei
       numBounties = msg.value/BountyPrice;        //Number of Bounties benefacted
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

  function approveClaim(uint bountyId, uint claimID) {
      Bounty storage b = Bounties[bountyId];
      Claim storage claim = b.claims[claimID];
      uint bountyID = claim.BountyID;
      Bounty storage bounty = Bounties[bountyID];
      require(token.transfer(claim.Claimer, bounty.Reward));
      bounty.Available--;
  }
   function GetBounty(uint _BountyID) constant returns(string, uint, uint){
       Bounty storage _bounty = Bounties[_BountyID];
       return (_bounty.Name,_bounty.Reward,_bounty.Available);
   }

   function GetClaim(uint bountyID, uint _ClaimID) constant returns(uint, uint, address, bytes32){
       Bounty storage bounty = Bounties[bountyID];
       Claim storage _claim= bounty.claims[_ClaimID];
       return (_claim.BountyID,_claim.ClaimID,_claim.Claimer,_claim.SubmissionHash);
   }

   function GetMarkedTokenBalance() constant returns(uint){
       return(markedTokenBalance);
   }

}
