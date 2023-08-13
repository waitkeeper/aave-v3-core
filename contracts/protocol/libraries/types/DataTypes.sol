// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library DataTypes {
  struct ReserveData {
    //stores the reserve configuration
    // 配置项
    ReserveConfigurationMap configuration;
    //the liquidity index. Expressed in ray
    // 流动性池自创立到更新时间戳之间的累计利率
    uint128 liquidityIndex;
    //the current supply rate. Expressed in ray
    // 当前的存款利率
    uint128 currentLiquidityRate;
    // 浮动借款利率自流动性池建立以来的累计利率
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;
    // 当前借款浮动利率
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate;
    //the current stable borrow rate. Expressed in ray
    // 当前借款固定利率
    uint128 currentStableBorrowRate;
    //timestamp of last update
    // 上次数据更新时间戳
    uint40 lastUpdateTimestamp;
    // 存储资产的ID
    //the id of the reserve. Represents the position in the list of the active reserves
    uint16 id;
    //aToken address
    // atoken代币的地址
    address aTokenAddress;
    // 当用户从流动性池中借款时,和存款类似，协议会按照借款类型为用户铸造不同的代币
    //stableDebtToken address
    // 固定利率借款代币地址
    address stableDebtTokenAddress;
    //variableDebtToken address
    // 浮动利率借款代币地址
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    // 利率策略合约地址
    address interestRateStrategyAddress;
    //the current treasury balance, scaled
    // 当前准备金余额
    uint128 accruedToTreasury;
    //the outstanding unbacked aTokens minted through the bridging feature
    // 通过桥接功能铸造的未偿还的无担保代币
    uint128 unbacked;
    //the outstanding debt borrowed against this asset in isolation mode
    // 以该资产借入的未偿还债务的单独模式
    uint128 isolationModeTotalDebt;
  }
  // ReserveConfigurationMap 其实是多个数据库值，为了节省gas，把多个数据压缩到一起了
  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold    Liquidation threshold
    //bit 32-47: Liq. bonus        Liquidation bonus
    //bit 48-55: Decimals  质押代币的ERC20精度
    //bit 56: reserve is active  质押品可以使用
    //bit 57: reserve is frozen 质押品冻结，不可以使用
    //bit 58: borrowing is enabled 是否可以贷款
    //bit 59: stable rate borrowing enabled 是否可以固定利率贷出
    //bit 60: asset is paused  资产是否被暂停
    //bit 61: borrowing in isolation mode is enabled 资产是否可以在isoltion mode内使用
    //bit 62-63: reserved 保留位，后期扩展
    //bit 64-79: reserve factor 储备系数，即借款利息中上缴aave风险准备金的比例
    //bit 80-115 borrow cap in whole tokens, borrowCap == 0 => no cap 代币贷出上限
    //bit 116-151 supply cap in whole tokens, supplyCap == 0 => no cap 代币存款上线
    //bit 152-167 liquidation protocol fee 清算过程中，aave收取的费用
    //bit 168-175 eMode category  e-mode类别
    //bit 176-211 unbacked mint cap in whole tokens, unbackedMintCap == 0 => minting disabled  无存入直接铸造的代币数量上限（此变量用户跨链）
    //bit 212-251 debt ceiling for isolation mode with (ReserveConfiguration::DEBT_CEILING_DECIMALS) decimals  隔离模式中此抵押品的贷出资产上限
    //bit 252-255 unused  还未使用

    uint256 data;
  }

  struct UserConfigurationMap {
    /**
     * @dev Bitmap of the users collaterals and borrows. It is divided in pairs of bits, one pair per asset.
     * The first bit indicates if an asset is used as collateral by the user, the second whether an
     * asset is borrowed by the user.
     */
    // 这是一个256bit的数据，从低到高每两bit为一组，可以表示128种不同资产的存款和贷款情况
    // 每组底位表示是否存在贷款，高位表示是否存在抵押物
    uint256 data;
  }

  struct EModeCategory {
    // each eMode category has a custom ltv and liquidation threshold
    uint16 ltv;
    uint16 liquidationThreshold;
    uint16 liquidationBonus;
    // each eMode category may or may not have a custom oracle to override the individual assets price oracles
    address priceSource;
    string label;
  }

  enum InterestRateMode {
    NONE,
    STABLE,
    VARIABLE
  }

  struct ReserveCache {
    uint256 currScaledVariableDebt;
    uint256 nextScaledVariableDebt;
    uint256 currPrincipalStableDebt;
    uint256 currAvgStableBorrowRate;
    uint256 currTotalStableDebt;
    uint256 nextAvgStableBorrowRate;
    uint256 nextTotalStableDebt;
    uint256 currLiquidityIndex;
    uint256 nextLiquidityIndex;
    uint256 currVariableBorrowIndex;
    uint256 nextVariableBorrowIndex;
    uint256 currLiquidityRate;
    uint256 currVariableBorrowRate;
    uint256 reserveFactor;
    ReserveConfigurationMap reserveConfiguration;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    uint40 reserveLastUpdateTimestamp;
    uint40 stableDebtLastUpdateTimestamp;
  }

  struct ExecuteLiquidationCallParams {
    uint256 reservesCount;
    uint256 debtToCover;
    address collateralAsset;
    address debtAsset;
    address user;
    bool receiveAToken;
    address priceOracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
  }

  struct ExecuteSupplyParams {
    address asset;
    uint256 amount;
    address onBehalfOf;
    uint16 referralCode;
  }

  struct ExecuteBorrowParams {
    address asset;
    address user;
    address onBehalfOf;
    uint256 amount;
    InterestRateMode interestRateMode;
    uint16 referralCode;
    bool releaseUnderlying;
    uint256 maxStableRateBorrowSizePercent;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
  }

  struct ExecuteRepayParams {
    address asset;
    uint256 amount;
    InterestRateMode interestRateMode;
    address onBehalfOf;
    bool useATokens;
  }

  struct ExecuteWithdrawParams {
    address asset;
    uint256 amount;
    address to;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
  }

  struct ExecuteSetUserEModeParams {
    uint256 reservesCount;
    address oracle;
    uint8 categoryId;
  }

  struct FinalizeTransferParams {
    address asset;
    address from;
    address to;
    uint256 amount;
    uint256 balanceFromBefore;
    uint256 balanceToBefore;
    uint256 reservesCount;
    address oracle;
    uint8 fromEModeCategory;
  }

  struct FlashloanParams {
    address receiverAddress;
    address[] assets;
    uint256[] amounts;
    uint256[] interestRateModes;
    address onBehalfOf;
    bytes params;
    uint16 referralCode;
    uint256 flashLoanPremiumToProtocol;
    uint256 flashLoanPremiumTotal;
    uint256 maxStableRateBorrowSizePercent;
    uint256 reservesCount;
    address addressesProvider;
    uint8 userEModeCategory;
    bool isAuthorizedFlashBorrower;
  }

  struct FlashloanSimpleParams {
    address receiverAddress;
    address asset;
    uint256 amount;
    bytes params;
    uint16 referralCode;
    uint256 flashLoanPremiumToProtocol;
    uint256 flashLoanPremiumTotal;
  }

  struct FlashLoanRepaymentParams {
    uint256 amount;
    uint256 totalPremium;
    uint256 flashLoanPremiumToProtocol;
    address asset;
    address receiverAddress;
    uint16 referralCode;
  }

  struct CalculateUserAccountDataParams {
    UserConfigurationMap userConfig;
    uint256 reservesCount;
    address user;
    address oracle;
    uint8 userEModeCategory;
  }

  struct ValidateBorrowParams {
    ReserveCache reserveCache;
    UserConfigurationMap userConfig;
    address asset;
    address userAddress;
    uint256 amount;
    InterestRateMode interestRateMode;
    uint256 maxStableLoanPercent;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
    bool isolationModeActive;
    address isolationModeCollateralAddress;
    uint256 isolationModeDebtCeiling;
  }

  struct ValidateLiquidationCallParams {
    ReserveCache debtReserveCache;
    uint256 totalDebt;
    uint256 healthFactor;
    address priceOracleSentinel;
  }

  struct CalculateInterestRatesParams {
    uint256 unbacked;
    uint256 liquidityAdded;
    uint256 liquidityTaken;
    uint256 totalStableDebt;
    uint256 totalVariableDebt;
    uint256 averageStableBorrowRate;
    uint256 reserveFactor;
    address reserve;
    address aToken;
  }

  struct InitReserveParams {
    address asset;
    address aTokenAddress;
    address stableDebtAddress;
    address variableDebtAddress;
    address interestRateStrategyAddress;
    uint16 reservesCount;
    uint16 maxNumberReserves;
  }
}
