pragma solidity >=0.4.21 <0.7.0;

import "./OSM.sol";
// import "./Feeder.sol";

contract Trading {
    uint256 competsid = 0;
    uint256 starterWallet = 1000;

    struct Contest {
        uint256 id;
        uint256 startDate;
        uint256 endDate;
        uint256 joinFee;
        address[] players;
    }

    struct TraderInfo {
        uint256 wallet;
        uint256 ethers;
    }

    Contest[] contests;
    mapping(address => uint256) public contestForTraders;
    mapping(uint256 => uint256) private payersContestCount;
    mapping(address => TraderInfo) public tradesInfos;
    event logger(uint256);
    event logger(bool);
    event logger(address);

    function joinContest(uint256 _contestId)
        public
        payable
        returns (uint256, uint256, address, bool)
    {
        bool creation = false;
        require(msg.value == 1000000000000000 wei);
        if (!containsContest(_contestId)) {
            address[] memory players;
            contests.push(
                Contest(_contestId, now, now + 10 minutes, 1000000000000000 wei, players)
            );
            creation = true;
        } else {
            uint256 end;
            (, end, ) = getContest(_contestId);
            if (end <= now) {
                return (0, 0, msg.sender, creation);
            }
        }
        contestForTraders[msg.sender] = _contestId;
        contests[getContestIndex(_contestId)].players.push(msg.sender);
        payersContestCount[_contestId]++;
        tradesInfos[msg.sender] = TraderInfo(1000, 0);

        return (
            tradesInfos[msg.sender].wallet,
            tradesInfos[msg.sender].ethers,
            msg.sender,
            creation
        );
    }

    function containsContest(uint256 _contestId) private view returns (bool) {
        for (uint256 index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return true;
            }
        }

        return false;
    }

    function getContestIndex(uint256 _contestId)
        private
        view
        returns (uint256)
    {
        for (uint256 index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return index;
            }
        }

        require(false);
        return 0;
    }

    function getContest(uint256 _contestId)
        public
        view
        returns (uint256, uint256, uint256)
    {
        for (uint256 index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return (
                    contests[index].startDate,
                    contests[index].endDate,
                    contests[index].joinFee
                );
            }
        }

        require(false);
        return (0, 0, 0);
    }

    function getPlayers(uint256 _contestId)
        public
        view
        returns (address[] memory)
    {
        for (uint256 index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                return contests[index].players;
            }
        }

        address[] memory result;
        return result;
    }

    function getTraderWallet(address _a)
        public
        view
        returns (uint256, uint256)
    {
        return (tradesInfos[_a].wallet, tradesInfos[_a].ethers);
    }

    function getPrize(address payable _winner) public {
        require(getWinner(contestForTraders[_winner]) == _winner);
        _winner.transfer(
            1000000000000000 wei * payersContestCount[contestForTraders[_winner]] - 1
        );
    }

    function getAddress() public view returns (uint256) {
        address payable add = address(uint160(address(this)));
        uint256 b = add.balance;
        return b;
    }

    function getWinner(uint256 _contestId) public view returns (address) {
        address[] memory players = getPlayers(_contestId);

        address winner = players[0];
        uint256 winnerTotal = 0;
        uint256 winnerIndex = 0;

        for (uint256 index = 0; index < players.length; index++) {
            uint256 currency;
            uint256 eth;

            (currency, eth) = getTraderWallet(players[index]);
            uint256 total = currency + eth * getPrice();

            if (total > winnerTotal) {
                winner = players[index];
                winnerTotal = total;
                winnerIndex = index;
            }
        }

        return winner;
    }

    function getTotalPlayers(uint256 _contestId) public view returns (uint256) {
        return contests[getContestIndex(_contestId)].players.length;
    }

    function trade(uint256 _amount, uint256 _contestId, bool buying)
        public
        returns (uint256, uint256, address)
    {
        if (buying) {
            require((tradesInfos[msg.sender].wallet - _amount) > 0);
            tradesInfos[msg.sender].wallet -= _amount;
            tradesInfos[msg.sender].ethers += _amount * getPrice();

            return (
                tradesInfos[msg.sender].wallet,
                tradesInfos[msg.sender].ethers,
                msg.sender
            );
        }

        tradesInfos[msg.sender].wallet += _amount * getPrice();
        tradesInfos[msg.sender].ethers -= _amount;
        return (
            tradesInfos[msg.sender].wallet,
            tradesInfos[msg.sender].ethers,
            msg.sender
        );
    }

    function setRoomEnd(uint256 _contestId, uint256 _end)
        public
        returns (uint256, uint256, uint256)
    {
        for (uint256 index = 0; index < contests.length; index++) {
            if (contests[index].id == _contestId) {
                contests[index].endDate = _end;
                return (
                    contests[index].startDate,
                    contests[index].endDate,
                    contests[index].joinFee
                );
            }
        }

        require(false);
        return (0, 0, 0);
    }

    function sell(uint256 _amount, uint256 _contestId)
        private
        returns (uint256, uint256, address)
    {
        TraderInfo storage infos = tradesInfos[msg.sender];
        infos.wallet += _amount * getPrice();
        infos.ethers -= _amount;

        return (infos.wallet, infos.ethers, msg.sender);
    }

    OSM osmInstance = OSM(0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763);
    function getPrice() public view returns (uint256) {
        return uint256(osmInstance.read());
    }
}
