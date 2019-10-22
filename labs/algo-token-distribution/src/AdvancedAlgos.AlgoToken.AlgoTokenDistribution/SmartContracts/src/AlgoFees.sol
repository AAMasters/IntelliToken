pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

import "./IIntelliMiner.sol";
import "./ERC20TokenHolder.sol";
import "./IntelliSystemRole.sol";
import "./IntelliCoreTeamRole.sol";

contract IntelliFees is ERC20TokenHolder, IntelliSystemRole, IntelliCoreTeamRole {
    using SafeERC20 for IERC20;

    uint256 private constant CAT_0_VALUE_PROPORTION = 1;
    uint256 private constant CAT_1_VALUE_PROPORTION = 10;
    uint256 private constant CAT_2_VALUE_PROPORTION = 20;
    uint256 private constant CAT_3_VALUE_PROPORTION = 30;
    uint256 private constant CAT_4_VALUE_PROPORTION = 40;
    uint256 private constant CAT_5_VALUE_PROPORTION = 50;

    address[] private _miners;
    mapping(address => uint256) private _minersByAddress;

    constructor(address tokenAddress)
        ERC20TokenHolder(tokenAddress)
        IntelliSystemRole()
        IntelliCoreTeamRole()
        public {
        _miners.push(address(0)); // Reserved as a marker for unregistered miner.
    }

    function registerMiner(address minerAddress) public notTerminated onlyCoreTeam {
        require(_miners.length < 1000);
        require(_minersByAddress[minerAddress] == 0);

        IIntelliMiner intelliMiner = IIntelliMiner(minerAddress);

        require(intelliMiner.isIntelliMiner());

        uint8 minerCategory = intelliMiner.getCategory();

        require(minerCategory >= 0 && minerCategory <= 5);

        _minersByAddress[minerAddress] = _miners.length;
        _miners.push(minerAddress);
    }

    function unregisterMiner(address minerAddress) public notTerminated onlyCoreTeam {
        require(_miners.length > 1);

        if(_miners.length == 2) {

            // Just remove the only registered miner...
            delete _miners[1];
            _miners.length = 1;
            delete _minersByAddress[minerAddress];

        } else {

            if(_minersByAddress[minerAddress] != _miners.length) {
                // Move the latest miner to the gap...
                _miners[_minersByAddress[minerAddress]] = _miners[_miners.length - 1];
            }

            delete _miners[_miners.length - 1];
            _miners.length--;
            delete _minersByAddress[minerAddress];
        }
    }

    function mine() public notTerminated onlySystem {
        require(_miners.length > 1);

        uint256 currentFeesBalance = _token.balanceOf(address(this));

		require(currentFeesBalance > 0);

        // Count how many ENABLED miners we have for each category...
        uint256[6] memory miners;

        for(uint256 i = 1; i < _miners.length; i++) {
            IIntelliMiner intelliMiner = IIntelliMiner(_miners[i]);

            if(!intelliMiner.isMining()) continue;

            uint8 minerCategory = intelliMiner.getCategory();

            if(minerCategory == 0) {
                miners[0]++;
            } else if(minerCategory == 1) {
                miners[1]++;
            } else if(minerCategory == 2) {
                miners[2]++;
            } else if(minerCategory == 3) {
                miners[3]++;
            } else if(minerCategory == 4) {
                miners[4]++;
            } else if(minerCategory == 5) {
                miners[5]++;
            }
        }

        // Calculate the fee to pay per miner according to its category...
        uint256 totalProportion = CAT_0_VALUE_PROPORTION * miners[0] +
            CAT_1_VALUE_PROPORTION * miners[1] +
            CAT_2_VALUE_PROPORTION * miners[2] +
            CAT_3_VALUE_PROPORTION * miners[3] +
            CAT_4_VALUE_PROPORTION * miners[4] +
            CAT_5_VALUE_PROPORTION * miners[5];

        uint256[6] memory feePerMiner;

        feePerMiner[0] = currentFeesBalance * CAT_0_VALUE_PROPORTION / totalProportion;
        feePerMiner[1] = currentFeesBalance * CAT_1_VALUE_PROPORTION / totalProportion;
        feePerMiner[2] = currentFeesBalance * CAT_2_VALUE_PROPORTION / totalProportion;
        feePerMiner[3] = currentFeesBalance * CAT_3_VALUE_PROPORTION / totalProportion;
        feePerMiner[4] = currentFeesBalance * CAT_4_VALUE_PROPORTION / totalProportion;
        feePerMiner[5] = currentFeesBalance * CAT_5_VALUE_PROPORTION / totalProportion;

        // Transfer the fees to ENABLED miners...
        for(i = 1; i < _miners.length; i++) {
            intelliMiner = IIntelliMiner(_miners[i]);

            if(!intelliMiner.isMining()) continue;

            minerCategory = intelliMiner.getCategory();

			_token.safeTransfer(intelliMiner.getMiner(), feePerMiner[minerCategory]);
        }
    }

    function terminate() public onlyCoreTeam {
        _terminate();
    }

    function getMinerCount() public view returns (uint256) {
        return _miners.length - 1;
    }

    function getMinerByIndex(uint256 index) public view returns (address) {
        return _miners[index + 1];
    }
}
