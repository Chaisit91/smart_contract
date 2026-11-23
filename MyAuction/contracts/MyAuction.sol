// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 < 0.9.0;

import "./Auction.sol";
contract MyAuction is Auction {
    Product public product;
    AuctionState public STATE;
    uint256 public endTime;
    uint256 public highestBid;
    address public highestBidder; //ผู้ประมูลคนที่มีราคาสูงสุด
    address[] public bidders; //เก็บ address ของผู้ประมูลทั้งหมด

    mapping(address => uint256) public bids; //เก็บยอดเงินที่ผู้ประมูลแต่ละคนประมูลไว้

    modifier onlyOwner() { //สิ่งที่ทำงานก่อนที่ function ทำงานจะทำการตรวจสอบว่า msg.sender เป็น owner หรือไม่ ถ้าใช่ก็จะทำงานต่อไป แต่ถ้าไม่ใช่จะ revert
        require(msg.sender == owner, "Only owner can call this function"); //require เป็นการตรวจสอบเงื่อนไข ถ้าเงื่อนไขเป็นจริงจะทำงานต่อไป แต่ถ้าเป็นเท็จจะ revert และแสดงข้อความที่กำหนด
        _; //  _  คือ ให้ function ทำงานต่อไป
    }

    modifier notAnOwner() {
        require(msg.sender != owner, "Owner cannot call this function");
        _; //ก่อน function ทำงานจะทำการตรวจสอบว่า msg.sender ไม่ใช่ owner ถ้าไม่ใช่ก็จะทำงานต่อไป แต่ถ้าเป็น owner จะ revert
    }

    modifier onGoingAuction() { //เช็คว่าการประมูลยังดำเนินอยู่หรือไม่ ถ้า STATE เป็น AuctionState.STARTED จะทำงานต่อไป แต่ถ้าไม่ใช่จะ revert
        require(STATE == AuctionState.STARTED, "Auction is stopped");
        _;
    }

    constructor(
        string memory _brand,
        string memory _serialNumber,
        uint256 _duration
    ) {
        owner = payable(msg.sender);
        product = Product(_brand, _serialNumber);
        STATE = AuctionState.STARTED;
        // endTime = block.timestamp + _duration * 1 minutes;
        endTime = block.timestamp + _duration * 1 seconds; //block.timestamp คือเวลาปัจจุบันของบล็อกที่กำลังทำงานอยู่ 1 seconds คือ 1 วินาที **ออกสอบ**
    } //msg.senderคือคนที่เรียกใช้ฟังก์ชัน constructor  คือเจ้าของ

    function bid() external payable override notAnOwner onGoingAuction {
        require(
            msg.value + bids[msg.sender] > highestBid,
            "Bid must be higher than current highest bid"
        ); //msg.value คือจำนวนเงินที่ผู้ประมูลส่งเข้ามา
        require(
            msg.sender != highestBidder,
            "You are already the highest bidder"
        ); //ตรวจสอบว่า msg.sender ไม่ใช่ highestBidder ถ้าใช่จะ revert
        highestBidder = msg.sender;
        if (bids[msg.sender] == 0) { //มีใครประมูลแล้วหรือยัง ถ้า bids[msg.sender] == 0 แสดงว่ายังไม่มีใครประมูลเลย
            bidders.push(msg.sender); //เก็บ address ของผู้ประมูลทั้งหมด
        }
        bids[msg.sender] += msg.value;
        highestBid = bids[msg.sender]; //เก็บยอดเงินที่ผู้ประมูลแต่ละคนประมูลไว้
        emit BidEvent(msg.sender, bids[msg.sender], block.timestamp); //เชื่อมต่อภายนอกกับภายใน smart contract โดยการส่ง event ไปยังภายนอก
    } //external เสียค่า gas น้อยกว่า

    //ดูยอดเงินที่ประมูลของตัวเองละผู้อื่น
    function getMyBid(address bidder) external view override returns (uint256) { //returns (uint256) คือฟังก์ชันนี้จะคืนค่าเป็น uint256 unsigned integer 256 bit = 32 byte
        return bids[bidder]; //return ยอดเงินที่ผู้ประมูลแต่ละคนประมูลไว้
    }

    //owner fuctions
    //จบการประมูลและยกเลิกการประมูล
    function endAuction() external override onlyOwner onGoingAuction {
        STATE = AuctionState.ENDED; //เปลี่ยนสถานะการประมูลเป็นจบการประมูล
        emit EndedEvent("Auction has ended", block.timestamp); //เชื่อมต่อภายนอกกับภายใน smart contract โดยการส่ง event ไปยังภายนอก
    } // ฟังชั่นไหนที่เจ้าของเรียกใช้จะต้องเป็นเจ้าของเท่านั้น  onlyOwner คือ modifier ที่กำหนดไว้ด้านบน

    //ยกเลิกการประมูล
    function cancelAuction() external override onlyOwner onGoingAuction {
        STATE = AuctionState.CANCELLED;
        emit CancelledEvent("Auction has been cancelled", block.timestamp); //เชื่อมต่อภายนอกกับภายใน smart contract โดยการส่ง event ไปยังภายนอก
    }

    //sheared functions

    //ถอนเงิน
    function withdraw() external override {
        uint256 amount = 0;
        address payable withdrawer = payable(msg.sender);
        require(STATE != AuctionState.STARTED, "Auction is still ongoing");
        if(withdrawer == owner) { // Owner can withdraw the highest bid
            require(STATE == AuctionState.ENDED, "Owner can only withdraw after auction ended");
            require(bids[highestBidder] > 0, "No funds to withdraw for highest bidder");
            amount = highestBid;
            bids[highestBidder] = 0; // Reset the highest bidder's bid
        } else { // Other bidders can withdraw their bids
            bool allowed = ((STATE == AuctionState.ENDED && withdrawer != highestBidder) ||
                (STATE == AuctionState.CANCELLED)) &&
                bids[withdrawer] > 0;
            require(allowed, "You are not allowed to withdraw");
            amount = bids[withdrawer];
            bids[withdrawer] = 0;
        }
        (bool sent, ) = payable(withdrawer).call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit WithdrawnEvent(withdrawer, amount, block.timestamp);
    }

    //ดูรายละเอียดสินค้า ดูproduct  มี view
    function getProductInfo()
        external
        view
        override
        returns (string memory, string memory)
    {
        return (product.Brand, product.SerialNumber);
    }
}
