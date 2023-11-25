-- INSERT INTO
--      `users` (`name`, `email`, `password`)
-- VALUES
--      ('Jon Doe', 'jondoe@gmail.com', 'strongpassword'),
--      ('Mary Ann', 'mary17@gmail.com', 'justpassword'),
--      (
--           'Mike Roberts',
--           'mikerob@gmail.com',
--           'weakpassword'
--      );

-- INSERT INTO
--      `accounts` (`name`,`account_no`, `pin`, `user_id`)
-- VALUES
--      ('Jon account', '3107748309', '1004', '1'),
--      ('mary account','3107833516', '2002', '2'),
--      ('robs account', '3108893021','1709', '3');

-- INSERT INTO
--      `transactions` (`hash`, `sender_id`, `recipient_id`, `amount`)
-- VALUES
--      ('CB444782BDC6235D5AC3188EBC5463AC', '1', '2', 2.50);


INSERT INTO `savings` (`amount`,`account_id`) VALUES ('2.0', '1');