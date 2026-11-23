import { expect } from "chai";
import { network } from "hardhat";
// const Product = require("../ignition/modules/product.json");
const Product = {
  "Brand": "Iphone 99 Pro Max",
  "SerialNumber": "IP99PM2024",
  "Duration": 2
};

const { ethers } = await network.create();

describe("MyAuction", function () {
  let myAuction: any; // Contract Instance
  let owner: any; // Owner of the contract
  let bidders: any; // Bidders participating in the auction
  let sampleBidAmount: any = [1, 1.2, 1.5, 2, 2.5, 3]; // Sample bid amounts in ether
  let sampleBidAmountInWei: any = sampleBidAmount.map((amount: any) =>
    ethers.parseEther(amount.toString())); // Convert bid amounts to wei

  beforeEach(async function () { //ทำงานทุกครั้งก่อน it ทำงาน
    console.log("Deploying MyAuction contract...");
    myAuction = await ethers.deployContract("MyAuction", [Product.Brand, Product.SerialNumber,
      Product.Duration]);
    [owner, ...bidders] = await ethers.getSigners(); //กระจาย address ของผู้ประมูลทั้งหมดให้กับ bidders โดยไม่เอา owner
  });

  it("should return product information", async function () {
    const [_brand, _serialNumber] = await myAuction.getProductInfo();
    expect(_brand).to.equal(Product.Brand);
    expect(_serialNumber).to.equal(Product.SerialNumber);
  });

  it("should allow bidders to place bids", async function () {
    for (let i = 0; i < sampleBidAmountInWei.length; i++) {
      const ct = myAuction.connect(bidders[i]); //ct คือ contract ที่เชื่อมต่อกับ address ของผู้ประมูลแต่ละคน
      const tx = await ct.bid({ value: sampleBidAmountInWei[i] }); //value คือจำนวนเงินที่ผู้ประมูลส่งเข้ามา มาจาก msg.value ใน smart contract
      const receipt = await tx.wait();
      expect(receipt.status).to.equal(1); // Check if the transaction was successful
      const highestBid = await myAuction.highestBid();

      const bidAmount = await myAuction.getMyBid(bidders[i].address);
      expect(bidAmount).to.equal(sampleBidAmountInWei[i]);
      expect(highestBid).to.equal(sampleBidAmountInWei[i]);
    }
  });

  const AUCTION_STATES = { "STARTED": 0, "ENDED": 1, "CANCELLED": 2 };
  const delayInSeconds = (s: number) => new Promise((resolve) => setTimeout(resolve, s * 1000)); //เวลาที่ดีเลย์และเมื่อครบเวลาที่กำหนดจะ resolve promise และทำงานต่อไป
  it("should end the auction", async function () {
    const ct = myAuction.connect(owner); //ct คือ contract ที่เชื่อมต่อกับ address ของเจ้าของ
    await delayInSeconds(Product.Duration + 3); //ดีเลย์ตามเวลาที่กำหนดใน product.Duration + 1 วินาที
    const tx = await ct.endAuction();
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1);
    const auctionState = await ct.STATE();
    expect(auctionState).to.equal(AUCTION_STATES.ENDED);
  });

  it("should cancel the auction", async function () {
    const ct = myAuction.connect(owner); //ct คือ contract ที่เชื่อมต่อกับ address ของเจ้าของ
    const tx = await ct.cancelAuction();
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1);
    const auctionState = await ct.STATE();
    expect(auctionState).to.equal(AUCTION_STATES.CANCELLED);
  });

  it("should make a withdrawal after auction ends", async function () {
    let ct, tx, receipt;
    for (let i = 0; i < sampleBidAmountInWei.length; i++) {
      ct = await myAuction.connect(bidders[i]); //ct คือ contract ที่เชื่อมต่อกับ address ของผู้ประมูลแต่ละคน
      tx = await ct.bid({ value: sampleBidAmountInWei[i] }); //value คือจำนวนเงินที่ผู้ประมูลส่งเข้ามา มาจาก msg.value ใน smart contract
      receipt = await tx.wait();
    }
    await delayInSeconds(Product.Duration + 3); //ดีเลย์ตามเวลาที่กำหนดใน product.Duration + 1 วินาที
    ct = myAuction.connect(owner); // connect owner's wallet to the contract
    tx = await ct.endAuction();
    receipt = await tx.wait();
    let i;
    for (i = 0; i < sampleBidAmountInWei.length - 1; i++) {
      ct = await myAuction.connect(bidders[i]); //ct คือ contract ที่เชื่อมต่อกับ address ของผู้ประมูลแต่ละคน
      await expect(ct.withdraw()).to.changeEtherBalance(ethers, bidders[i], sampleBidAmountInWei[i]);
    }
    ct = myAuction.connect(owner); // connect owner's wallet to the contract
    await expect(ct.withdraw()).to.changeEtherBalance(ethers, owner,
      sampleBidAmountInWei[sampleBidAmountInWei.length - 1]);
  });

  it("should make a withdrawal after auction is cancelled", async function () {
    let ct, tx, receipt;
    for (let i = 0; i < sampleBidAmountInWei.length; i++) {
      ct = myAuction.connect(bidders[i]); //ct คือ contract ที่เชื่อมต่อกับ address ของผู้ประมูลแต่ละคน
      tx = await ct.bid({ value: sampleBidAmountInWei[i] }); //value คือจำนวนเงินที่ผู้ประมูลส่งเข้ามา มาจาก msg.value ใน smart contract
      receipt = await tx.wait();
    }
    ct = myAuction.connect(owner); //ct คือ contract ที่เชื่อมต่อกับ address ของเจ้าของ
    tx = await ct.cancelAuction();
    receipt = await tx.wait();
    let i;
    for (i = 0; i < sampleBidAmountInWei.length; i++) {
      ct = await myAuction.connect(bidders[i]); //ct คือ contract ที่เชื่อมต่อกับ address ของผู้ประมูลแต่ละคน
      await expect(ct.withdraw()).to.changeEtherBalance(ethers, bidders[i], sampleBidAmountInWei[i]);
    }
    ct = await myAuction.connect(owner); // connect owner's wallet to the contract
    await expect(ct.withdraw()).to.be.revertedWith("Owner can only withdraw after auction ended"); // Owner should not be able to withdraw any funds after cancellation
  });
});