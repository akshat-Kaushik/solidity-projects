//SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.6;

contract Ecommerce
{
    struct Product 
    {
        string title;
        string desc;
        address payable seller;
        uint productID;
        uint price;
        address buyer;
        bool delivered;
    }
    uint count=1;
    Product[] public products;

    address payable public manager;
    constructor()
    {
        manager=payable(msg.sender);
    }


    bool destroyed=false;

    modifier innotdestroyed
    {
        require(!destroyed,"contract does not exist");
        _;
    }

    event registered(string title, uint productID ,address seller);
    event bought (uint productID,address buyer);
    event delivered (uint productID);

    function registerP(string memory _title,string memory _desc,uint _price) public innotdestroyed
    {
        require(_price>0,"Price should be greater than zero");
        Product memory tempProduct;
        tempProduct.title=_title;
        tempProduct.desc=_desc;
        tempProduct.price=_price;
        tempProduct.seller=payable(msg.sender);
        tempProduct.productID=count;
        products.push(tempProduct);
        count++;
        emit registered(_title,tempProduct.productID,msg.sender);

    }

    function buy(uint _productID) payable public innotdestroyed
    {
        require(products[_productID-1].price==msg.value,"pay the exact value");
        require(products[_productID-1].seller!=msg.sender,"seller cannot be the buyer");
        products[_productID-1].buyer=msg.sender;
        emit bought(_productID,msg.sender);
    }

    function delivery(uint _productID) public innotdestroyed
    {
        require(products[_productID-1].buyer==msg.sender,"Only buyer can confirm");
        products[_productID-1].delivered=true;
        products[_productID-1].seller.transfer(products[_productID-1].price);
        emit delivered(_productID);
    }

    // function destroy() public 
    // {
    //     require(msg.sender==manager,"only manager can call this func");
    //     selfdestruct(manager);
    // }
    //not using this function

    function destroy() public innotdestroyed
    {
        require(manager==msg.sender);
        manager.transfer(address(this).balance);
        destroyed=true;

    }

    fallback() payable external

    {
        payable (msg.sender).transfer(msg.value);
    }
}