import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
// const {Brand, SerialNumber, Duration} = require("./product.json");
const product = {
  "Brand" : "Iphone 99 Pro Max",
  "SerialNumber" : "IP99PM2024",
  "Duration" : 2
};


export default buildModule("MyAuctionModule", (m) => {
  const brand = m.getParameter("_brand", product.Brand);
  const serialNumber = m.getParameter("_serialNumber", product.SerialNumber);
  const duration = m.getParameter("_duration", product.Duration);
  const myAuction = m.contract("MyAuction" , [brand, serialNumber, duration]);

  return { myAuction };
});
