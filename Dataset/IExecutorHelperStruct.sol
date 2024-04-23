// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExecutorHelperStruct {
  struct Swap {
    bytes data;
    bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
  }

  struct SwapExecutorDescription {
    Swap[][] swapSequences;
    address tokenIn;
    address tokenOut;
    uint256 minTotalAmountOut;
    address to;
    uint256 deadline;
    bytes positiveSlippageData;
  }

  struct UniSwap {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 collectAmount; // amount that should be transferred to the pool
    uint32 swapFee;
    uint32 feePrecision;
    uint32 tokenWeightInput;
  }

  struct StableSwap {
    address pool;
    address tokenFrom;
    address tokenTo;
    uint8 tokenIndexFrom;
    uint8 tokenIndexTo;
    uint256 dx;
    uint256 poolLength;
    address poolLp;
    bool isSaddle; // true: saddle, false: stable
  }

  struct CurveSwap {
    address pool;
    address tokenFrom;
    address tokenTo;
    int128 tokenIndexFrom;
    int128 tokenIndexTo;
    uint256 dx;
    bool usePoolUnderlying;
    bool useTriCrypto;
  }

  struct UniswapV3KSElastic {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    uint160 sqrtPriceLimitX96;
    bool isUniV3; // true = UniV3, false = KSElastic
  }

  struct BalancerV2 {
    address vault;
    bytes32 poolId;
    address assetIn;
    address assetOut;
    uint256 amount;
  }

  struct DODO {
    address recipient;
    address pool;
    address tokenFrom;
    address tokenTo;
    uint256 amount;
    address sellHelper;
    bool isSellBase;
    bool isVersion2;
  }

  struct GMX {
    address vault;
    address tokenIn;
    address tokenOut;
    uint256 amount;
    address receiver;
  }

  struct Synthetix {
    address synthetixProxy;
    address tokenIn;
    address tokenOut;
    bytes32 sourceCurrencyKey;
    uint256 sourceAmount;
    bytes32 destinationCurrencyKey;
    bool useAtomicExchange;
  }

  struct Platypus {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 collectAmount; // amount that should be transferred to the pool
  }

  struct PSM {
    address router;
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    address recipient;
  }

  struct WSTETH {
    address pool;
    uint256 amount;
    bool isWrapping;
  }

  struct Maverick {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 swapAmount;
    uint256 sqrtPriceLimitD18;
  }

  struct SyncSwap {
    bytes _data;
    address vault;
    address tokenIn;
    address pool;
    uint256 collectAmount;
  }

  struct AlgebraV1 {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    uint160 sqrtPriceLimitX96;
    uint256 senderFeeOnTransfer; // [ FoT_FLAG(1 bit) ... SENDER_ADDRESS(160 bits) ]
  }

  struct BalancerBatch {
    address vault;
    bytes32[] poolIds;
    address[] path; // swap path from assetIn to assetOut
    bytes[] userDatas;
    uint256 amountIn; // assetIn amount
  }

  struct Mantis {
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 amount;
    address recipient;
  }

  struct IziSwap {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 swapAmount;
    int24 limitPoint;
  }

  struct TraderJoeV2 {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
  }

  struct LevelFiV2 {
    address pool;
    address fromToken;
    address toToken;
    uint256 amountIn;
    uint256 minAmountOut;
    address recipient; // receive token out
  }

  struct GMXGLP {
    address rewardRouter;
    address stakedGLP;
    address glpManager;
    address yearnVault;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    address recipient;
  }

  struct Vooi {
    address pool;
    address fromToken;
    address toToken;
    uint256 fromID;
    uint256 toID;
    uint256 fromAmount;
    address to;
  }

  struct VelocoreV2 {
    address vault;
    uint256 amount;
    address tokenIn;
    address tokenOut;
    address stablePool; // if not empty then use stable pool
    address wrapToken;
    bool isConvertFirst;
  }

  struct MaticMigrate {
    address pool;
    address tokenAddress; // should be POL
    uint256 amount;
    address recipient; // empty if migrate
  }

  struct Kokonut {
    address pool;
    uint256 dx;
    uint256 tokenIndexFrom;
    address fromToken;
    address toToken;
  }

  struct BalancerV1 {
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 amount;
  }

  struct SwaapV2 {
    address router;
    uint256 amount;
    bytes data;
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct ArbswapStable {
    address pool;
    uint256 dx;
    uint256 tokenIndexFrom;
    address tokenIn;
    address tokenOut;
  }

  struct BancorV2 {
    address pool;
    address[] swapPath;
    uint256 amount;
    address recipient;
  }

  struct Ambient {
    address pool;
    uint128 qty;
    address base;
    address quote;
    uint256 poolIdx;
    uint8 settleFlags;
  }

  struct UniV1 {
    address pool;
    uint256 amount;
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct LighterV2 {
    address orderBook;
    uint256 amount;
    bool isAsk; // isAsk = orderBook.isAskOrder(orderId);
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct EtherFiWeETH {
    uint256 amount;
    bool isWrapping;
  }

  struct Kelp {
    uint256 amount;
    address tokenIn;
  }

  struct EthenaSusde {
    uint256 amount;
    address recipient;
  }

  struct RocketPool {
    address pool;
    uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
  }

  struct MakersDAI {
    uint256 isRedeemAndAmount; // 1 isRedeem + 127 empty + 128 amount token in
    address recipient;
  }

  struct Renzo {
    address pool;
    uint256 amount;
    address tokenIn;
    address tokenOut;
  }

  struct FrxETH {
    address pool;
    uint256 amount;
    address tokenOut;
  }

  struct SfrxETH {
    address pool;
    uint256 amount;
    address tokenOut;
    address recipient;
  }

  struct SfrxETHConvertor {
    address pool;
    uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct OriginETH {
    address pool;
    uint256 amount;
  }

  struct Permit {
    uint256 deadline;
    uint256 amount;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  struct PufferFinance {
    address pool;
    bool isStETH;
    Permit permit;
  }
}
