# EthTransaction
An application to interact with polygon and provide status about transaction to user via slack.

### Flow diagram

![EthTransactions Notifications Workflow](https://user-images.githubusercontent.com/20892499/146677835-59b8cf70-c3e2-4292-b187-7a9928b8061f.png)

### Public APIs
  1. API to get all available transactions (Empty list in case no transaction is cached)
 
    Method: GET
    URL: http://localhost:4000/api/transactions (localhost can be relaced once you will use with your domain)
    Response:
      {
          "transactions": [
              {
                  "alert_sent?": false,
                  "status": "pending",
                  "tx_hash": "generate_dummy_tx_hash1"
              },
              {
                  "alert_sent?": false,
                  "status": "confirm",
                  "tx_hash": "generate_dummy_tx_hash2"
              }
          ]
      }
   
   2. API to create new transaction with initiated status
      
    Method: POST
    URL: http://localhost:4000/api/transactions (localhost can be relaced once you will use with your domain)
    Request: 
      {
          "txs_hash": ["0x03e3e0e94831300112cbd592e94e27353b7b0d11115e6f78a0c81310d97810c3"]
      }
    Response:
      200, ok
      {
          "status": "success"
      }
      
  3. Webhook API to interc with our application and to update status for particular tx_hash
     
    Method: POST
    URL: http://localhost:4000/api/transactions/webhook-stats (localhost can be relaced once you will use with your domain)
    Request: 
      {
          "status": "confirmed",
          "hash": "0x03e3e0e94831300112cbd592e94e27353b7b0d11115e6f78a0c81310d97810c3"
      }
    Response:
      200, ok
    
     
    
