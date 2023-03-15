//SPDX-License-Identifier: GPL-3.0

contract MultiSig{

    address [] public owners;
    uint public numConfReq;

    struct Transaction{
        address to;
        uint value;
        bool executed;
    }

    mapping(uint=>mapping(address=>bool)) isConfirmed;
    Transaction[] public transactions;

    constructor(address[] memory _owners,uint _numConfReq)
    {
        require(_owners.length>1,"Owners must be greater than 1");
        require(_numConfReq>0 && _numConfReq<owners.length,"no. of Confirmation not in syn with no. of owners");

        for(uint i=0;i<_owners.length;i++)
        {
            require(_owners[i]!=address(0),"invalid address");
            owners.push(_owners[i]);
            numConfReq=_numConfReq;
        }
    
    }

    event TransactionSubmitted(uint transactionId,address sender,address receiver,uint amoumnt);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);


    function sumbitTransaction(address _to) public payable
    {
        require(_to!=address(0),"invalid receiver address");
        require(msg.value>0,"amount must be greater than 0");
        uint transactionId=transactions.length;
        transactions.push(Transaction({to:_to,value:msg.value,executed:false}));
        emit TransactionSubmitted(transactionId,msg.sender,_to,msg.value);

    }

     function confirmTransaction(uint _transactionId) public
     {
        require(_transactionId<transactions.length,"Invalid Transaction Id");
        require(!isConfirmed[_transactionId][msg.sender],"Transaction Is Already Confirmed By The Owner");
        isConfirmed[_transactionId][msg.sender]=true;
        emit TransactionConfirmed(_transactionId);
       if(isTransactionConfirmed(_transactionId)){
           executeTransaction(_transactionId);
       }
    }


    function executeTransaction(uint _transactionId) public  payable
    {
       require(_transactionId<transactions.length,"Invalid Transaction Id");
       require(!transactions[_transactionId].executed,"Transaction is already executed");
        (bool success,) =transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
         require(success,"Transaction Execution Failed");
         transactions[_transactionId].executed=true;
         emit TransactionExecuted(_transactionId);
    }
    function isTransactionConfirmed(uint _transactionId) internal view returns(bool)
    {
         require(_transactionId<transactions.length,"Invalid Transaction Id");
         uint confimationCount;
         for(uint i=0;i<owners.length;i++)
         {
            if(isConfirmed[_transactionId][owners[i]])
            {
            confimationCount++;
            }
         }
         return confimationCount>=numConfReq;
    }
}
