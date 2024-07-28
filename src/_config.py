# Whether app is in production mode
production = True

db_credentials = {
    "user": "root",
    "host": "localhost",
    "port": 3306,
    "password": "mysqlking@02",
    "db": "inpay",
}

if production:
    db_credentials = {
        "user": "avnadmin",
        "host": "qeasily-db-00-kingcollins172-7f3a.e.aivencloud.com",
        "port": 10826,
        "password": "AVNS_pRyqrPHtfeGTnUevI1l",
        "db": "inpay",
    }
