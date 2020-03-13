pragma solidity >=0.4.21 <0.7.0;

import "./OSM.sol";
// import "./Feeder.sol";

contract Trading {
    uint competsid = 0;
    uint starterWallet = 1000;

    struct Contest {
        uint id;
        uint startDate;
        uint endDate;
        uint joinFee;
        address[] players;
    }

    struct TraderInfo {
        uint wallet;
        uint ethers;
    }

    Contest[] contests;
    mapping(address => uint) public contestForTraders;
    mapping(uint => uint) private payersContestCount;
    mapping(address => TraderInfo) public tradesInfos;
    event logger(uint);
    event logger(bool);

    function joinContest(uint _contestId) public returns (uint, uint, address, bool) {
        bool creation = false;
        if (!containsContest(_contestId)) {
            address[] memory players;
            contests.push(Contest(_contestId, now, now +  10 minutes, 5, players));
            creation = true;
        } else {
            uint end;
            (,end,) = getContest(_contestId);
            if (end <= now) {
                return (0, 0, msg.sender, creation);
            }
        }
        contestForTraders[msg.sender] = _contestId;
        contests[getContestIndex(_contestId)].players.push(msg.sender);
        payersContestCount[_contestId]++;
        tradesInfos[msg.sender] = TraderInfo(1000, 0);

        return (tradesInfos[msg.sender].wallet, tradesInfos[msg.sender].ethers, msg.sender, creation);
    }

    function containsContest(uint _contestId) private view returns (bool) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return true;
            }
        }

        return false;
    }

    function getContestIndex(uint _contestId) private view returns (uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return index;
            }
        }

        require(false);
        return 0;
    }

    function getContest(uint _contestId) public view returns (uint, uint, uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return (contests[index].startDate, contests[index].endDate, contests[index].joinFee);
            }
        }

        return (0, 0, 0);
    }

    function getPlayers(uint _contestId) public view returns (address[] memory) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return contests[index].players;
            }
        }

        address[] memory result;    
        return result;
    }

    function getTraderWallet(address _a) public view returns (uint, uint) {
        return (tradesInfos[_a].wallet, tradesInfos[_a].ethers);
    }
    
    
    function getPrize(address payable _winner) public payable {
        uint contestId = contestForTraders[_winner];
        require(_winner == getWinner(contestId));

        uint prize = getPrizeTotal(contestId);

        _winner.transfer(prize);
    }

    function getPrizeTotal(uint _contestId) public view returns (uint) {
        uint fee;

        (,,fee) = getContest(_contestId);
        uint prize = fee * contests[getContestIndex(_contestId)].players.length;

        return prize;
    }

    function getWinner(uint _contestId) public view returns (address) {
        address[] memory players = getPlayers(_contestId);

        address winner = players[0];
        uint winnerTotal = 0;

        for (uint index = 0; index < players.length; index++) {
            uint currency;
            uint eth;

            (currency, eth) = getTraderWallet(players[index]);
            uint total = currency + eth * getEtherPrice();
             
            if (total > winnerTotal) {
                winner = players[index];
                winnerTotal = total;
            }
        }

        return winner;
    }

    function getTotalPlayers(uint _contestId) public view returns (uint) {
        return contests[getContestIndex(_contestId)].players.length;
    } 

    function trade(uint _amount, uint _contestId, bool buying) public returns (uint, uint, address) {
        if (buying) {
            require((tradesInfos[msg.sender].wallet - _amount) > 0);
            tradesInfos[msg.sender].wallet -= _amount;
            tradesInfos[msg.sender].ethers += _amount * getEtherPrice();

            return (tradesInfos[msg.sender].wallet, tradesInfos[msg.sender].ethers, msg.sender);
        }
    
        tradesInfos[msg.sender].wallet += _amount * getCurrencyPrice();
        tradesInfos[msg.sender].ethers -= _amount;
        return (tradesInfos[msg.sender].wallet, tradesInfos[msg.sender].ethers, msg.sender);
    }

    function setRoomEnd(uint _contestId, uint _end) public returns (uint, uint, uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                contests[index].endDate = _end;
                return (contests[index].startDate, contests[index].endDate, contests[index].joinFee);
            }
        }

        return (0, 0, 0);
    }

    function setRoomFee(uint _contestId, uint _fee) public returns (uint, uint, uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                contests[index].joinFee = _fee;
                return (contests[index].startDate, contests[index].endDate, contests[index].joinFee);
            }
        }

        return (0, 0, 0);
    }

    function sell(uint _amount, uint _contestId) private returns (uint, uint, address) {
        TraderInfo storage infos = tradesInfos[msg.sender];
        infos.wallet += _amount * getCurrencyPrice();
        infos.ethers -= _amount;

        return (infos.wallet, infos.ethers, msg.sender);
    }

    function getCurrencyPrice() public view returns (uint) {
        return 1;
    }

    function getEtherPrice() public view returns (uint) {
        return 1;
    }
    
    function checkContestStatus(uint _contestId) public {

    }

    OSM osmInstance = OSM(0x9fffe440258b79c5d6604001674a4722ffc0f7bc);
    function getPrice() public view returns (uint) {
        return uint(osmInstance.read()) ;
    }
}