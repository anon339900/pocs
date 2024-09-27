// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
//... removed code
// XMSToken with Governance.
contract XMSToken {//is IXMSToken, CoreRef {
    string public constant /*override*/ name = "Mars Ecosystem Token";

    string public constant /*override*/ symbol = "XMS";

    uint8 public constant /*override*/ decimals = 18;

    /// @notice Total number of tokens in circulation
    uint256 public /*override*/ totalSupply = 1_000_000_000e18;

    // Allowance amounts on behalf of others
    mapping(address => mapping(address => uint96)) internal _allowances;

    // Official record of token balances for each account
    mapping(address => uint96) internal _balances;

    /// @notice A record of each accounts delegate
    mapping(address => address) public /*override*/ delegates;

    /// @notice A record of votes checkpoints for each account, by index
 //   mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
// ... removed code
    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    constructor(){}

    /**
     * @notice Approve `spender` to transfer up to `amount` from `msg.sender`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
// ... removed code

    /**
     * @notice Triggers an approval from owner to spends
     * @param owner The address to approve from
     * @param spender The address to be approved
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external /*override*/ {
        uint96 amount_;
        if (amount == uint256(-1)) {
            amount_ = uint96(-1);
        } else {
            amount_ = safe96(
                amount,
                "XMSToken::permit: Amount exceeds 96 bits"
            );
        }
        bytes32 domainSeparator =
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(name)),
                    //getChainId(),
                    1,
                    address(this)
                )
            );

        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            amount,
                            nonce,
                            expiry
                        )
                    )
                )
            );
        address signatory = ecrecover(digest, v, r, s);
        require(signatory == owner, "XMSToken::permit: Unauthorized");
        require(nonce == nonces[owner]++, "XMSToken::permit: Invalid nonce");
        require(signatory != address(0), "XMSToken::permit: Invalid signature");

        require(
            block.timestamp <= expiry,
            "XMSToken::permit: Signature expired"
        );
        _allowances[owner][spender] = amount_;

        //... removed code :emit Approval(owner, spender, amount_);
    }
  // ... removed code
    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint96)
    {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
    //... removed code


}