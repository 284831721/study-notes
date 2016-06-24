#### 未切换资源订单统计
```sql
SELECT
	*, round(
		foo.pay_order_count * 100 /(SELECT count(1) FROM main_order where date(create_time) = date),
		4
	) AS 该店铺支付订单占总比,
	CASE
WHEN foo.pay_order_count = 0 THEN
	0
ELSE
	round(
		foo.close_after_pay_order_count * 100 / foo.pay_order_count,
		4
	)
END AS 关闭订单占支付订单总比
FROM
	(
		SELECT
			CASE
		WHEN tmp.supplier_id = 18024 THEN
			'虚拟自建'
		WHEN tmp.supplier_id = 17800 THEN
			'承载库'
		ELSE
			'接口接入'
		END AS source_type,
		tmp.supplier_id,
		tmp.shop_name,
		tmp. SOURCE,
		DATE (tmp. DATE) AS DATE,
		COUNT (tmp.main_order_id) AS total_order_count,
		SUM (
			CASE
			WHEN tmp.pay_time IS NULL THEN
				0
			ELSE
				1
			END
		) AS pay_order_count,
		SUM (
			CASE
			WHEN tmp.status = 12 THEN
				1
			ELSE
				0
			END
		) AS complete_order_count,
		SUM (
			CASE
			WHEN tmp.status = 12 THEN
				0
			ELSE
				1
			END
		) AS close_order_count,
		SUM (
			CASE
			WHEN tmp.status != 12
			AND tmp.pay_time IS NOT NULL THEN
				1
			ELSE
				0
			END
		) AS close_after_pay_order_count
	FROM
		(
			SELECT
				fo.main_order_id,
				fo.supplier_id,
				fo.flight_more_info -> 'source' AS SOURCE,
				si.shop_name,
				mo.pay_time,
				mo.status,
				DATE (mo.create_time) AS DATE
			FROM
				main_order mo
			INNER JOIN flight_order fo ON mo. ID = fo.main_order_id
			AND (
				fo.origin_supplier != 0
				and fo.origin_supplier IS not NULL
			)
			INNER JOIN b2c_supplier_info si ON supplier_id = si. ID -- AND DATE (mo.create_time) = DATE '$TODAY' - 1
			GROUP BY
				DATE (mo.create_time),
				supplier_id,
				shop_name,
				fo.flight_more_info -> 'source',
				fo.main_order_id,
				mo.pay_time,
				mo.status
		) AS tmp
	GROUP BY
		DATE (tmp. DATE),
		tmp.supplier_id,
		tmp.shop_name,
		tmp. SOURCE
	) AS foo
ORDER BY
	foo.DATE DESC
```

```sql
CREATE INDEX "main_order_create_time_status_idx" ON "public"."main_order" USING btree (create_time);
```
##### 资源类型相关统计
```sql
SELECT
	foo.create_time,
	round(
		SUM (foo.ftype) * 100 / COUNT (DISTINCT foo.main_order_id),
		2
	) AS 国际机票订单占总订单比,
	CASE
WHEN SUM (
	foo.international_order_pay_time
) = 0 THEN
	0
ELSE
	round(
		SUM (
			foo.international_order_pay_time
		) * 100 / SUM (foo.pay_time),
		2
	)
END AS 国际机票支付订单占总支付订单比,
 CASE
WHEN SUM (foo.pay_time) = 0 THEN
	0
ELSE
	round(
		SUM (foo.children_pay) * 100 / SUM (foo.pay_time),
		2
	)
END AS 儿童支付订单数占总支付订单数
FROM
	(
		SELECT
			fo.main_order_id,
			DATE (mo.create_time) create_time,
			CASE
		WHEN fo.flight_type > 1 THEN
			1
		ELSE
			0
		END AS ftype,
		--总支付订单
		CASE
	WHEN mo.pay_time IS NULL THEN
		0
	ELSE
		1
	END AS pay_time,
	--国际订单支付
	CASE
WHEN mo.pay_time IS NOT NULL
AND fo.flight_type > 1 THEN
	1
ELSE
	0
END AS international_order_pay_time,
 CASE
WHEN pi.is_adult IS FALSE
AND mo.pay_time IS NOT NULL THEN
	1
ELSE
	0
END AS children_pay
FROM
	flight_order fo
INNER JOIN main_order mo ON fo.main_order_id = mo. ID
INNER JOIN passenger_info pi ON fo.passenger_id = pi. ID
GROUP BY
	DATE (mo.create_time),
	fo.main_order_id,
	fo.flight_type,
	mo.pay_time,
	pi.is_adult
ORDER BY
	create_time DESC
	) AS foo
GROUP BY
	create_time
ORDER BY
	foo.create_time DESC;
```
##### 各类型订单比例（仅统计支付后）
```sql
SELECT
	foo. DATE,
	COUNT (ID) AS order_count,
	-- 	SUM (foo.ops_order) AS 运营介入订单数,
	round(
		SUM (foo.ops_order) * 100 / COUNT (ID),
		2
	) AS 运营订单（非承载库）占比,
	-- 	SUM (foo.cjz_order) AS 承载库订单数,
	round(
		SUM (foo.cjz_order) * 100 / COUNT (ID),
		2
	) AS 承载库订单占比,
	round(
		SUM (foo.auto_complete_order) * 100 / COUNT (ID),
		2
	) AS 全自动订单占比,
	-- 	SUM (foo.ops_close_order) AS ops_close_order,
	round(
		SUM (foo.ops_close_order) * 100 / COUNT (ID),
		2
	) AS 运营关单占比
FROM
	(
		SELECT
			DATE (mo.create_time) AS DATE,
			mo. ID,
			CASE
		WHEN fo.origin_supplier != 0
		AND fo.supplier_id != 17800 THEN
			1
		ELSE
			0
		END AS ops_order,
		CASE
	WHEN fo.origin_supplier = 0
	AND fo.supplier_id = 17800 THEN
		1
	ELSE
		0
	END AS cjz_order,
	CASE
WHEN fo.origin_supplier = 0 THEN
	1
ELSE
	0
END AS auto_complete_order,
 CASE
WHEN fo.origin_supplier != 0
AND mo.status = 13
AND (
	ro.refund_initiator != 'user'
	OR ro.refund_initiator IS NULL
) THEN
	1
ELSE
	0
END AS ops_close_order
FROM
	main_order mo
INNER JOIN flight_order fo ON mo. ID = fo.main_order_id
AND mo.pay_time IS NOT NULL
LEFT JOIN fcb_refund_order ro ON mo. ID = ro.main_order_id
GROUP BY
	DATE (mo.create_time),
	mo. ID,
	fo.supplier_id,
	fo.origin_supplier,
	ro.refund_initiator
	) AS foo
GROUP BY
	foo. DATE
ORDER BY
	DATE DESC;


```