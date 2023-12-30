
#Whether app is in production mode
production = True

db_credentials  = {'user': 'root', 'host': 'localhost', 'port': 3306, 
                'password': 'mysqlking@02', 'db': 'inpay'}

if production:
     db_credentials = {'user': 'master', 'host': 'mysql-2c185947-kingcollins172-7f3a.a.aivencloud.com', 'port': 10826, 
                'password': 'masterpass', 'db': 'inpay'}
     