CREATE DATABASE IF NOT EXISTS `couple_life`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `couple_life`;
SET NAMES utf8mb4;


CREATE TABLE IF NOT EXISTS `app_user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `openid` varchar(64) NOT NULL COMMENT '微信小程序用户唯一标识',
  `unionid` varchar(64) DEFAULT NULL COMMENT '微信开放平台 UnionID',
  `nickname` varchar(64) DEFAULT NULL COMMENT '微信昵称/用户昵称',
  `avatar_url` varchar(500) DEFAULT NULL COMMENT '头像地址',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号，可选',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '用户状态：0禁用，1正常',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_app_user_openid` (`openid`),
  KEY `idx_app_user_unionid` (`unionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='小程序用户';


CREATE TABLE IF NOT EXISTS `couple` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_name` varchar(64) DEFAULT NULL COMMENT '情侣空间名称',
  `invite_code` varchar(16) DEFAULT NULL COMMENT '配对邀请码',
  `created_by_user_id` bigint unsigned NOT NULL COMMENT '创建人用户ID',
  `status` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '状态：0待配对，1已配对，2已解除',
  `invite_expires_at` datetime DEFAULT NULL COMMENT '邀请码过期时间',
  `paired_at` datetime DEFAULT NULL COMMENT '配对成功时间',
  `dissolved_at` datetime DEFAULT NULL COMMENT '解除关系时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_couple_invite_code` (`invite_code`),
  KEY `idx_couple_creator` (`created_by_user_id`),
  CONSTRAINT `fk_couple_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣关系/情侣空间';

-- 情侣与用户关系表
-- 每个情侣空间最多两名有效成员仍需在配对事务中校验
CREATE TABLE IF NOT EXISTS `couple_member` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '情侣空间ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `member_role` tinyint unsigned NOT NULL DEFAULT '2' COMMENT '角色：1创建者，2另一方',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '成员状态：0已退出，1有效',
  `active_user_id` bigint unsigned GENERATED ALWAYS AS (CASE WHEN `status` = 1 THEN `user_id` ELSE NULL END) STORED COMMENT '有效成员唯一约束辅助列，不需要业务代码赋值',
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `left_at` datetime DEFAULT NULL COMMENT '退出时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_couple_member_active_user` (`active_user_id`),
  KEY `idx_couple_member_couple_user` (`couple_id`, `user_id`),
  KEY `idx_couple_member_user` (`user_id`, `status`),
  CONSTRAINT `fk_couple_member_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_couple_member_user` FOREIGN KEY (`user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣成员关系';


CREATE TABLE IF NOT EXISTS `product_category` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `name` varchar(64) NOT NULL COMMENT '分类名称',
  `description` varchar(255) DEFAULT NULL COMMENT '分类描述',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序值，越小越靠前',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `created_by_user_id` bigint unsigned DEFAULT NULL COMMENT '创建人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_category_name` (`couple_id`, `name`),
  KEY `idx_product_category_sort` (`couple_id`, `status`, `sort`),
  CONSTRAINT `fk_product_category_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_product_category_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='甜蜜商城商品分类';

CREATE TABLE IF NOT EXISTS `sweet_product` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `category_id` bigint unsigned NOT NULL COMMENT '商品分类ID',
  `name` varchar(100) NOT NULL COMMENT '商品/权益名称',
  `product_type` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '类型：1服务券，2甜蜜特权，3约会体验，4礼物/惊喜（默认不走物流配送）',
  `points_price` int unsigned NOT NULL DEFAULT '0' COMMENT '兑换所需积分',
  `stock` int NOT NULL DEFAULT '-1' COMMENT '库存：-1表示不限量，0表示售罄，大于0表示剩余数量',
  `image` varchar(500) DEFAULT NULL COMMENT '商品图片地址',
  `description` varchar(1000) DEFAULT NULL COMMENT '商品介绍',
  `usage_instructions` varchar(1000) DEFAULT NULL COMMENT '使用说明/兑换规则',
  `valid_days` smallint unsigned NOT NULL DEFAULT '0' COMMENT '兑换后有效天数：0表示永久有效',
  `limit_per_user` int unsigned NOT NULL DEFAULT '0' COMMENT '每人限兑数量：0表示不限',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序值',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：0下架，1上架',
  `created_by_user_id` bigint unsigned DEFAULT NULL COMMENT '创建人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sweet_product_name` (`couple_id`, `name`),
  KEY `idx_sweet_product_category` (`couple_id`, `category_id`, `status`, `sort`),
  CONSTRAINT `fk_sweet_product_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_sweet_product_category` FOREIGN KEY (`category_id`) REFERENCES `product_category` (`id`),
  CONSTRAINT `fk_sweet_product_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣甜蜜商城商品/权益';


CREATE TABLE IF NOT EXISTS `shopping_cart` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `user_id` bigint unsigned NOT NULL COMMENT '加入购物车的用户ID',
  `product_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `quantity` int unsigned NOT NULL DEFAULT '1' COMMENT '数量',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cart_user_product` (`user_id`, `product_id`),
  KEY `idx_cart_couple_user` (`couple_id`, `user_id`),
  CONSTRAINT `fk_cart_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `sweet_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣甜蜜商城购物车';

CREATE TABLE IF NOT EXISTS `sweet_order` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(40) NOT NULL COMMENT '订单编号',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `buyer_user_id` bigint unsigned NOT NULL COMMENT '兑换人/下单用户ID',
  `receiver_user_id` bigint unsigned NOT NULL COMMENT '权益归属人ID，可为自己或另一半',
  `order_status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：1已兑换，2已取消，3已退款',
  `total_quantity` int unsigned NOT NULL DEFAULT '0' COMMENT '商品总数量',
  `total_points` int unsigned NOT NULL DEFAULT '0' COMMENT '订单消耗总积分',
  `remark` varchar(500) DEFAULT NULL COMMENT '下单备注',
  `ordered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `cancelled_at` datetime DEFAULT NULL COMMENT '取消时间',
  `refunded_at` datetime DEFAULT NULL COMMENT '退款时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sweet_order_no` (`order_no`),
  KEY `idx_sweet_order_buyer` (`couple_id`, `buyer_user_id`, `ordered_at`),
  KEY `idx_sweet_order_receiver` (`couple_id`, `receiver_user_id`, `ordered_at`),
  CONSTRAINT `fk_sweet_order_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_sweet_order_buyer` FOREIGN KEY (`buyer_user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_sweet_order_receiver` FOREIGN KEY (`receiver_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣甜蜜兑换订单';

CREATE TABLE IF NOT EXISTS `sweet_order_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `product_id` bigint unsigned DEFAULT NULL COMMENT '商品ID，保留历史快照时允许为空',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称快照',
  `product_image` varchar(500) DEFAULT NULL COMMENT '商品图片快照',
  `product_type` tinyint unsigned NOT NULL COMMENT '商品类型快照',
  `points_price` int unsigned NOT NULL COMMENT '下单时单价积分快照',
  `quantity` int unsigned NOT NULL DEFAULT '1' COMMENT '购买数量',
  `total_points` int unsigned NOT NULL COMMENT '该明细消耗积分',
  PRIMARY KEY (`id`),
  KEY `idx_sweet_order_item_order` (`order_id`),
  KEY `idx_sweet_order_item_product` (`product_id`),
  CONSTRAINT `fk_sweet_order_item_order` FOREIGN KEY (`order_id`) REFERENCES `sweet_order` (`id`),
  CONSTRAINT `fk_sweet_order_item_product` FOREIGN KEY (`product_id`) REFERENCES `sweet_product` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣兑换订单明细（保留商品快照）';


CREATE TABLE IF NOT EXISTS `couple_inventory` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `order_id` bigint unsigned NOT NULL COMMENT '来源订单ID',
  `order_item_id` bigint unsigned NOT NULL COMMENT '来源订单明细ID',
  `product_id` bigint unsigned DEFAULT NULL COMMENT '商品ID',
  `buyer_user_id` bigint unsigned NOT NULL COMMENT '兑换购买人ID',
  `owner_user_id` bigint unsigned NOT NULL COMMENT '仓库归属用户ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称快照',
  `product_image` varchar(500) DEFAULT NULL COMMENT '商品图片快照',
  `points_price` int unsigned NOT NULL COMMENT '兑换时所需积分快照',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：1未使用，2使用处理中，3已使用，4已过期，5已撤销',
  `acquired_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
  `expires_at` datetime DEFAULT NULL COMMENT '过期时间',
  `used_at` datetime DEFAULT NULL COMMENT '使用完成时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_inventory_owner` (`couple_id`, `owner_user_id`, `status`, `acquired_at`),
  KEY `idx_inventory_order` (`order_id`, `order_item_id`),
  CONSTRAINT `fk_inventory_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_inventory_order` FOREIGN KEY (`order_id`) REFERENCES `sweet_order` (`id`),
  CONSTRAINT `fk_inventory_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `sweet_order_item` (`id`),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `sweet_product` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_inventory_buyer` FOREIGN KEY (`buyer_user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_inventory_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣个人仓库/已兑换权益';

CREATE TABLE IF NOT EXISTS `redeem_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `inventory_id` bigint unsigned NOT NULL COMMENT '仓库权益ID',
  `request_user_id` bigint unsigned NOT NULL COMMENT '申请使用人/权益持有人',
  `fulfill_user_id` bigint unsigned NOT NULL COMMENT '需要履行权益的另一方',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：1待处理，2已接受，3已完成，4已拒绝，5已撤销',
  `request_note` varchar(500) DEFAULT NULL COMMENT '使用请求说明',
  `response_note` varchar(500) DEFAULT NULL COMMENT '对方处理说明',
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `accepted_at` datetime DEFAULT NULL COMMENT '接受时间',
  `completed_at` datetime DEFAULT NULL COMMENT '履行完成时间',
  `rejected_at` datetime DEFAULT NULL COMMENT '拒绝时间',
  `cancelled_at` datetime DEFAULT NULL COMMENT '撤销时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_redeem_inventory` (`inventory_id`, `status`),
  KEY `idx_redeem_request_user` (`couple_id`, `request_user_id`, `requested_at`),
  KEY `idx_redeem_fulfill_user` (`couple_id`, `fulfill_user_id`, `status`),
  CONSTRAINT `fk_redeem_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_redeem_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `couple_inventory` (`id`),
  CONSTRAINT `fk_redeem_request_user` FOREIGN KEY (`request_user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_redeem_fulfill_user` FOREIGN KEY (`fulfill_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣权益兑现/使用记录';


CREATE TABLE IF NOT EXISTS `couple_task` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `title` varchar(100) NOT NULL COMMENT '任务标题',
  `description` varchar(1000) DEFAULT NULL COMMENT '任务说明',
  `task_type` tinyint unsigned NOT NULL DEFAULT '5' COMMENT '类型：1日常，2家务，3浪漫互动，4约会，5其他',
  `created_by_user_id` bigint unsigned NOT NULL COMMENT '任务发布人ID',
  `executor_user_id` bigint unsigned NOT NULL COMMENT '任务执行人ID',
  `reviewer_user_id` bigint unsigned NOT NULL COMMENT '任务确认人ID',
  `reward_points` int unsigned NOT NULL DEFAULT '0' COMMENT '完成奖励积分',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '状态：1待完成，2待确认，3已完成，4待修改/未通过，5已取消',
  `due_time` datetime DEFAULT NULL COMMENT '任务截止时间',
  `submit_note` varchar(1000) DEFAULT NULL COMMENT '执行人完成说明',
  `review_note` varchar(1000) DEFAULT NULL COMMENT '确认/驳回说明',
  `submitted_at` datetime DEFAULT NULL COMMENT '提交完成时间',
  `reviewed_at` datetime DEFAULT NULL COMMENT '确认/驳回时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_task_executor` (`couple_id`, `executor_user_id`, `status`, `due_time`),
  KEY `idx_task_reviewer` (`couple_id`, `reviewer_user_id`, `status`),
  KEY `idx_task_creator` (`couple_id`, `created_by_user_id`, `create_time`),
  CONSTRAINT `fk_task_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_task_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_task_executor` FOREIGN KEY (`executor_user_id`) REFERENCES `app_user` (`id`),
  CONSTRAINT `fk_task_reviewer` FOREIGN KEY (`reviewer_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣互动任务';

CREATE TABLE IF NOT EXISTS `point_account` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `user_id` bigint unsigned NOT NULL COMMENT '积分所属用户ID',
  `balance` int unsigned NOT NULL DEFAULT '0' COMMENT '当前可用积分',
  `total_earned` bigint unsigned NOT NULL DEFAULT '0' COMMENT '累计获得积分',
  `total_spent` bigint unsigned NOT NULL DEFAULT '0' COMMENT '累计消耗积分',
  `version` int unsigned NOT NULL DEFAULT '0' COMMENT '乐观锁版本号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_point_account_member` (`couple_id`, `user_id`),
  CONSTRAINT `fk_point_account_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_point_account_user` FOREIGN KEY (`user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣用户积分账户';

CREATE TABLE IF NOT EXISTS `point_transaction` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `account_id` bigint unsigned NOT NULL COMMENT '积分账户ID',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `user_id` bigint unsigned NOT NULL COMMENT '积分所属用户ID',
  `transaction_type` tinyint unsigned NOT NULL COMMENT '类型：1任务奖励，2兑换消费，3退款返还，4人工调整',
  `change_points` int NOT NULL COMMENT '积分变动：增加为正数，扣减为负数',
  `balance_after` int unsigned NOT NULL COMMENT '变动后的积分余额',
  `biz_type` varchar(32) NOT NULL COMMENT '关联业务类型，如 task/order/refund/adjust',
  `biz_id` bigint unsigned DEFAULT NULL COMMENT '关联业务记录ID；人工调整等无业务主键场景允许为空',
  `idempotency_key` varchar(128) NOT NULL COMMENT '幂等键：同一积分变更请求重试时必须复用；人工调整也必须提供稳定请求标识',
  `description` varchar(255) DEFAULT NULL COMMENT '变动说明',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_point_transaction_idempotency` (`account_id`, `idempotency_key`),
  KEY `idx_point_transaction_biz` (`user_id`, `biz_type`, `biz_id`, `transaction_type`),
  KEY `idx_point_transaction_account` (`account_id`, `create_time`),
  KEY `idx_point_transaction_couple` (`couple_id`, `user_id`, `create_time`),
  CONSTRAINT `fk_point_transaction_account` FOREIGN KEY (`account_id`) REFERENCES `point_account` (`id`),
  CONSTRAINT `fk_point_transaction_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_point_transaction_user` FOREIGN KEY (`user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣积分变动流水';


CREATE TABLE IF NOT EXISTS `couple_moment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `couple_id` bigint unsigned NOT NULL COMMENT '所属情侣空间ID',
  `author_user_id` bigint unsigned NOT NULL COMMENT '发布人用户ID',
  `title` varchar(100) NOT NULL COMMENT '记录标题',
  `content` text COMMENT '记录内容',
  `cover_image` varchar(500) DEFAULT NULL COMMENT '封面图片地址',
  `memory_date` datetime DEFAULT NULL COMMENT '事情发生/纪念日期',
  `is_pinned` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '是否置顶：0否，1是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_couple_moment_date` (`couple_id`, `memory_date`),
  KEY `idx_couple_moment_author` (`author_user_id`),
  CONSTRAINT `fk_couple_moment_couple` FOREIGN KEY (`couple_id`) REFERENCES `couple` (`id`),
  CONSTRAINT `fk_couple_moment_author` FOREIGN KEY (`author_user_id`) REFERENCES `app_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='情侣共同回忆/甜蜜日记';
