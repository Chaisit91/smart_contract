// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 < 0.9.0;

abstract contract Auction {
    // เจ้าของ
    address payable public owner;
    // รายละเอียดสินค้า
    struct Product {
        string Brand;
        string SerialNumber;
    }

    // สถานะการประมูล
    enum AuctionState { STARTED, ENDED, CANCELLED }

    // client functions

    // ยื่นประมูล | ส่งเงินมาด้วย
    function bid() virtual external payable;
    // ดูยอดเงินที่ผู้ประมูลของตัวเองและผู้อื่น
    function getMyBid(address bidder) virtual external view returns(uint256);

    // owner functions

    // จบการประมูล
    function endAuction() virtual external;
    // ยกเลิกการประมูล
    function cancelAuction() virtual external;

    // shared functions

    // ถอนเงิน
    function withdraw() virtual external;
    // ดูรายละเอียดสินค้า
    function getProductInfo() virtual external view returns(string memory, string memory);

    // events

    // มีการประมูล
    event BidEvent(address bidder, uint256 amount, uint256 timestamp);
    // จบประมูล
    event EndedEvent(string message, uint256 timestamp);
    // ยกเลิกประมูล
    event CancelledEvent(string message, uint256 timestamp);
    // มีการถอนเงิน
    event WithdrawnEvent(address withdrawer, uint256 amount, uint256 timestamp);
}