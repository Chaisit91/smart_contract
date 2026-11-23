import { expect ,assert } from "chai";
import { network } from "hardhat";


const { ethers } = await network.create();

describe("SimpleMath", function () {
  it("Should add two numbers correctly", async function () { // Test case for addition
    const simpleMath = await ethers.deployContract("SimpleMath");
    assert.equal(await simpleMath.add(2n, 3n), 5n,);
  });
  it("Should divide two numbers correctly", async function () { // Test case for division
    const simpleMath = await ethers.deployContract("SimpleMath");
    assert.equal(await simpleMath.divide(6n, 3n), 2n,);  //การบ้าน
    
  });
  it("Should subtract two numbers correctly", async function () { // Test case for subtraction
    const simpleMath = await ethers.deployContract("SimpleMath");
    assert.equal(await simpleMath.subtract(5n, 3n), 2n,);
    
  });
  it("Should multiply two numbers correctly", async function () { // Test case for multiplication
    const simpleMath = await ethers.deployContract("SimpleMath");
    assert.equal(await simpleMath.multiply(2n, 3n), 6n,);
    
  });
  
});
