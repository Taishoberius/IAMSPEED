pragma solidity >=0.4.21 <0.7.0;
// import "./Feeder.sol";

contract Trading {
    uint competsid = 0;
    uint starterWallet = 1000;

    struct Contest {
        uint id;
        /*uint startDate;
        uint endDate;*/
    }

    struct Trader {
        uint wallet;
        uint ethers;
        address trader;
    }

    Contest[] contests;
    mapping(uint => Trader[]) internal contestForTraders;
    

    function createContest() public returns (uint) {
        Contest memory contest = Contest(++competsid);
        contests.push(contest);
        joinContest(contest.id);
        
        return contest.id;
    }

    function joinContest(uint _contestId) public {
        contestForTraders[_contestId].push(Trader(starterWallet, 0, msg.sender));
    }

    function trade(uint _amount, uint _contestId, bool buying) public {
        if (buying) {
            buy(_amount, _contestId);
            return;
        }
    
        sell(_amount, _contestId);
    }

    function buy(uint _amount, uint _contestId) private {
        Trader memory trader = getTraderForContest(_contestId);
        require((trader.wallet - _amount) >= 0, "No Tune ma gueule");
        trader.wallet -= _amount;
        trader.ethers += _amount * getPrice();
    }

    function sell(uint _amount, uint _contestId) private {
        Trader memory trader = getTraderForContest(_contestId);
        trader.wallet += _amount;
        trader.ethers -= _amount * getPrice();
    }

    function getTraderForContest(uint _contestId) private returns (Trader memory) {
        Trader[] memory traders = contestForTraders[_contestId];
        for (uint index=0; index < traders.length; index++) {
            if (traders[index].trader == msg.sender) {
                return traders[index];
            }
        }

        return Trader(1000, 1, msg.sender);
    }

    function getPrice() private returns (uint) {
        return 2;
    }
    
    function checkContestStatus(uint _contestId) public {
    }
}