// SPDX-License-Identifierv: MIT
pragma solidity >= 0.8.0 < 0.9.0;

contract Hellosolidity{
    uint public val1;
    uint private val2;

    // // constructor(uint _val1 , uint _val2){
    //         val1 = _val1
    //         val2 = _val2

    // // }
    function setVal1(uint _val1) public{ //internal เรียกใช้เฉพาะใน contracts นั้นๆ  // External คนอื่นต้องเป็นคนเรียก ไม่เรียกตัวมันเอง
        val1 =_val1;
    }
    function setVal2(uint _val2) public{ //internal เรียกใช้เฉพาะใน contracts นั้นๆ  // External คนอื่นต้องเป็นคนเรียก ไม่เรียกตัวมันเอง  //setter คั้งค่าตัวแปล val2
        val2 =_val2;
    }
    function getVal2() public view returns (uint){ //internal เรียกใช้เฉพาะใน contracts นั้นๆ  // External คนอื่นต้องเป็นคนเรียก ไม่เรียกตัวมันเอง //getter ดึงค่าตัวแปล val2
        return val2;  //getterfuction การที่จะให้คนภายนอกดูด้วยได้  และที่ใช้ getter จะมีการ return คืนค่า
    } // view มีการเรียกดึงค่ามาใช้แต่ไม่ได้เปลี่ยนค่า เรียกมาดูเฉยๆ ให้ใช้ View
    function add(uint _val1 , uint _val2) public pure returns(uint){
        return _val1 + _val2;
    }
}// การใช้ pure ประมวลผลโดยใช้ข้อมูลของ _val1, _val2

// internal เรียกใช้ได้เฉพาะภายใน Contract นี้และ Contract ที่สืบทอดตามเงื่อนไข
// external เน้นเรียกจากภายนอก Contract โดยตรง
// setter ใช้สำหรับกำหนดหรือเปลี่ยนค่าตัวแปร
// getter ใช้สำหรับดึงค่าตัวแปรมาแสดง
// view ใช้อ่านข้อมูล แต่ไม่เปลี่ยนแปลงสถานะของ Contract
// pure ใช้คำนวณโดยไม่อ่านหรือเปลี่ยนแปลงสถานะของ Contract