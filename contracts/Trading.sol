pragma solidity >=0.4.21 <0.7.0;
// import "./Feeder.sol";

contract Trading {
    uint competsid = 0;
    uint starterWallet = 1000;

    struct Contest {
        uint id;
        uint startDate;
        uint endDate;
    }

    struct TraderInfo {
        uint wallet;
        uint ethers;
    }

    Contest[] contests;
    mapping(address => uint) public contestForTraders;
    mapping(address => TraderInfo) public tradesInfos;
    event logger(uint);
    event logger(bool);

    function joinContest(uint _contestId) public returns (uint, uint, address) {
        if (!containsContest(_contestId)) {
            contests.push(Contest(_contestId, now, now +  1 minutes));
        } else {
            uint end;
            (,end) = getContest(_contestId);
            if (end <= now) {
                return (0, 0, msg.sender);
            }
        }
        contestForTraders[msg.sender] = _contestId;
        tradesInfos[msg.sender] = TraderInfo(1000, 0);

        return (tradesInfos[msg.sender].wallet, tradesInfos[msg.sender].ethers, msg.sender);
    }

    function containsContest(uint _contestId) private view returns (bool) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return true;
            }
        }

        return false;
    }

    function getContest(uint _contestId) public view returns (uint, uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return (contests[index].startDate, contests[index].endDate);
            }
        }

        return (0, 0);
    }

    function getTraderWallet(address _a) public view returns (uint, uint) {
        return (tradesInfos[_a].wallet, tradesInfos[_a].ethers);
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

    function setRoomEnd(uint _contestId, uint _end) public returns (uint, uint) {
        for (uint index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                contests[index].endDate = _end;
                return (contests[index].startDate, contests[index].endDate);
            }
        }

        return (0, 0);
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
}